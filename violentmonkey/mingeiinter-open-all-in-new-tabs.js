// ==UserScript==
// @name         mingeiinter-open-all-in-new-tabs
// @namespace    http://tampermonkey.net
// @match        https://mingeiinter.net/posts/*
// @run-at       document-idle
// @description  各 .post-list（日付ごとの記事一覧）に「全ての記事を新しいタブで開く」ボタンを追加する（ミンゲイインターネット）
// @version      0.0.1
// @grant        GM_openInTab
// ==/UserScript==

(() => {
  "use strict";

  const BUTTON_LABEL = "全ての記事を新しいタブで開く";
  const BUTTON_CLASS = "mingeiinter-open-all-btn";

  function addButtons() {
    const lists = document.querySelectorAll("ul.post-list");

    for (const list of lists) {
      // すでにボタンを追加済みならスキップ（多重挿入防止）
      if (
        list.previousElementSibling &&
        list.previousElementSibling.classList.contains(BUTTON_CLASS)
      ) {
        continue;
      }

      const button = document.createElement("button");
      button.type = "button";
      button.textContent = BUTTON_LABEL;
      button.className = BUTTON_CLASS;
      button.style.cssText =
        "margin:0.5em 0;padding:0.2em 0.6em;font-size:0.9em;cursor:pointer;";

      button.addEventListener("click", () => {
        const links = list.querySelectorAll("li > p.title > a[href]");
        for (const link of links) {
          // window.open をループで呼ぶとブラウザのポップアップブロックに
          // よって最初の1件しか開かれないため、Tampermonkey/Violentmonkey が
          // 提供する GM_openInTab（拡張機能の権限でタブを開く API）を使う
          if (typeof GM_openInTab === "function") {
            GM_openInTab(link.href, { active: false, insert: true });
          } else {
            window.open(link.href, "_blank", "noopener,noreferrer");
          }
        }
      });

      list.parentElement.insertBefore(button, list);
    }
  }

  addButtons();

  // ポスト一覧が後から描画されるケースに備えて DOM の変化を監視する
  const observer = new MutationObserver(() => addButtons());
  observer.observe(document.body, { childList: true, subtree: true });
})();
