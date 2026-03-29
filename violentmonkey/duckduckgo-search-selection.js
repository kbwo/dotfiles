// ==UserScript==
// @name         duckduckgo-search-selection
// @namespace    http://tampermonkey.net
// @match        *://*/*
// @run-at       document-start
// @description  選択中の文字列を検索語に、Alt+Ctrl+K で新しいタブで DuckDuckGo 検索を開く
// @version      0.0.1
// ==/UserScript==

(() => {
  "use strict";

  window.addEventListener(
    "keydown",
    (e) => {
      if (!e.ctrlKey || !e.altKey) return;
      const k = e.key.toLowerCase();
      const isK = k === "k" || e.code === "KeyK";
      if (!isK) return;

      e.preventDefault();
      e.stopImmediatePropagation();

      const q = window.getSelection()?.toString().trim() ?? "";
      if (!q) {
        alert("検索する文字を選択してください");
        return;
      }

      const url = `https://duckduckgo.com/?q=${encodeURIComponent(q)}`;
      window.open(url, "_blank", "noopener,noreferrer");
    },
    true
  );
})();
