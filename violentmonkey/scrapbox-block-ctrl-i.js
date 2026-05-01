// ==UserScript==
// @name         Scrapbox: block Ctrl+I, Ctrl+T, and Cmd+F
// @namespace    http://tampermonkey.net/
// @version      1.2
// @description  Scrapbox で Ctrl+I / Ctrl+T / Cmd+F の keydown イベント伝播を握りつぶす
// @author       kbwo
// @match        https://scrapbox.io/*
// @grant        none
// @run-at       document-start
// ==/UserScript==

(function () {
  "use strict";

  function handler(event) {
    const key = event.key.toLowerCase();
    if (event.ctrlKey && (key === "i" || key === "t")) {
      event.stopImmediatePropagation();
      event.stopPropagation();
      event.preventDefault();
    }
    if (event.metaKey && key === "f") {
      event.stopImmediatePropagation();
      event.stopPropagation();
      event.preventDefault();
    }
  }

  window.addEventListener("keydown", handler, true);
  document.addEventListener("keydown", handler, true);
})();
