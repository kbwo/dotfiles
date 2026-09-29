// ==UserScript==
// @name         kbwo-blog-palette
// @namespace    http://tampermonkey.net
// @match        https://x.com/*
// @match        https://twitter.com/*
// @match        https://grok.com/*
// @run-at       document-start
// @description  Recolor X and Grok (light theme) with the blog.kbwo.dev palette
// @version      0.0.1
// @grant        none
// ==/UserScript==

(() => {
  "use strict";

  // blog.kbwo.dev の CSS 変数（--bg, --card, --ink ...）の値
  const P = {
    bg: [251, 238, 223],
    card: [255, 253, 245],
    ink: [76, 46, 31],
    body: [92, 64, 51],
    mute: [138, 106, 84],
    faint: [170, 140, 118],
    line: [236, 217, 194],
    lineDark: [222, 196, 166],
    pale: [243, 217, 168],
    code: [247, 235, 212],
    mark: [201, 162, 131],
    accent: [228, 98, 63],
    accentDark: [181, 80, 47],
    accentPale: [240, 170, 150],
    link: [110, 138, 243],
    linkHover: [63, 87, 177],
  };
  const rgb = (c, a = 1) => `rgba(${c.join(",")},${a})`;
  // HSL の "H S% L%" 形式（Tailwind 系の hsl(var(--x)) で使われる）
  const hsl = ([r, g, b]) => {
    [r, g, b] = [r / 255, g / 255, b / 255];
    const max = Math.max(r, g, b), min = Math.min(r, g, b), d = max - min;
    const l = (max + min) / 2;
    const s = d === 0 ? 0 : d / (1 - Math.abs(2 * l - 1));
    const h = d === 0 ? 0 : max === r ? ((g - b) / d) % 6 : max === g ? (b - r) / d + 2 : (r - g) / d + 4;
    return `${Math.round((h * 60 + 360) % 360)} ${Math.round(s * 100)}% ${Math.round(l * 100)}%`;
  };
  const dots = `radial-gradient(${rgb([232, 169, 58], 0.2)} 2px, transparent 2px) 0 0 / 16px 16px`;

  const addStyle = (css) => {
    const style = document.createElement("style");
    style.textContent = css;
    (document.head || document.documentElement).append(style);
  };

  if (location.hostname === "grok.com") {
    const hslVars = {
      bg: ["--background-color", "--surface-l1", "--surface-inset", "--muted", "--accent"],
      card: ["--surface-base", "--surface-elevated", "--thead-bg-color"],
      code: ["--surface-l2", "--surface-l1-hover"],
      line: ["--surface-l3", "--surface-l2-active", "--border", "--sidebar-border"],
      pale: ["--surface-l4"],
      ink: ["--fg-primary", "--primary", "--surface-invert", "--popover-foreground", "--card-foreground", "--secondary-foreground", "--accent-foreground"],
      mute: ["--fg-secondary", "--secondary", "--muted-foreground", "--sidebar-foreground"],
      faint: ["--fg-tertiary", "--fg-quaternary"],
      link: ["--fg-link"],
    };
    const colorVars = {
      "--background": rgb(P.bg),
      "--background-secondary": rgb(P.bg),
      "--card": rgb(P.card, 0.8),
      "--popover": rgb(P.card),
      "--input": rgb(P.card),
      "--input-hover": rgb(P.card),
      "--input-background": rgb(P.card),
      "--input-background-hover": rgb(P.card),
      "--input-button-background": rgb(P.card),
      "--input-button-background-hover": rgb(P.code),
      "--input-border": rgb(P.line),
      "--card-border": rgb(P.line),
      "--border-l1": rgb(P.ink, 0.08),
      "--border-l2": rgb(P.ink, 0.12),
      "--border-l3": rgb(P.ink, 0.18),
      "--button-filled": rgb(P.ink),
      "--button-filled-hover": rgb(P.body),
      "--button-ghost-hover": rgb(P.accent, 0.08),
      "--button-secondary-fill": rgb(P.ink, 0.05),
      "--highlight": rgb(P.accent, 0.25),
      "--link": rgb(P.link),
      "--link-hover": rgb(P.linkHover),
    };
    const decls = [
      ...Object.entries(hslVars).flatMap(([k, names]) => names.map((n) => `${n}: ${hsl(P[k])} !important;`)),
      ...Object.entries(colorVars).map(([n, v]) => `${n}: ${v} !important;`),
    ];
    // ponytail: light テーマのみ。dark テーマにも当てるなら html.dark 用の対応表を足す
    addStyle(`html.light { ${decls.join(" ")} } html.light body { background: ${dots}, ${rgb(P.bg)} !important; }`);
    return;
  }

  // X（light テーマ "Default"）の色 → blog の色。キーは X が使う "r,g,b"
  const X = {
    "255,255,255": P.card,
    "15,20,25": P.ink,
    "39,44,48": P.body,
    "55,67,77": P.body,
    "83,100,113": P.mute,
    "101,119,134": P.mute,
    "130,154,171": P.faint,
    "185,202,211": P.mark,
    "207,217,222": P.lineDark,
    "239,243,244": P.line,
    "229,234,236": P.pale,
    "247,249,249": P.code,
    "29,155,240": P.accent,
    "26,140,216": P.accentDark,
    "142,205,248": P.accentPale,
  };
  const recolor = (s) =>
    s.replace(/(rgba?\()\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)/g, (m, fn, r, g, b) => {
      const c = X[`${r},${g},${b}`];
      return c ? fn + c.join(", ") : m;
    });

  const fixRule = (rule) => {
    if (rule.style) {
      for (const p of rule.style) {
        const v = rule.style.getPropertyValue(p);
        const nv = recolor(v);
        if (nv !== v) rule.style.setProperty(p, nv, rule.style.getPropertyPriority(p));
      }
    }
    if (rule.cssRules) for (const r of rule.cssRules) fixRule(r);
  };
  const fixSheet = (sheet) => {
    try {
      for (const r of sheet.cssRules) fixRule(r);
    } catch {} // クロスオリジンの stylesheet は読めない
  };
  const fixInline = (el) => {
    const s = el.getAttribute("style");
    if (!s) return;
    const ns = recolor(s);
    if (ns !== s) el.setAttribute("style", ns);
  };

  // X（react-native-web）は insertRule で色付きのルールを後から足していく
  const insertRule = CSSStyleSheet.prototype.insertRule;
  CSSStyleSheet.prototype.insertRule = function (...args) {
    const i = insertRule.apply(this, args);
    try {
      fixRule(this.cssRules[i]);
    } catch {}
    return i;
  };

  new MutationObserver((muts) => {
    for (const m of muts) {
      if (m.type === "attributes") {
        fixInline(m.target);
        continue;
      }
      for (const n of m.addedNodes) {
        if (n.nodeType !== 1) continue;
        if (n.sheet) fixSheet(n.sheet);
        fixInline(n);
        n.querySelectorAll("[style]").forEach(fixInline);
      }
    }
  }).observe(document.documentElement, { childList: true, subtree: true, attributes: true, attributeFilter: ["style"] });

  for (const sheet of document.styleSheets) fixSheet(sheet);
  document.querySelectorAll("[style]").forEach(fixInline);
  addStyle(`body { background: ${dots}, ${rgb(P.bg)} !important; }`);
})();
