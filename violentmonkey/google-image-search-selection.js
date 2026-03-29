// ==UserScript==
// @name         google-image-search-selection
// @namespace    http://tampermonkey.net
// @match        *://*/*
// @run-at       document-start
// @description  選択中の文字列を検索語に、Alt+Ctrl+I で新しいタブで Google 画像検索を開く
// @version      0.0.1
// ==/UserScript==

(() => {
  "use strict";

  window.addEventListener(
    "keydown",
    (e) => {
      if (!e.ctrlKey || !e.altKey) return;
      const k = e.key.toLowerCase();
      const isI = k === "i" || e.code === "KeyI";
      if (!isI) return;

      e.preventDefault();
      e.stopImmediatePropagation();

      const q = window.getSelection()?.toString().trim() ?? "";
      if (!q) {
        alert("検索する文字を選択してください");
        return;
      }

      const url = `https://www.google.com/search?tbm=isch&q=${encodeURIComponent(q)}`;
      window.open(url, "_blank", "noopener,noreferrer");
    },
    true
  );
})();
