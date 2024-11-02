// ==UserScript==
// @name         ChatGPT Remove All Key Event Listeners (Window & Document)
// @namespace    http://tampermonkey.net/
// @version      1.1
// @description  Remove all keydown event listeners set by the website on both window and document objects
// @author       kbwo
// @match        https://chatgpt.com/*
// @grant        none
// @run-at       document-start
// ==/UserScript==

(function () {
  "use strict";

  function overrideEventTarget(target) {
    const originalAddEventListener = target.addEventListener;
    target.addEventListener = function (type, listener, options) {
      if (
        [
          "keypress",
          "keydown",
          "keyup",
        ].includes(type)
      ) {
        return;
      }

      return originalAddEventListener.call(this, type, listener, options);
    };
  }

  overrideEventTarget(window);
  overrideEventTarget(document);
})();
