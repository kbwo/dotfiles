// ==UserScript==
// @name         esa-style
// @namespace    http://tampermonkey.net
// @match        https://*.esa.io/*
// @icon         data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==
// @description
// @version      0.0.1
// @grant        GM_addStyle
// ==/UserScript==

(() => {
  "use strict";

  GM_addStyle(`
    .user-theme--dark .highlight code .err,
    .user-theme--dark .highlight code .nt {
        background-color: transparent;
        color: #F7768E;
    }
    `);
})();
