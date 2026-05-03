// ==UserScript==
// @name         Scrapbox: Alt+Enter to jump to page link
// @namespace    http://tampermonkey.net/
// @version      0.0.3
// @description  Scrapbox で Alt+Enter を押すと、cursor 位置の link に遷移する。なければ cursor 行の先頭リンクを踏む。
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

  // 内部ページリンク (a.page-link) と外部 URL リンク (a.link) の両方を対象にする。
  const LINK_SELECTOR = "a.page-link, a.link";

  // cursor 位置にある link を返す。
  // .cursor 要素の表示位置を起点に elementsFromPoint でヒットテストする。
  // Scrapbox は cursor 位置検出用の .char-index span を実テキストの上に
  // overlay しているため、elementFromPoint (単数) では下の <a> に届かない。
  // elementsFromPoint で重なっている要素を全部見て探す。
  function findLinkAtCursor() {
    const cursor = document.querySelector(".cursor");
    log("findLinkAtCursor: .cursor =", cursor);
    if (!cursor) return null;

    const rect = cursor.getBoundingClientRect();
    const y = rect.top + rect.height / 2;
    log("findLinkAtCursor: cursor rect =", {
      left: rect.left, top: rect.top, width: rect.width, height: rect.height,
    });

    // .cursor は文字の境界に描画される細い縦線なので、
    // 左右両側を少しずつずらして link を探す。
    for (const dx of [3, -3, 1, -1, 6, -6]) {
      const x = rect.left + dx;
      const els = document.elementsFromPoint(x, y);
      let link = null;
      for (const el of els) {
        if (el && el.closest) {
          const found = el.closest(LINK_SELECTOR);
          if (found) { link = found; break; }
        }
      }
      log("findLinkAtCursor: probe", { dx, x, y, els, link });
      if (link) return link;
    }
    return null;
  }

  // cursor 行の先頭にある link
  function findFirstLinkInCursorLine() {
    const line = document.querySelector(".cursor-line");
    log("findFirstLinkInCursorLine: .cursor-line =", line);
    if (!line) return null;
    const link = line.querySelector(LINK_SELECTOR);
    log("findFirstLinkInCursorLine: link =", link);
    return link;
  }

  function handler(e) {
    if (e.key !== "Enter") return;
    log("handler: Enter pressed", {
      altKey: e.altKey, ctrlKey: e.ctrlKey, shiftKey: e.shiftKey, metaKey: e.metaKey,
      type: e.type, target: e.target, currentTarget: e.currentTarget,
      eventPhase: e.eventPhase, defaultPrevented: e.defaultPrevented,
    });
    if (!e.altKey) {
      log("handler: skip — altKey is false");
      return;
    }
    if (e.ctrlKey || e.shiftKey || e.metaKey) {
      log("handler: skip — other modifiers are pressed");
      return;
    }

    const linkAt = findLinkAtCursor();
    const linkFirst = linkAt ? null : findFirstLinkInCursorLine();
    const link = linkAt || linkFirst;
    log("handler: resolved link", { fromCursor: linkAt, fromLine: linkFirst, chosen: link });

    if (!(link instanceof HTMLAnchorElement)) {
      log("handler: no anchor link found, aborting");
      return;
    }

    e.preventDefault();
    e.stopImmediatePropagation();
    e.stopPropagation();
    log("handler: clicking link", { href: link.href, text: link.textContent });
    link.click();
  }

  // 取りこぼしを防ぐため複数の target で listen する。
  // 同じ event が複数回 handler に届くケースもあるので、その場合は log で確認する。
  const targets = [window, document];
  for (const t of targets) {
    t.addEventListener("keydown", handler, true);
    log("registered keydown listener on", t === window ? "window" : "document");
  }

  // #text-input は Scrapbox の入力 element。後から差し替えられる可能性があるので、
  // 出現を監視して keydown listener を bind する。
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
