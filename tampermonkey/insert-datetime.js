// ==UserScript==
// @name         insert-datetime
// @namespace    http://tampermonkey.net
// @description
// @version 0.0.1
// @match        *://*/*
// @grant        none
// ==/UserScript==

  const getCurrentDateTime = () => {
    const now = new Date();
    const y = now.getFullYear();
    const m = now.getMonth() + 1;
    const d = now.getDate();
    const h = now.getHours();
    const mi = now.getMinutes();
    const s = now.getSeconds();
    const dStr = `${y}-${m < 10 ? '0' + m : m}-${d < 10 ? '0' + d : d} ${h < 10 ? '0' + h : h}:${mi < 10 ? '0' + mi : mi}:${s < 10 ? '0' + s : s}`;
    return dStr;
  }

(() => {
  'use strict';

  // insert current datetime to focusing input
  const f = (event) => {
    // alt+ctrl+d
    if (event.altKey && event.ctrlKey && event.keyCode === 68) {
      const input = document.activeElement;
      input.value = input.value + getCurrentDateTime();
      input.dispatchEvent(new Event('input', {bubbles: true, cancelable: true}));
      input.dispatchEvent(new Event('change', {bubbles: true, cancelable: true}));
    }
  }

  document.addEventListener('keydown', f, true);

})();
