// ==UserScript==
// @name         scrapbox-split-page-button
// @namespace    http://tampermonkey.net
// @match        https://scrapbox.io/*
// @match        https://*.scrapbox.io/*
// @run-at       document-start
// @description  Ctrl+Alt+N で .split-page-button をクリック（Scrapbox）
// @version      0.0.1
// @grant        none
// ==/UserScript==

(() => {
  "use strict";

  window.addEventListener(
    "keydown",
    (e) => {
      if (!e.ctrlKey || !e.altKey || e.shiftKey || e.metaKey) return;
      const k = e.key.toLowerCase();
      const isN = k === "n" || e.code === "KeyN";
      if (!isN) return;

      const btn = document.querySelector(".split-page-button");
      if (!btn) return;

      e.preventDefault();
      e.stopImmediatePropagation();

      btn.click();
    },
    true
  );
})();
