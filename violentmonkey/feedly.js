// ==UserScript==
// @name         Disable Site Shortcut Keys
// @namespace    https://feedly.com/
// @version      1.0.0
// @description  Web サイトが定義するショートカットキーを無効化します。
// @author       kbwo
// @match        *://feedly.com/*
// @run-at       document-start    // ココ重要！ページより先に実行
// @grant        none
// ==/UserScript==

(() => {
  "use strict";

  const KEY_EVENTS = ["keydown", "keypress", "keyup"];

  const origAdd = EventTarget.prototype.addEventListener;

  // 「キー系イベントなら何もせず return」で無効化
  EventTarget.prototype.addEventListener = function (type, listener, opts) {
    if (KEY_EVENTS.includes(type)) {
      // console.debug(`[Tampermonkey] blocked addEventListener(${type})`);
      return;
    }
    return origAdd.call(this, type, listener, opts);
  };

  // もしサイトが inline handler を使っていた場合に備えて一度掃除
  for (const t of KEY_EVENTS) {
    window[`on${t}`] = null;
    document[`on${t}`] = null;
  }
})();
