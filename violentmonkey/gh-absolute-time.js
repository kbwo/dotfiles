// ==UserScript==
// @name         gh-absolute-time
// @namespace    http://tampermonkey.net
// @match        https://github.com/*
// @icon         data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==
// @description  Show <relative-time> as absolute datetime
// @run-at       document-end
// @version      0.0.1
// ==/UserScript==

(() => {
    "use strict";

    // <relative-time> (github/relative-time-element) re-renders itself when these attributes change.
    // sv-SE locale formats as "YYYY-MM-DD HH:mm".
    const attrs = {
        format: "datetime",
        prefix: "",
        lang: "sv-SE",
        "hour-cycle": "h23",
        year: "numeric",
        month: "2-digit",
        day: "2-digit",
        hour: "2-digit",
        minute: "2-digit",
    };

    const apply = () => {
        for (const el of document.querySelectorAll('relative-time:not([format="datetime"])')) {
            for (const [k, v] of Object.entries(attrs)) el.setAttribute(k, v);
        }
    };

    apply();
    // ponytail: rescans the whole document per mutation batch; scope to added nodes if it gets slow
    new MutationObserver(apply).observe(document.body, {
        childList: true,
        subtree: true,
        attributes: true,
        attributeFilter: ["format"],
    });
})();
