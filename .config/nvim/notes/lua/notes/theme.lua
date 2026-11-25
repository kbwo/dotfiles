-- The notes' colors: the card list's and the page's highlight groups, made from the
-- colorscheme in use so that they suit a dark and a light one alike, and a light
-- colorscheme while a local note or the local list is in front, so that local
-- (kept on this machine only) is never mistaken for remote.

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

-- catppuccin's colors for the flavour loaded now (catppuccin-latte while local is in front), or nil.
local function catppuccin_palette()
  local flavour = (vim.g.colors_name or ""):match("^catppuccin%-(%a+)$")
  local ok, palettes = pcall(require, "catppuccin.palettes")
  if not flavour or not ok then
    return nil
  end
  return palettes.get_palette(flavour)
end

local function palette()
  local c = catppuccin_palette()
  if c then
    return {
      bg = c.base,
      card = c.mantle,
      fg = c.text,
      dim = c.subtext0,
      bar = c.blue,
      warn = c.peach,
      heading = c.yellow,
      comment = c.overlay0,
      remote = c.peach,
      ["local"] = c.blue,
    }
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
      comment = t.syn.comment,
      remote = t.diag.warning,
      ["local"] = t.syn.fun,
    }
  end
  -- Another colorscheme: kanagawa wave's colors.
  return { bg = "#1f1f28", card = "#2a2a37", fg = "#dcd7ba", dim = "#c8c093", bar = "#7e9cd8", warn = "#ff9e3b", heading = "#e6c384", comment = "#727169", remote = "#ff9e3b", ["local"] = "#7e9cd8" }
end

function M.apply_highlights()
  local p = palette()
  local hl = function(name, opts)
    vim.api.nvim_set_hl(0, name, opts)
  end
  local badge = blend(p.dim, p.card, 0.4)
  hl("NotesCard", { fg = p.dim, bg = p.card })
  hl("NotesCardBar", { fg = p.bar, bg = p.card })
  hl("NotesCardTitle", { fg = p.fg, bg = p.card, bold = true })
  hl("NotesCardBadge", { fg = badge, bg = p.card })
  hl("NotesCardDue", { fg = p.warn, bg = p.card })
  -- A closed page: one step dimmer than an open one, on the same card.
  hl("NotesCardClosed", { fg = blend(p.dim, p.card, 0.3), bg = p.card })
  hl("NotesCardClosedTitle", { fg = blend(p.fg, p.card, 0.3), bg = p.card, bold = true })
  hl("NotesCardClosedBar", { fg = blend(p.bar, p.card, 0.45), bg = p.card })
  hl("NotesCardSelected", { fg = p.warn, bg = p.card, bold = true })
  hl("NotesHeading", { fg = p.heading, bold = true })
  hl("NotesHelp", { fg = p.comment })
  hl("NotesLabel", { fg = p.bg, bg = p.warn, bold = true })
  hl("NotesBandRemote", { fg = p.bg, bg = p.remote, bold = true })
  hl("NotesBandLocal", { fg = p.bg, bg = p["local"], bold = true })
end

-- ===== the page's notation (decorate.lua) =====

local function page_highlights()
  local link = function(name, to)
    vim.api.nvim_set_hl(0, name, { link = to, default = true })
  end
  link("NotesTitle", "Title")
  link("NotesTitleRule", "WinSeparator")
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
  link("NotesQuote", "@markup.quote")
  link("NotesPrefix", "Special")
  link("NotesBlockStart", "Special")
  link("NotesIndentDot", "Delimiter")
end

-- ===== a light colorscheme while local is in front =====

-- Light where remote is dark, so that the two cannot be mistaken at a glance.
M.LOCAL_COLORSCHEME = "catppuccin-latte"

local saved_colorscheme = nil -- the colorscheme to go back to, while local's is on
local warned = false

-- The name `:colorscheme` takes to load the one in use now again.
local function current_colorscheme()
  local name = vim.g.colors_name
  if name == "kanagawa" then
    local ok, kanagawa = pcall(require, "kanagawa")
    if ok and kanagawa._CURRENT_THEME then
      return "kanagawa-" .. kanagawa._CURRENT_THEME
    end
  end
  return name
end

--- Show local's colorscheme while `is_local`, and the one from before when not.
function M.set_local(is_local)
  if is_local and not saved_colorscheme then
    local before = current_colorscheme()
    if not pcall(vim.cmd.colorscheme, M.LOCAL_COLORSCHEME) then
      if not warned then
        warned = true
        vim.notify(("notes: 配色 %s がありません（:JetpackSync で入ります）"):format(M.LOCAL_COLORSCHEME), vim.log.levels.WARN)
      end
      return
    end
    saved_colorscheme = before
  elseif not is_local and saved_colorscheme then
    local back = saved_colorscheme
    saved_colorscheme = nil
    if back then
      pcall(vim.cmd.colorscheme, back)
    end
  end
end

function M.setup()
  M.apply_highlights()
  page_highlights()
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("notes_theme", { clear = true }),
    callback = function()
      M.apply_highlights()
      page_highlights()
    end,
  })
end

return M
