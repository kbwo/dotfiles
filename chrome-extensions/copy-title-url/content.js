(() => {
  "use strict";

  // ページの CSS の影響を受けないよう Shadow DOM に入れ、popover で top layer（ページのモーダルより手前）に出す
  let toastTimer;
  const toast = (title, detail, ok) => {
    document.getElementById("copy-title-url-toast")?.remove();
    clearTimeout(toastTimer);

    const host = document.createElement("div");
    host.id = "copy-title-url-toast";
    host.popover = "manual";
    host.style.cssText =
      "all:initial;position:fixed;inset:auto 24px 24px auto;margin:0;border:0;padding:0;background:transparent;overflow:visible;";
    const root = host.attachShadow({ mode: "closed" });
    root.innerHTML = `
      <style>
        .t {
          display: flex; gap: 10px; align-items: flex-start;
          max-width: 420px; padding: 12px 16px; border-radius: 10px;
          background: rgba(28, 28, 30, 0.92); color: #fff;
          box-shadow: 0 8px 24px rgba(0, 0, 0, 0.3);
          font: 13px/1.4 -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
          opacity: 0; transform: translateY(8px);
          transition: opacity 0.2s, transform 0.2s;
        }
        .t.show { opacity: 1; transform: none; }
        .icon { flex: none; font-weight: bold; color: ${ok ? "#34c759" : "#ff453a"}; }
        .title { font-weight: 600; }
        .detail {
          margin-top: 2px; color: rgba(255, 255, 255, 0.7);
          display: -webkit-box; -webkit-line-clamp: 3; -webkit-box-orient: vertical;
          overflow: hidden; word-break: break-all; white-space: pre-wrap;
        }
      </style>
      <div class="t"><span class="icon">${ok ? "✓" : "✕"}</span><div><div class="title"></div><div class="detail"></div></div></div>`;
    root.querySelector(".title").textContent = title;
    root.querySelector(".detail").textContent = detail;
    document.documentElement.append(host);
    host.showPopover();

    const box = root.querySelector(".t");
    requestAnimationFrame(() => box.classList.add("show"));
    toastTimer = setTimeout(() => {
      box.classList.remove("show");
      box.addEventListener("transitionend", () => host.remove(), { once: true });
    }, 2500);
  };

  const copy = async (text) => {
    try {
      // navigator.clipboard はページ側の制約（フォーカス・ユーザー操作・Permissions Policy）で
      // 拒否されることがあるため、拡張の offscreen document でコピーする（background.js 経由）
      if (!(await chrome.runtime.sendMessage(text))) {
        throw new Error("execCommand('copy') returned false");
      }
      toast("Copied to clipboard", text, true);
    } catch (e) {
      console.error(e);
      toast("Failed to copy", String(e), false);
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
            toast("Failed to read clipboard", String(err), false);
          }
        }
      })();
    },
    true
  );
})();
