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
      const url = new URL(location.href);
      const segments = url.pathname.split("/").filter(Boolean);
      if (segments[segments.length - 1] === "quotes") {
        return;
      }
      segments.push("quotes");
      url.pathname = "/" + segments.join("/");
      location.href = url.toString();
    }
  });
})();
