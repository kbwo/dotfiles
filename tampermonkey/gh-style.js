// ==UserScript==
// @name         gh-style
// @namespace    http://tampermonkey.net
// @match        https://github.com/*
// @icon         data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==
// @description
// @version      0.0.1
// @grant        GM_addStyle
// ==/UserScript==

(() => {
  'use strict';

  GM_addStyle(`
    pre {
      white-space: pre-wrap;
    }
    .feed-left-sidebar {
      display: none;
    }
    .feed-right-sidebar {
      display: none;
    }
    `);
})();
