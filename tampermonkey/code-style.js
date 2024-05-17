// ==UserScript==
// @name         code-style
// @namespace    http://tampermonkey.net
// @description
// @version 0.0.1
// @match        *://*/*
// @grant        GM_addStyle
// ==/UserScript==

(() => {
  "use strict";

  GM_addStyle(`
    pre, code {
      white-space: pre-wrap !important;
    }
    `);
})();
