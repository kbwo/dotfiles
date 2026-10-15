// GM_openInTab(url, { active: false, insert: true }) 相当: 現在のタブの直後に、背景タブとして順番に開く
chrome.runtime.onMessage.addListener((urls, sender) => {
  urls.forEach((url, i) => {
    chrome.tabs.create({ url, active: false, index: sender.tab.index + 1 + i });
  });
});
