// ==UserScript==
// @name         x-option-q-quotes
// @namespace    http://tampermonkey.net
// @match        https://x.com/*
// @match        https://twitter.com/*
// @run-at       document-start
// @description  Press Option+Q to navigate to current URL + /quotes
// @version      0.0.1
// @grant        none
// ==/UserScript==

(() => {
  "use strict";

  document.addEventListener("keydown", (e) => {
    if (e.altKey && e.code === "KeyQ") {
      e.preventDefault();
      const url = location.href.replace(/\/+$/, "");
      if (!url.endsWith("/quotes")) {
        location.href = url + "/quotes";
      }
    }
  });
})();
