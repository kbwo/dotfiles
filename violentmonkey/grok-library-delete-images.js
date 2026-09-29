// ==UserScript==
// @name         grok-library-delete-images
// @namespace    http://tampermonkey.net
// @match        https://grok.com/*
// @description  Add a button on grok.com/library that deletes every image item
// @version      0.0.1
// @grant        none
// ==/UserScript==

(() => {
  "use strict";

  const IMAGE = /\.(jpe?g|png|gif|webp|heic|avif)\b/i;
  const DELETE = /^(Delete|削除する|削除)$/;
  const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
  const waitFor = async (fn, timeout = 5000) => {
    for (const end = Date.now() + timeout; Date.now() < end; await sleep(100)) {
      const v = fn();
      if (v) return v;
    }
    return null;
  };

  // "Item actions" ボタンを 1 つだけ含む一番外側の要素をカードとみなす
  const cardOf = (btn) => {
    let c = btn;
    while (c.parentElement?.querySelectorAll('button[aria-label="Item actions"]').length === 1) c = c.parentElement;
    return c;
  };
  const nextImageCard = () =>
    [...document.querySelectorAll('button[aria-label="Item actions"]')]
      .map((btn) => ({ btn, card: cardOf(btn) }))
      .find(({ card }) => IMAGE.test(card.textContent));

  const deleteOne = async ({ btn, card }) => {
    card.scrollIntoView({ block: "center" });
    // Radix のメニューは click ではなく pointerdown で開く
    btn.dispatchEvent(new PointerEvent("pointerdown", { bubbles: true, button: 0, pointerType: "mouse" }));
    const item = await waitFor(() =>
      [...document.querySelectorAll('[role="menuitem"]')].find((e) => DELETE.test(e.textContent.trim())),
    );
    if (!item) throw new Error("Delete menu item not found");
    item.click();
    // 確認ダイアログが出る場合はその削除ボタンを押す
    const confirmBtn = await waitFor(
      () =>
        [...document.querySelectorAll('[role="alertdialog"] button, [role="dialog"] button')].find((e) =>
          DELETE.test(e.textContent.trim()),
        ),
      1500,
    );
    confirmBtn?.click();
    if (!(await waitFor(() => !card.isConnected))) throw new Error("Item was not removed");
  };

  const run = async (button) => {
    if (!confirm("Delete ALL images in the Grok library? This cannot be undone.")) return;
    let n = 0;
    try {
      for (;;) {
        let target = nextImageCard();
        if (!target) {
          // 無限スクロールで続きを読み込む
          window.scrollTo(0, document.body.scrollHeight);
          document.querySelector("main")?.scrollTo(0, 1e9);
          target = await waitFor(nextImageCard, 3000);
          if (!target) break;
        }
        await deleteOne(target);
        button.textContent = `Deleting… ${++n}`;
      }
      alert(`Deleted ${n} images.`);
    } catch (e) {
      alert(`Stopped after ${n} images: ${e.message}`);
    } finally {
      button.textContent = "Delete all images";
    }
  };

  const button = document.createElement("button");
  button.textContent = "Delete all images";
  button.style.cssText =
    "position:fixed;right:16px;bottom:16px;z-index:99999;padding:8px 12px;border-radius:8px;background:#c62828;color:#fff;font-weight:bold;cursor:pointer";
  button.onclick = () => run(button);
  document.body.append(button);
  // grok.com は SPA なので /library にいる間だけ表示する
  setInterval(() => {
    button.style.display = location.pathname.startsWith("/library") ? "" : "none";
  }, 500);
})();
