-- The notes' colors: the card list's and the page's highlight groups, made from the
-- colorscheme in use so that they suit a dark and a light one alike, and a ground of
-- another color while a local note or the local list is in front, so that local
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

local function palette()
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

-- ===== local's ground =====

-- The ground while local is in front: wave's own colors on a deep blue-green, as far
-- from the remote ground's bluish grey as a dark ground goes.
local LOCAL_BG = "#16302e"
-- The groups that make up a window's ground: the text's, the gutter's and the part
-- below the last line. Floating windows and the status line keep their own.
local GROUND = { "Normal", "NormalNC", "LineNr", "CursorLineNr", "SignColumn", "FoldColumn", "EndOfBuffer" }

local showing_local = false
local saved = {} -- group -> its definition before local's ground was put on

local function put_local_ground()
  saved = {}
  for _, name in ipairs(GROUND) do
    local def = vim.api.nvim_get_hl(0, { name = name, link = false })
    saved[name] = def
    local new = vim.tbl_extend("force", def, { bg = LOCAL_BG })
    if name == "EndOfBuffer" then
      new.fg = LOCAL_BG -- kanagawa hides the ~ by drawing them in the ground's color
    end
    vim.api.nvim_set_hl(0, name, new)
  end
end

local function take_local_ground_off()
  for name, def in pairs(saved) do
    vim.api.nvim_set_hl(0, name, def)
  end
  saved = {}
end

--- Put local's ground on while `is_local`, and take it off when not.
function M.set_local(is_local)
  if is_local == showing_local then
    return
  end
  showing_local = is_local
  if is_local then
    put_local_ground()
  else
    take_local_ground_off()
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
      -- A new colorscheme replaced the ground; put local's on it again.
      if showing_local then
        put_local_ground()
      end
    end,
  })
end

return M
