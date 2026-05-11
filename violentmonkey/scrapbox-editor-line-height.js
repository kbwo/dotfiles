// ==UserScript==
// @name         Scrapbox Editor Line Height
// @namespace    http://tampermonkey.net/
// @version      1.0
// @description  Set line-height: 1.2em on all spans inside #editor
// @author       You
// @match        https://scrapbox.io/*
// @grant        GM_addStyle
// ==/UserScript==

(function () {
    'use strict';

    GM_addStyle('#editor .code-block span { line-height: 1.2em; }');
})();
