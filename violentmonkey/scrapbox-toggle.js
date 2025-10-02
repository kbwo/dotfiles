// ==UserScript==
// @name         Scrapbox Toggle
// @namespace    http://tampermonkey.net/
// @version      1.0
// @description  Toggle between /kbwo and /kbwo-s with Alt+H
// @author       You
// @match        https://scrapbox.io/*
// @grant        none
// ==/UserScript==

(function () {
    'use strict';

    document.addEventListener('keydown', function (e) {
        if (e.altKey && e.key === 'h') {
            e.preventDefault();

            const currentPath = window.location.pathname;
            const pathParts = currentPath.split('/');
            if (!["kbwo", "kbwo-s"].includes(currentPath.replace(/\//g, ""))) {
                window.location.pathname = pathParts[1];
            } else if (pathParts[1] === 'kbwo-s') {
                window.location.pathname = "/kbwo";
            } else if (pathParts[1] === 'kbwo') {
                window.location.pathname = "/kbwo-s";
            } else {
                return; // Do nothing if not on kbwo or kbwo-s
            }
        }
    });
})();