// ==UserScript==
// @name         Scrapbox Editor Line Height
// @namespace    http://tampermonkey.net/
// @version      1.0
// @description  Set line-height: 1.2em on all spans inside #editor
// @author       You
// @match        https://scrapbox.io/*
// @grant        none
// ==/UserScript==

(function () {
    'use strict';

    const style = document.createElement('style');
    style.textContent = '#editor span { line-height: 1.2em; }';
    document.head.appendChild(style);
})();
