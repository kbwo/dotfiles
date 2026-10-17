// offscreen document はフォーカスを持たず navigator.clipboard が使えないため execCommand('copy') を使う
chrome.runtime.onMessage.addListener((msg, _sender, sendResponse) => {
  if (msg?.target !== "offscreen") return;
  const t = document.getElementById("t");
  t.value = msg.text;
  t.select();
  sendResponse(document.execCommand("copy"));
});
