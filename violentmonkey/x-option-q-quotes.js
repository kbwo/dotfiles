// ==UserScript==
// @name         x-option-q-quotes
// @namespace    http://tampermonkey.net
// @match        https://x.com/*
// @match        https://twitter.com/*
// @run-at       document-start
// @description  Press Option+Q to navigate to current URL + /quotes (sorted by Recent)
// @version      0.0.2
// @grant        none
// ==/UserScript==

(() => {
  "use strict";

  document.addEventListener("keydown", (e) => {
    if (e.altKey && e.code === "KeyQ") {
      e.preventDefault();
      const url = new URL(location.href);
      const segments = url.pathname.split("/").filter(Boolean);
      if (segments[segments.length - 1] === "quotes") {
        return;
      }
      segments.push("quotes");
      url.pathname = "/" + segments.join("/");
      location.href = url.toString();
    }
  });

  const waitFor = (find, timeout = 10000) =>
    new Promise((resolve) => {
      const el = find();
      if (el) return resolve(el);
      const obs = new MutationObserver(() => {
        const el = find();
        if (el) { obs.disconnect(); resolve(el); }
      });
      obs.observe(document.documentElement, { childList: true, subtree: true });
      setTimeout(() => { obs.disconnect(); resolve(null); }, timeout);
    });

  if (location.pathname.endsWith("/quotes")) {
    (async () => {
      // 並び替えボタンは class が自動生成で不安定なので、スライダー型アイコンの path で特定する
      const sortButton = await waitFor(() =>
        [...document.querySelectorAll('button[aria-haspopup="menu"]')].find((b) =>
          b.querySelector('path[d^="M15 13c1.864"]'),
        ),
      );
      if (!sortButton) return;
      sortButton.click();
      const recent = await waitFor(() =>
        [...document.querySelectorAll('[role="menuitem"]')].find(
          (m) => m.textContent.trim() === "Recent",
        ),
      );
      recent?.click();
    })();
  }
})();
