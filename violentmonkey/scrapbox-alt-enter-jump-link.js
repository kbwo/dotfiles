// ==UserScript==
// @name         Scrapbox: Alt+Enter to jump to page link
// @namespace    http://tampermonkey.net/
// @version      0.0.4
// @description  Scrapbox で Alt+Enter を押すと、cursor 行のリンクに遷移する。cursor 行は edit モードで <a> が消えるため、生テキストをパースして URL を解決する。
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

  // text 中の bracket ([...]) のうち、char index が範囲内に含まれるもの、
  // なければ index 以降で最初に現れるものを返す。
  // ネストした [[...]] や行頭の `[` は無視 — Scrapbox の bracket syntax を簡易にカバー。
  function findBracketNear(text, idx) {
    const re = /\[([^\[\]\n]+)\]/g;
    let m;
    let after = null;
    while ((m = re.exec(text)) !== null) {
      const start = m.index;
      const end = start + m[0].length;
      if (idx >= start && idx <= end) {
        return { content: m[1], start, end, hit: "inside" };
      }
      if (idx < start && !after) after = { content: m[1], start, end, hit: "after" };
    }
    return after;
  }

  // bracket の中身から URL を解決する。
  // 形式:
  //   [https://...]                → 外部 URL
  //   [name https://...]           → 外部 URL (name は無視)
  //   [https://... name]           → 外部 URL
  //   [Page Title]                 → 同じ project の内部ページ
  function resolveUrl(content) {
    const trimmed = content.trim();
    const urlMatch = trimmed.match(/(https?:\/\/\S+)/);
    if (urlMatch) return urlMatch[1];

    // 内部ページリンク。/{project}/{title}
    const parts = location.pathname.split("/").filter(Boolean);
    const project = parts[0];
    if (!project) return null;
    // Scrapbox のページ URL は空白を _ に変換、それ以外は encodeURIComponent。
    const title = trimmed.replace(/ /g, "_");
    return `/${project}/${encodeURI(title)}`;
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

    const bracket = findBracketNear(text, cursorIdx);
    log("handler: bracket result", bracket);

    if (!bracket) {
      log("handler: no bracket link in line, aborting");
      return;
    }

    const url = resolveUrl(bracket.content);
    log("handler: resolved url", { content: bracket.content, url });

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
