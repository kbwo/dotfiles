// content.js から受け取った文字列を offscreen document に渡してコピーさせ、成否を返す
chrome.runtime.onMessage.addListener((msg, _sender, sendResponse) => {
  if (msg?.target === "offscreen") return;
  (async () => {
    if (!(await chrome.offscreen.hasDocument())) {
      await chrome.offscreen.createDocument({
        url: "offscreen.html",
        reasons: ["CLIPBOARD"],
        justification: "Copy page title and URL to the clipboard",
      });
    }
    sendResponse(await chrome.runtime.sendMessage({ target: "offscreen", text: msg }));
  })();
  return true; // sendResponse を非同期で呼ぶ
});
