// ==UserScript==
// @name         Scrapbox: Alt+Enter to jump to page link
// @namespace    http://tampermonkey.net/
// @version      0.0.1
// @description  Scrapbox で Alt+Enter を押すと、cursor 位置の page link に遷移する。なければ cursor 行の先頭リンクを踏む。
// @author       kbwo
// @match        https://scrapbox.io/*
// @match        https://*.scrapbox.io/*
// @run-at       document-start
// @grant        none
// ==/UserScript==

(() => {
  "use strict";

  // cursor 位置にある a.page-link を返す。
  // .cursor 要素の表示位置を起点に elementFromPoint でヒットテストする。
  function findLinkAtCursor() {
    const cursor = document.querySelector(".cursor");
    if (!cursor) return null;

    const rect = cursor.getBoundingClientRect();
    const y = rect.top + rect.height / 2;

    // .cursor は文字の境界に描画される細い縦線なので、
    // 左右両側を少しずつずらして link を探す。
    for (const dx of [3, -3, 1, -1, 6, -6]) {
      const el = document.elementFromPoint(rect.left + dx, y);
      const link = el && el.closest && el.closest("a.page-link");
      if (link) return link;
    }
    return null;
  }

  // cursor 行の先頭にある a.page-link
  function findFirstLinkInCursorLine() {
    const line = document.querySelector(".cursor-line");
    return line ? line.querySelector("a.page-link") : null;
  }

  function handler(e) {
    if (e.key !== "Enter") return;
    if (!e.altKey) return;
    if (e.ctrlKey || e.shiftKey || e.metaKey) return;

    const link = findLinkAtCursor() || findFirstLinkInCursorLine();
    if (!(link instanceof HTMLAnchorElement)) return;

    e.preventDefault();
    e.stopImmediatePropagation();
    e.stopPropagation();
    link.click();
  }

  window.addEventListener("keydown", handler, true);
  document.addEventListener("keydown", handler, true);
})();
