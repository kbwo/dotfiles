// ==UserScript==
// @name         gh-hide-whitespace
// @namespace    http://tampermonkey.net
// @match        https://github.com/*/*/pull/*/files*
// @icon         data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==
// @description
// @run-at       document-end
// @version      0.0.1
// ==/UserScript==

(() => {
    "use strict";

    const url = new URL(location.href);
    const w = url.searchParams.get("w");
    if (w === "1") {
        return;
    }
    url.searchParams.set("w", "1");
    location.href = url.href;
})();
