// ==UserScript==
// @name         Overflow Y Hidden for Specific react-scroll-to-bottom Elements
// @namespace    http://tampermonkey.net/
// @version      1.1
// @description  Add overflow-y: hidden to elements with class starting with react-scroll-to-bottom--css- that contain child elements with the same prefix
// @author       kbwo
// @match        *://chatgpt.com/*
// @grant        none
// @run-at       document-end
// ==/UserScript==

(function () {
    'use strict';

    const CLASS_PREFIX = 'react-scroll-to-bottom--css-';

    // スタイルを適用する関数
    function applyOverflowHidden(element) {
        if (element && element.style) {
            element.style.overflowY = 'hidden';
        }
    }

    // 対象の親要素を見つけてスタイルを適用する関数
    function processElement(element) {
        if (!element.classList) return;

        // 親要素が指定のクラスプレフィックスを持っているかチェック
        const hasParentClass = Array.from(element.classList).some(cls => cls.startsWith(CLASS_PREFIX));
        if (!hasParentClass) return;

        // 子要素に指定のクラスプレフィックスを持つ要素が存在するかチェック
        const childWithPrefix = element.querySelector(`[class^="${CLASS_PREFIX}"], [class*=" ${CLASS_PREFIX}"]`);
        if (childWithPrefix) {
            applyOverflowHidden(element);
        }
    }

    // 既存の要素に対してスタイルを適用
    function applyToExistingElements() {
        // 親要素を選択
        const parentElements = document.querySelectorAll(`[class^="${CLASS_PREFIX}"], [class*=" ${CLASS_PREFIX}"]`);
        parentElements.forEach(processElement);
    }

    // 新しく追加された要素に対してスタイルを適用する
    function observeNewElements() {
        const observer = new MutationObserver((mutations) => {
            mutations.forEach((mutation) => {
                mutation.addedNodes.forEach((node) => {
                    if (node.nodeType === 1) { // ELEMENT_NODE
                        // 親要素に対してチェック
                        processElement(node);

                        // 子要素もチェック
                        const parentElements = node.querySelectorAll(`[class^="${CLASS_PREFIX}"], [class*=" ${CLASS_PREFIX}"]`);
                        parentElements.forEach(processElement);
                    }
                });
            });
        });

        observer.observe(document.body, { childList: true, subtree: true });
    }

    // 初期実行
    applyToExistingElements();
    // 監視開始
    observeNewElements();

})();
