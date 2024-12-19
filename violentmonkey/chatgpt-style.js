// ==UserScript==
// @name         chatgpt-style
// @namespace    http://tampermonkey.net
// @description
// @version 0.0.1
// @match        *://chatgpt.com/*
// @grant        GM_addStyle
// ==/UserScript==

(() => {
    "use strict";

    GM_addStyle(`
    .relative.flex.h-full.max-w-full.flex-1.flex-col.overflow-hidden {
        min-width: 100%;
    }
    `);
})();
