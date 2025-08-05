// ==UserScript==
// @name         Block Key Disruptor
// @namespace    http://tampermonkey.net/
// @version      1.1
// @description  Remove all keydown event listeners set by the website on both window and document objects
// @author       kbwo
// @match        https://chatgpt.com/*
// @match        https://claude.ai/*
// @match        https://app.devin.ai/*
// @match        https://*.slack.com/*
// @grant        none
// @run-at       document-start
// ==/UserScript==

(function () {
  "use strict";

  function overrideEventTarget(target) {
    const originalAddEventListener = target.addEventListener;
    target.addEventListener = function (type, _listener, options) {
      if (
        [
          "keypress",
          "keydown",
          "keyup",
        ].includes(type)
      ) {
        const listener = (event) => {
          if (
            event.key === "J" ||
            event.key === "K" ||
            event.key === "g" ||
            event.key === "G" ||
            event.ctrlKey
          ) {
            return;
          }

          return _listener(event);
        };
        return originalAddEventListener.call(this, type, listener, options);
      }


      return originalAddEventListener.call(this, type, _listener, options);
    };
  }

  overrideEventTarget(window);
  overrideEventTarget(document);
})();
