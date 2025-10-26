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
      await GM_setClipboard(text, "text");
      alert("copied to clipboard");
    } catch (e) {
      console.error(e);
      alert("failed to copy");
    }
  };

  document.addEventListener("keydown", async (e) => {
    // delete `#xxx`, `[xxx]`
    const title = document.title
      .replace(/^\(\d+\)\s/, "")      // "(数字) "を削除
      .replace(/#\S+/g, "")            // "#以降"を削除
      .replace(/[\[\]]/g, "")         // "[]"を削除
      .replace(/\u200D/g, "");        // ZWJを削除
    const urlObj = new URL(document.URL);
    urlObj.hash = ''; // Remove hash fragment
    
    // Remove ?slide= parameter for speakerdeck.com
    if (urlObj.hostname.includes('speakerdeck.com') && urlObj.searchParams.has('slide')) {
      urlObj.searchParams.delete('slide');
    }
    
    const url = urlObj.toString();
    if (e.ctrlKey && e.altKey && (e.key === "c" || e.code === "KeyC")) {
      copy(`[${title}](${url})`);
    }
    if (e.ctrlKey && e.altKey && (e.key === "s" || e.code === "KeyS")) {
      copy(`${title} ${url}`);
    }
    // Ctrl+Alt+D: append to existing clipboard
    if (e.ctrlKey && e.altKey && (e.key === "d" || e.code === "KeyD")) {
      try {
        // Use navigator.clipboard API to read existing content
        const existing = await navigator.clipboard.readText();
        const newContent = existing ? `${existing}\n${title} ${url}` : `${title} ${url}`;
        copy(newContent);
      } catch (err) {
        // If reading clipboard fails (e.g., permission denied), just copy the new content
        alert('Failed to read clipboard:', err);
      }
    }
  });
})();
