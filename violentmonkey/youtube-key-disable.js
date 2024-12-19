// ==UserScript==
// @name         youtube-key-disable
// @namespace    http://tampermonkey.net
// @match        https://www.youtube.com/*
// @description
// @version      0.0.1
// @grant        none
// ==/UserScript==

(() => {
  "use strict";

  const f = (eventName) => (event) => {
    if (event.shiftKey && ["j", "k"].includes(event.key.toLowerCase())) {
      event.cancelBubble = true;
      event.stopImmediatePropagation();
    }
  };
  ["keydown"].map((eventName) => {
    document.addEventListener(eventName, f(eventName), true);
  });
})();
