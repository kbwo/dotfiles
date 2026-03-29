// ==UserScript==
// @name         Scrapbox: disable shortcuts except E
// @namespace    http://tampermonkey.net/
// @version      1.0
// @description  Scrapbox の key 系リスナーへは「e を押すショートカット」だけ通し、それ以外は無視する
// @author       kbwo
// @match        https://scrapbox.io/*
// @grant        none
// @run-at       document-start
// ==/UserScript==

(function () {
  "use strict";

  function isShortcutUsingE(event) {
    return event.key === "e" || event.key === "E";
  }

  function overrideEventTarget(target) {
    const originalAddEventListener = target.addEventListener;
    target.addEventListener = function (type, _listener, options) {
      if (
        ["keypress", "keydown", "keyup"].includes(type) && _listener
      ) {
        const listener = (event) => {
          if (!isShortcutUsingE(event)) {
            return;
          }

          if (typeof _listener === "function") {
            return _listener(event);
          }
          if (_listener && typeof _listener.handleEvent === "function") {
            return _listener.handleEvent(event);
          }
        };
        return originalAddEventListener.call(this, type, listener, options);
      }

      return originalAddEventListener.call(this, type, _listener, options);
    };
  }

  overrideEventTarget(window);
  overrideEventTarget(document);
})();
