// ==UserScript==
// @name         copy-title-url
// @namespace    http://tampermonkey.net
// @match        *://*/*
// @description
// @version      0.0.1
// @grant        none
// ==/UserScript==

(() => {
  "use strict";

  const copy = (text) => {
    window.navigator.clipboard
      .writeText(text)
      .then(() => {
        alert("copied to clipboard");
      })
      .catch((e) => {
        console.error(e);
        alert("failed to copy");
      });
  };

  document.addEventListener("keydown", (e) => {
    // delete `#xxx`, `[xxx]`
    const title = document.title
      .replace(/^\(\d+\)\s/, "")
      .replace(/#.+/g, "")
      .replace(/[\[\]]/g, "");
    const url = document.URL;
    if (e.ctrlKey && e.altKey && (e.key === "c" || e.code === "KeyC")) {
      copy(`${title}\n${url}`);
    }
    if (e.ctrlKey && e.altKey && (e.key === "s" || e.code === "KeyS")) {
      copy(`${title} ${url}`);
    }
  });
})();
