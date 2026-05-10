// ==UserScript==
// @name         Scrapbox: Alt+Enter to jump to page link
// @namespace    http://tampermonkey.net/
// @version      0.0.6
// @description  Scrapbox で Alt+Enter を押すと、cursor 行のリンクに遷移する。cursor 行は edit モードで <a> が消えるため、生テキストをパースして URL を解決する。bracket / 裸 URL / hashtag に対応。
// @author       kbwo
// @match        https://scrapbox.io/*
// @match        https://*.scrapbox.io/*
// @run-at       document-start
// @grant        none
// ==/UserScript==

(() => {
  "use strict";

  const TAG = "[alt-enter-jump]";
  const log = (...args) => console.log(TAG, ...args);

  log("userscript loaded", { url: location.href, readyState: document.readyState });

  // .char-index span の class から c-N の N を取り出す。
  function charIndexOf(el) {
    if (!el || !el.classList) return -1;
    for (const c of el.classList) {
      const m = /^c-(\d+)$/.exec(c);
      if (m) return parseInt(m[1], 10);
    }
    return -1;
  }

  // cursor の char index (line 内の何文字目か) を返す。
  // .cursor 要素の表示位置を起点に elementsFromPoint で
  // .char-index span を探し、その c-N から index を取る。
  function getCursorCharIndex() {
    const cursor = document.querySelector(".cursor");
    if (!cursor) return -1;
    const rect = cursor.getBoundingClientRect();
    const y = rect.top + rect.height / 2;

    for (const dx of [1, -1, 3, -3, 6, -6]) {
      const x = rect.left + dx;
      const els = document.elementsFromPoint(x, y);
      for (const el of els) {
        if (el && el.classList && el.classList.contains("char-index")) {
          const idx = charIndexOf(el);
          if (idx >= 0) {
            // dx>0 なら cursor の右隣 (cursor の直後) の文字、
            // dx<0 なら cursor の左隣 (cursor の直前) の文字。
            // 直前文字を選んで返したいので dx>0 のときは -1 する。
            return dx > 0 ? Math.max(0, idx - 1) : idx;
          }
        }
      }
    }
    return -1;
  }

  // cursor 行の生テキストを返す。
  // .cursor-line 内の .char-index span を c-N 順に並べて連結する。
  function getCursorLineText() {
    const line = document.querySelector(".cursor-line");
    if (!line) return null;
    const spans = Array.from(line.querySelectorAll(".char-index"));
    if (spans.length === 0) {
      // edit モードでなければ普通の textContent
      return line.textContent || "";
    }
    const indexed = spans
      .map((s) => ({ idx: charIndexOf(s), text: s.textContent || "" }))
      .filter((x) => x.idx >= 0)
      .sort((a, b) => a.idx - b.idx);
    let out = "";
    for (const { text } of indexed) out += text;
    return out;
  }

  // 行内のリンク候補を全部集める。
  // Scrapbox は以下を自動リンク化する:
  //   - [...] bracket (内部ページ / 外部 URL いずれも)
  //   - 裸の https?:// URL
  //   - #hashtag (内部ページ)
  function collectLinks(text) {
    const out = [];

    const bracketRe = /\[([^\[\]\n]+)\]/g;
    let m;
    while ((m = bracketRe.exec(text)) !== null) {
      out.push({
        type: "bracket",
        content: m[1],
        start: m.index,
        end: m.index + m[0].length,
      });
    }

    // 裸 URL。bracket 内の URL とも match するが、bracket 候補が同じ位置にあるので
    // 後段で先に bracket を選べばよい。ただ重複は避けたいので bracket 範囲内なら除外。
    const urlRe = /https?:\/\/[^\s\[\]<>]+/g;
    while ((m = urlRe.exec(text)) !== null) {
      const start = m.index;
      const end = start + m[0].length;
      const insideBracket = out.some(
        (b) => b.type === "bracket" && start >= b.start && end <= b.end,
      );
      if (insideBracket) continue;
      out.push({ type: "url", content: m[0], start, end });
    }

    // #hashtag (行頭または whitespace の直後)
    const hashRe = /(^|\s)#(\S+)/g;
    while ((m = hashRe.exec(text)) !== null) {
      const tagStart = m.index + m[1].length; // # の位置
      const tagEnd = tagStart + 1 + m[2].length;
      out.push({ type: "hashtag", content: m[2], start: tagStart, end: tagEnd });
    }

    return out.sort((a, b) => a.start - b.start);
  }

  // cursor 位置 idx に最も近いリンクを選ぶ。
  // 1. idx が範囲内にあるもの
  // 2. idx 以降で最初に現れるもの
  // 3. 行内の先頭リンク
  function pickLinkNear(links, idx) {
    if (links.length === 0) return null;
    for (const l of links) {
      if (idx >= l.start && idx <= l.end) return { ...l, hit: "inside" };
    }
    for (const l of links) {
      if (l.start >= idx) return { ...l, hit: "after" };
    }
    return { ...links[0], hit: "first" };
  }

  // リンク候補から実際の URL を解決する。
  function resolveUrl(item) {
    if (item.type === "url") return item.content;

    if (item.type === "bracket") {
      const trimmed = item.content.trim();
      const urlMatch = trimmed.match(/(https?:\/\/\S+)/);
      if (urlMatch) return urlMatch[1];
      return resolveInternal(trimmed);
    }

    if (item.type === "hashtag") {
      return resolveInternal(item.content);
    }

    return null;
  }

  // 同じ project 内のページ URL を組み立てる。
  // Scrapbox のページ URL は空白を _ に変換し、ページタイトル全体を path segment として escape する。
  function resolveInternal(title) {
    const parts = location.pathname.split("/").filter(Boolean);
    const project = parts[0];
    if (!project) return null;
    const slug = title.replace(/ /g, "_");
    return `/${project}/${encodeURIComponent(slug)}`;
  }

  function handler(e) {
    if (e.key !== "Enter") return;
    log("handler: Enter pressed", {
      altKey: e.altKey, ctrlKey: e.ctrlKey, shiftKey: e.shiftKey, metaKey: e.metaKey,
      type: e.type, eventPhase: e.eventPhase, defaultPrevented: e.defaultPrevented,
    });
    if (!e.altKey) return;
    if (e.ctrlKey || e.shiftKey || e.metaKey) return;

    const line = document.querySelector(".cursor-line");
    log("handler: cursor-line", {
      element: line,
      outerHTML_snapshot: line ? line.outerHTML : null,
      textContent_snapshot: line ? line.textContent : null,
      classes: line ? line.className : null,
      anchorCount: line ? line.querySelectorAll("a").length : 0,
    });

    if (!line) {
      log("handler: no .cursor-line, aborting");
      return;
    }

    const text = getCursorLineText();
    const cursorIdx = getCursorCharIndex();
    log("handler: parsed line", { text, cursorIdx });

    const links = collectLinks(text);
    log("handler: collected links", links);

    const picked = pickLinkNear(links, cursorIdx);
    log("handler: picked link", picked);

    if (!picked) {
      log("handler: no link in line, aborting");
      return;
    }

    const url = resolveUrl(picked);
    log("handler: resolved url", { picked, url });

    if (!url) {
      log("handler: could not resolve url, aborting");
      return;
    }

    e.preventDefault();
    e.stopImmediatePropagation();
    e.stopPropagation();

    // 外部 URL は新規タブで、内部 URL は同タブで遷移 (Scrapbox の通常クリック挙動に合わせる)。
    if (/^https?:\/\//i.test(url)) {
      log("handler: opening external in new tab");
      window.open(url, "_blank", "noopener,noreferrer");
    } else {
      log("handler: navigating in current tab");
      location.href = url;
    }
  }

  const targets = [window, document];
  for (const t of targets) {
    t.addEventListener("keydown", handler, true);
    log("registered keydown listener on", t === window ? "window" : "document");
  }

  const seen = new WeakSet();
  function bindTextInput() {
    const ti = document.getElementById("text-input");
    if (!ti || seen.has(ti)) return;
    seen.add(ti);
    ti.addEventListener("keydown", handler, true);
    log("registered keydown listener on #text-input", ti);
  }
  bindTextInput();
  const mo = new MutationObserver(bindTextInput);
  mo.observe(document.documentElement, { childList: true, subtree: true });
  log("MutationObserver started for #text-input");
})();
