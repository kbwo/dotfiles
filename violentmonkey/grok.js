// ==UserScript==
// @name        Grok Button Highlighter
// @namespace   Violentmonkey Scripts
// @match       *://*.grok.com/*
// @grant       none
// @version     1.0
// @author      -
// @description Highlights Grok buttons when pressed
// ==/UserScript==

(function () {
  "use strict";

  // Apply styles to buttons with aria-pressed="true"
  function styleButtons() {
    const pressedButtons = document.querySelectorAll(
      'button[aria-pressed="true"]',
    );
    pressedButtons.forEach((button) => {
      button.style.backgroundColor = "green";
    });

    const unpressedButtons = document.querySelectorAll(
      'button[aria-pressed="false"]',
    );
    unpressedButtons.forEach((button) => {
      button.style.backgroundColor = "";
    });
  }

  // Create a mutation observer to watch for DOM changes
  const observer = new MutationObserver((mutations) => {
    styleButtons();
  });

  // Start observing the document with the configured parameters
  observer.observe(document.body, {
    attributes: true,
    childList: true,
    subtree: true,
    attributeFilter: ["aria-pressed"],
  });

  // Initial styling
  styleButtons();
})();
