// ==UserScript==
// @name         Scrapbox: block Ctrl+I
// @namespace    http://tampermonkey.net/
// @version      1.0
// @description  Scrapbox で Ctrl+I の keydown イベント伝播を握りつぶす
// @author       kbwo
// @match        https://scrapbox.io/*
// @grant        none
// @run-at       document-start
// ==/UserScript==

(function () {
  "use strict";

  function handler(event) {
    if (event.ctrlKey && (event.key === "i" || event.key === "I")) {
      event.stopImmediatePropagation();
      event.stopPropagation();
      event.preventDefault();
    }
  }

  window.addEventListener("keydown", handler, true);
  document.addEventListener("keydown", handler, true);
})();
