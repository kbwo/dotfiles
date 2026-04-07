// ==UserScript==
// @name         strip-trailing-newlines-on-paste
// @namespace    http://tampermonkey.net
// @match        *://*/*
// @exclude      *://github.com/*
// @run-at       document-start
// @description  Remove trailing newlines from pasted text
// @version      0.0.1
// @grant        none
// ==/UserScript==

(() => {
  "use strict";

  document.addEventListener("paste", (e) => {
    const text = e.clipboardData.getData("text/plain");
    const trimmed = text
      .replace(/^[\r\n]+|[\r\n]+$/g, "")
      .replace(/(\r?\n){2,}/g, "\n\n");

    if (trimmed === text) return;

    e.preventDefault();

    const active = document.activeElement;
    if (
      active &&
      (active.tagName === "TEXTAREA" ||
        (active.tagName === "INPUT" && active.type === "text"))
    ) {
      const start = active.selectionStart;
      const end = active.selectionEnd;
      const value = active.value;
      active.value = value.slice(0, start) + trimmed + value.slice(end);
      active.selectionStart = active.selectionEnd = start + trimmed.length;
      active.dispatchEvent(new Event("input", { bubbles: true }));
    } else {
      document.execCommand("insertText", false, trimmed);
    }
  }, true);
})();
