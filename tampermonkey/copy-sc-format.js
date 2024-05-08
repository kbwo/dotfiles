// ==UserScript==
// @name         copy-title-url
// @namespace    http://tampermonkey.net
// @match        *://*/*
// @description
// @version      0.0.1
// @grant        none
// ==/UserScript==

(() => {
  'use strict';

  document.addEventListener('keydown', (e) => {
    if (e.ctrlKey && e.altKey && (e.key === 'c' || e.code === 'KeyC')) {
      const title = document.title;
      const url = document.URL;
      window.navigator.clipboard.writeText(`${title}\n${url}`).then(() => {
        alert('copied to clipboard');
      }).catch((e) => {
        console.error(e)
        alert('failed to copy');
      });
    }
  })

})();
