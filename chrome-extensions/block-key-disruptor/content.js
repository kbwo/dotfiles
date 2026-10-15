// Runs in the page's MAIN world so it can patch the page's own addEventListener.
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
        ].includes(type) && _listener
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

          // Handle both function and object with handleEvent
          if (typeof _listener === 'function') {
            return _listener(event);
          } else if (_listener && typeof _listener.handleEvent === 'function') {
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
