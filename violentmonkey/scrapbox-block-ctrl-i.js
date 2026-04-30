// ==UserScript==
// @name         Scrapbox: block Ctrl+I and Ctrl+T
// @namespace    http://tampermonkey.net/
// @version      1.1
// @description  Scrapbox で Ctrl+I / Ctrl+T の keydown イベント伝播を握りつぶす
// @author       kbwo
// @match        https://scrapbox.io/*
// @grant        none
// @run-at       document-start
// ==/UserScript==

(function () {
  "use strict";

  function handler(event) {
    if (!event.ctrlKey) {
      return;
    }
    const key = event.key.toLowerCase();
    if (key === "i" || key === "t") {
      event.stopImmediatePropagation();
      event.stopPropagation();
      event.preventDefault();
    }
  }

  window.addEventListener("keydown", handler, true);
  document.addEventListener("keydown", handler, true);
})();
