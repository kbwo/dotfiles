// ==UserScript==
// @name         gh-remove-queryparam
// @namespace    http://tampermonkey.net
// @match        https://github.com/*
// @icon         data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==
// @description
// @version      0.0.1
// @grant        none
// ==/UserScript==

(() => {
  'use strict';
  const url = new URL(location.href);
  if (url.searchParams.get('tab') === 'readme-ov-file') {
    url.searchParams.delete('tab')
    history.replaceState(null, null, url.href);
  }
})();
