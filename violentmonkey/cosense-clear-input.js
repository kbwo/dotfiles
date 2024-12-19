// ==UserScript==
// @name         Cosense Clear Input Field
// @namespace    http://tampermonkey.net/
// @version      1.0
// @description  Clear specific input field on page load or SPA navigation
// @author       kbwo
// @icon         https://www.google.com/s2/favicons?sz=64&domain=scrapbox.io
// @match        https://scrapbox.io/*
// @grant        none
// ==/UserScript==

(function () {
    'use strict';

    // 対象の入力フィールドを特定するセレクタ
    const targetSelector = document.querySelector('form.search-form input[type="text"]');

    // 指定されたセレクタに一致する要素を空にする関数
    const clearInputField = () => {
        const inputField = document.querySelector(targetSelector);
        if (inputField) {
            inputField.value = '';
            console.log('Input field cleared:', inputField);
        }
    };

    // ページロード時に一度実行
    clearInputField();

    // MutationObserverを使ってDOM変更を監視
    const observer = new MutationObserver(() => {
        clearInputField();
    });

    // 監視対象の設定
    observer.observe(document.body, {
        childList: true,
        subtree: true,
    });

    // SPAでのナビゲーション変更に対応するため、pushStateやreplaceStateをフック
    const originalPushState = history.pushState;
    const originalReplaceState = history.replaceState;

    const handleHistoryChange = () => {
        setTimeout(clearInputField, 100); // 少し遅延を入れる
    };

    history.pushState = function () {
        originalPushState.apply(this, arguments);
        handleHistoryChange();
    };

    history.replaceState = function () {
        originalReplaceState.apply(this, arguments);
        handleHistoryChange();
    };

    window.addEventListener('popstate', handleHistoryChange);

})();
