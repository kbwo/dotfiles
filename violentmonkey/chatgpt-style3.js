// ==UserScript==
// @name         Prevent disturbing PageUp or PageDown
// @namespace    http://tampermonkey.net/
// @version      1.1
// @author       kbwo
// @match        *://chatgpt.com/*
// @grant        none
// @run-at       document-end
// ==/UserScript==

(function () {
    'use strict';

    let found = false;

    function findAndModifyElement() {
        if (found) return;

        const elements = document.querySelectorAll('div[style*="width: 0px"]');
        if (elements.length > 0) {
            elements.forEach(element => {
                element.style.display = 'none';
            });
            found = true;
            clearInterval(intervalId);
            console.log('Found and modified elements with width:0px');
        }
    }

    const intervalId = setInterval(findAndModifyElement, 500);
})();
