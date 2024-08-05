// ==UserScript==
// @name         cosense-key-disable
// @namespace    http://tampermonkey.net
// @match        https://scrapbox.io/*
// @description
// @version      0.0.1
// @grant        none
// ==/UserScript==

(() => {
  "use strict";

  const f = (eventName) => (event) => {
    if (event.ctrlKey && ["g"].includes(event.key.toLowerCase())) {
      event.cancelBubble = true;
      event.stopImmediatePropagation();
    }
  };
  ["keydown"].map((eventName) => {
    document.addEventListener(eventName, f(eventName), true);
  });
})();
