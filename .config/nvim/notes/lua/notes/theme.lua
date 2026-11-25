-- The notes' colors: the card list's and the page's highlight groups, made from the
-- colorscheme in use so that they suit a dark and a light one alike, and a light scheme
-- in the windows showing a local note or the local list, so that local (kept on this
-- machine only) is never mistaken for remote.

local M = {}

local function hex(n)
  return ("#%06x"):format(n)
end

-- `a` moved towards `b` by `t` (0..1), both "#rrggbb".
local function blend(a, b, t)
  local function ch(s, i)
    return tonumber(s:sub(i, i + 1), 16)
  end
  local out = 0
  for _, i in ipairs({ 2, 4, 6 }) do
    out = out * 256 + math.floor(ch(a, i) + (ch(b, i) - ch(a, i)) * t + 0.5)
  end
  return hex(out)
end

-- kanagawa's colors for the theme loaded now, or nil under another colorscheme.
local function kanagawa_theme()
  if vim.g.colors_name ~= "kanagawa" then
    return nil
  end
  local ok, kanagawa = pcall(require, "kanagawa")
  if not ok or not kanagawa._CURRENT_THEME then
    return nil
  end
  return require("kanagawa.colors").setup({ theme = kanagawa._CURRENT_THEME, colors = kanagawa.config.colors }).theme
end

-- The notes' colours from a catppuccin palette (latte for local's windows).
local function palette_of(c)
  return {
      bg = c.base,
      card = c.mantle,
      -- A card not closed: the ground towards the blue, so that local's cards are tinted too.
      live_card = blend(c.base, c.blue, 0.13),
      -- catppuccin's own cursor line (mantle lightened) is all but the ground's color.
      cursorline = c.surface1,
      fg = c.text,
      dim = c.subtext0,
      bar = c.blue,
      warn = c.peach,
      heading = c.yellow,
      heading_rule = c.sky,
      comment = c.overlay0,
      remote = c.peach,
      public = c.green,
      ["local"] = c.blue,
    }
end

-- The colorscheme in use: catppuccin's own flavour, kanagawa's theme, or kanagawa wave's colours.
local function palette()
  local flavour = (vim.g.colors_name or ""):match("^catppuccin%-(%a+)$")
  local ok, palettes = pcall(require, "catppuccin.palettes")
  if flavour and ok then
    return palette_of(palettes.get_palette(flavour))
  end
  local t = kanagawa_theme()
  if t then
    return {
      bg = t.ui.bg,
      card = t.ui.bg_p1,
      fg = t.ui.fg,
      dim = t.ui.fg_dim,
      bar = t.syn.fun,
      warn = t.diag.warning,
      heading = t.syn.identifier,
      heading_rule = t.syn.special1,
      comment = t.syn.comment,
      remote = t.diag.warning,
      public = t.syn.string,
      ["local"] = t.syn.fun,
    }
  end
  -- Another colorscheme: kanagawa wave's colors.
  return { bg = "#1f1f28", card = "#2a2a37", fg = "#dcd7ba", dim = "#c8c093", bar = "#7e9cd8", warn = "#ff9e3b", heading = "#e6c384", heading_rule = "#7fb4ca", comment = "#727169", remote = "#ff9e3b", ["local"] = "#7e9cd8", public = "#98bb6c" }
end

local page_highlights, build_local -- defined below

--- The notes' groups in namespace `ns` (0: everywhere), from palette `p`.
local function paint(ns, p)
  local hl = function(name, opts)
    vim.api.nvim_set_hl(ns, name, opts)
  end
  -- A card not closed stands out from the ground (13% towards the text), a closed one keeps
  -- the plain card's ground with its text one step dimmer, so the two part at a glance.
  local live = p.live_card or blend(p.bg, p.fg, 0.13)
  local badge = blend(p.dim, live, 0.4)
  hl("NotesCard", { fg = p.dim, bg = live })
  hl("NotesCardBar", { fg = p.bar, bg = live })
  hl("NotesCardTitle", { fg = p.fg, bg = live, bold = true })
  hl("NotesCardBadge", { fg = badge, bg = live })
  hl("NotesCardDue", { fg = p.warn, bg = live })
  hl("NotesCardClosed", { fg = blend(p.dim, p.card, 0.3), bg = p.card })
  hl("NotesCardClosedTitle", { fg = blend(p.fg, p.card, 0.3), bg = p.card, bold = true })
  hl("NotesCardClosedBar", { fg = blend(p.bar, p.card, 0.45), bg = p.card })
  hl("NotesCardSelected", { fg = p.warn, bg = live, bold = true })
  -- A published page: its title rows filled green, closed or not, and "public" a green label.
  hl("NotesCardPublicTitle", { fg = p.bg, bg = p.public, bold = true })
  hl("NotesCardPublicLabel", { fg = p.bg, bg = p.public, bold = true })
  if p.cursorline then
    hl("CursorLine", { bg = p.cursorline })
  end
  hl("NotesHeading", { fg = p.heading, bold = true })
  hl("NotesHelp", { fg = p.dim })
  hl("NotesHelpKey", { fg = p.warn, bold = true })

  -- A page's marks and blocks (decorate.lua), after stderr-blog's src/styles/cosense-editor.css.
  -- date:… / closed: as a label: the accent on a pale of it, filled once its day has come (.cs-page-mark).
  hl("NotesMark", { fg = p.warn, bold = true })
  hl("NotesMarkLabel", { fg = p.warn, bg = blend(p.warn, p.bg, 0.8), bold = true })
  hl("NotesMarkDue", { fg = p.bg, bg = p.warn, bold = true })
  -- A check line: the box in the accent, a checked line's text fainter, not struck through (.cs-check, .cs-checked).
  hl("NotesCheckBox", { fg = p.warn, bold = true })
  hl("NotesCheckMark", { fg = p.warn })
  hl("NotesChecked", { fg = blend(p.fg, p.bg, 0.45) })
  hl("NotesCheckTime", { fg = p.comment })
  -- A quote: a grey bar, its text quieter than the page's (.cs-quote-line, .cs-quote).
  hl("NotesQuote", { fg = p.dim })
  hl("NotesQuoteBar", { fg = p.comment })
  -- The rule at a page's title, in the accent (kanagawa's WinSeparator, used before, is the ground's colour, all but unseen).
  hl("NotesTitleRule", { fg = p.warn })
  -- The rule under a heading, a light blue of its own, apart from the title's accent and the heading's yellow.
  hl("NotesHeadingRule", { fg = p.heading_rule })
  -- An item's dot (and a quote's or numbered line's dash) in the accent, to be found at a glance.
  hl("NotesIndentDot", { fg = p.warn })
  -- A code block and inline code on a ground tinted towards the blue (.cs-code-line, .cs-code).
  hl("NotesCodeGround", { bg = blend(p.bg, p.bar, 0.22) })
  hl("NotesCodeHeader", { fg = p.dim, bold = true })
  hl("NotesLabel", { fg = p.bg, bg = p.warn, bold = true })
  hl("NotesBandRemote", { fg = p.bg, bg = p.remote, bold = true })
  hl("NotesBandLocal", { fg = p.bg, bg = p["local"], bold = true })
end

--- The notes' colours for the colorscheme in use, and local's windows' for latte.
function M.apply_highlights()
  paint(0, palette())
  page_highlights(0)
  build_local()
end

-- ===== the page's notation (decorate.lua) =====

page_highlights = function(ns)
  local link = function(name, to)
    vim.api.nvim_set_hl(ns, name, { link = to, default = true })
  end
  link("NotesTitle", "Title")
  link("NotesLink", "Function")
  link("NotesLinkMissing", "DiagnosticWarn")
  link("NotesUrl", "@markup.link.url")
  link("NotesImage", "@markup.link.url")
  -- A heading ([** ] and deeper) is NotesHeading, the list's day headings' yellow above.
  link("NotesStrong", "@markup.strong")
  link("NotesItalic", "@markup.italic")
  link("NotesStrike", "@markup.strikethrough")
  link("NotesUnderline", "@markup.underline")
  link("NotesCode", "@markup.raw")
  link("NotesPrefix", "Special")
  link("NotesBlockStart", "Special")
end

-- ===== local's windows in a light scheme =====

-- A window showing a local page or the local list is drawn in catppuccin's latte, light
-- where remote is dark, through a highlight namespace of its own (nvim_win_set_hl_ns), so
-- that local and remote side by side keep their own colours and nothing else changes when
-- one is entered. The colorscheme itself stays as it is.
M.LOCAL_NS = vim.api.nvim_create_namespace("notes_local_colours")

--- latte's highlight groups, as catppuccin's own compiler writes them
--- (catppuccin/lib/compiler.lua `compile`), or nil without catppuccin.
function M.local_groups()
  local ok, mapper = pcall(require, "catppuccin.lib.mapper")
  if not ok then
    return nil
  end
  local theme = mapper.apply("latte")
  local groups = vim.tbl_deep_extend("keep", theme.custom_highlights, theme.integrations, theme.syntax, theme.editor)
  for _, spec in pairs(groups) do
    for _, style in ipairs(spec.style or {}) do
      spec[style] = true
    end
    spec.style = nil
  end
  return groups
end

--- The notes' colours from latte's palette, or nil without catppuccin.
function M.local_palette()
  local ok, palettes = pcall(require, "catppuccin.palettes")
  return ok and palette_of(palettes.get_palette("latte")) or nil
end

local has_local = false

build_local = function()
  local groups, p = M.local_groups(), M.local_palette()
  has_local = groups ~= nil and p ~= nil
  if not has_local then
    return
  end
  for name, spec in pairs(groups) do
    vim.api.nvim_set_hl(M.LOCAL_NS, name, spec)
  end
  page_highlights(M.LOCAL_NS)
  paint(M.LOCAL_NS, p)
  -- The cursor's box is one for the whole screen ('guicursor' is global): latte's text colour
  -- with its ground on it, used only while the cursor is in a local window (M.refresh). The
  -- terminal's own, near white, vanishes on latte's ground.
  vim.api.nvim_set_hl(0, "NotesCursor", { fg = p.bg, bg = p.fg })
end

local warned = false
local base_guicursor = nil -- 'guicursor' without local's cursor colour, while that is added

--- Whether window `win` shows local: a local page, or the list on its local tab.
local function shows_local(win)
  local buf = vim.api.nvim_win_get_buf(win)
  if vim.bo[buf].filetype == "notes-list" then
    return require("notes.list").shows_local(buf)
  end
  return vim.bo[buf].buftype == "" and require("notes.page").is_local(buf)
end

--- Give every window its colours (latte for local's, the colorscheme's for the rest) and the
--- cursor its box colour for the window it is in.
function M.refresh()
  local any_local = false
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local is_local = has_local and shows_local(win)
    any_local = any_local or is_local
    vim.api.nvim_win_set_hl_ns(win, is_local and M.LOCAL_NS or 0)
  end
  if not has_local and not warned and vim.iter(vim.api.nvim_list_wins()):any(shows_local) then
    warned = true
    vim.notify("notes: 配色 catppuccin がありません（:JetpackSync で入ります）", vim.log.levels.WARN)
  end
  local in_local = has_local and shows_local(vim.api.nvim_get_current_win())
  if in_local and not base_guicursor then
    base_guicursor = vim.o.guicursor
    vim.o.guicursor = base_guicursor .. ",a:NotesCursor"
  elseif not in_local and base_guicursor then
    vim.o.guicursor = base_guicursor
    base_guicursor = nil
  end
end

function M.setup()
  M.apply_highlights()
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("notes_theme", { clear = true }),
    callback = M.apply_highlights,
  })
  vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter", "BufEnter", "WinClosed" }, {
    group = vim.api.nvim_create_augroup("notes_theme_windows", { clear = true }),
    callback = function()
      vim.schedule(M.refresh) -- after the window has its buffer, and a closed one is gone
    end,
  })
end

return M
