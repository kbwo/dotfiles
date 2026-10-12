// ==UserScript==
// @name         copy-title-url
// @namespace    http://tampermonkey.net
// @match        *://*/*
// @run-at       document-start
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

  const removeYouTubeTimeParam = (urlObj) => {
    const h = urlObj.hostname;
    const isYouTube =
      h === "youtu.be" ||
      h === "youtube.com" ||
      h.endsWith(".youtube.com");
    if (isYouTube && urlObj.searchParams.has("t")) {
      urlObj.searchParams.delete("t");
    }
  };

  // Amazon の「シェア」ボタンと同じ API を叩いて https://amzn.asia/d/xxx 形式の短縮URLを得る。
  // 必要なトークンは商品ページの DOM にしか無いため、商品ページ以外では例外になる（呼び出し側でフォールバック）。
  const amazonShortUrl = async () => {
    const share = JSON.parse(
      document.querySelector("[data-ssf-share-icon]").dataset.ssfShareIcon
    );
    const res = await fetch(
      `https://data.amazon.co.jp/api/marketplaces/${share.shareDataAttributes.marketplaceId}/social-share/on-share`,
      {
        method: "POST",
        credentials: "include",
        headers: {
          Accept:
            'application/vnd.com.amazon.api+json; type="social-share.on-share/v1"',
          // 明示しないと fetch が ";charset=UTF-8" を付け、API が 415 を返す
          "Content-Type": "application/x-www-form-urlencoded",
          "x-api-csrf-token": share.shareAapiCsrfToken,
          "x-amzn-encrypted-slate-token": document.querySelector(
            'meta[name="encrypted-slate-token"]'
          ).content,
        },
        body: new URLSearchParams({
          longUrl: share.url,
          channel: JSON.stringify({ ref: "", label: "" }),
        }).toString(),
      }
    );
    return (await res.json()).entity.shortUrl.url;
  };

  // capture: true — YouTube 等は内側で stopPropagation するため、document のバブル段では届かない。
  // window のキャプチャで先に拾い、ショートカット時は伝播を止める。
  window.addEventListener(
    "keydown",
    (e) => {
      if (!e.ctrlKey || !e.altKey) return;
      const k = e.key.toLowerCase();
      const isC = k === "c" || e.code === "KeyC";
      const isS = k === "s" || e.code === "KeyS";
      const isD = k === "d" || e.code === "KeyD";
      if (!isC && !isS && !isD) return;

      e.preventDefault();
      e.stopImmediatePropagation();

      void (async () => {
        // Use .toot .text .content first line if available, otherwise document.title
        const tootContent = document.querySelector(".toot .text .content");
        const rawTitle = tootContent
          ? tootContent.innerText.split("\n")[0]
          : document.title;
        // delete `#xxx`, `[xxx]`
        const title = rawTitle
          .replace(/^\(\d+\)\s/, "") // "(数字) "を削除
          .replace(/#\S+/g, "") // "#以降"を削除
          .replace(/[\[\]]/g, "") // "[]"を削除
          .replace(/["'`]/g, "") // quotesを削除
          .replace(/\u200D/g, ""); // ZWJを削除
        const urlObj = new URL(document.URL);
        urlObj.hash = ""; // Remove hash fragment

        removeYouTubeTimeParam(urlObj);

        // Remove ?slide= parameter for speakerdeck.com
        if (
          urlObj.hostname.includes("speakerdeck.com") &&
          urlObj.searchParams.has("slide")
        ) {
          urlObj.searchParams.delete("slide");
        }

        let url = urlObj.toString();
        if (urlObj.hostname === "www.amazon.co.jp") {
          try {
            url = await amazonShortUrl();
          } catch (err) {
            console.error(err); // ページのURLにフォールバック
          }
        }
        if (isC) {
          copy(`[${title}](${url})`);
        } else if (isS) {
          copy(`${title} ${url}`);
        } else if (isD) {
          try {
            const existing = await navigator.clipboard.readText();
            const newContent = existing
              ? `${existing}\n${title} ${url}`
              : `${title} ${url}`;
            copy(newContent);
          } catch (err) {
            alert(`Failed to read clipboard: ${err}`);
          }
        }
      })();
    },
    true
  );
})();
