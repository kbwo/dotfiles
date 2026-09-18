// ==UserScript==
// @name         ctrl-bracket-to-escape
// @namespace    http://tampermonkey.net
// @match        *://*/*
// @run-at       document-start
// @description  Map Ctrl+[ to Escape key
// @version      0.0.1
// @grant        none
// ==/UserScript==

(() => {
  "use strict";

  document.addEventListener("keydown", (e) => {
    if (e.ctrlKey && e.key === "[") {
      e.preventDefault();
      e.stopPropagation();

      const esc = new KeyboardEvent("keydown", {
        key: "Escape",
        code: "Escape",
        keyCode: 27,
        which: 27,
        bubbles: true,
        cancelable: true,
      });
      e.target.dispatchEvent(esc);
    }
  }, true);
})();
