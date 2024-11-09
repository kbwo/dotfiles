// ==UserScript==
// @name         copy-title-url
// @namespace    http://tampermonkey.net
// @match        *://*/*
// @description
// @version      0.0.1
// @grant GM_setClipboard
// ==/UserScript==

(() => {
  "use strict";

  const copy = async (text) => {
    try {
      await GM.setClipboard(text, "text");
      alert("copied to clipboard");
    } catch (e) {
      console.error(e);
      alert("failed to copy");
    }
  };

  document.addEventListener("keydown", (e) => {
    // delete `#xxx`, `[xxx]`
    const title = document.title
      .replace(/^\(\d+\)\s/, "")
      .replace(/#.+/g, "")
      .replace(/[\[\]]/g, "");
    const url = document.URL;
    if (e.ctrlKey && e.altKey && (e.key === "c" || e.code === "KeyC")) {
      copy(`[${title}](${url})`);
    }
    if (e.ctrlKey && e.altKey && (e.key === "s" || e.code === "KeyS")) {
      copy(`${title} ${url}`);
    }
  });
})();
