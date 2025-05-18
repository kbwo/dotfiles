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
    .flex.h-full.flex-col.overflow-y-auto {
        position: relative;
        bottom: 25px;
    }
    `);
})();
