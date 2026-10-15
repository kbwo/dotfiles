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
        // window.open をループで呼ぶとブラウザのポップアップブロックに
        // よって最初の1件しか開かれないため、background の chrome.tabs.create
        // （拡張機能の権限でタブを開く API）に任せる
        chrome.runtime.sendMessage([...links].map((link) => link.href));
      });

      list.parentElement.insertBefore(button, list);
    }
  }

  addButtons();

  // ポスト一覧が後から描画されるケースに備えて DOM の変化を監視する
  const observer = new MutationObserver(() => addButtons());
  observer.observe(document.body, { childList: true, subtree: true });
})();
