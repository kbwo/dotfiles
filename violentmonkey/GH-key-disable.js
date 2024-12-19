// ==UserScript==
// @name         gh-key-disable
// @namespace    http://tampermonkey.net
// @match        https://github.com/*
// @icon         data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==
// @description
// @version      0.0.1
// @grant        none
// ==/UserScript==

(() => {
  "use strict";

  const f = (eventName) => (event) => {
    if (
      event.ctrlKey &&
      !e.altKey &&
      ["b", "c"].includes(event.key.toLowerCase())
    ) {
      event.cancelBubble = true;
      event.stopImmediatePropagation();
    }
  };
  ["keydown"].map((eventName) => {
    document.addEventListener(eventName, f(eventName), true);
  });
})();
