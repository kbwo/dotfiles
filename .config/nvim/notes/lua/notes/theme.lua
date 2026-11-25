-- The notes' colors: the card list's highlight groups, made from the colorscheme in use
-- so that they suit a dark and a light one alike, and the switch to kanagawa's light
-- theme (lotus) while a local note or the local list is in front, so that local
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

-- ===== lotus while local is in front =====

local saved_theme = nil -- the kanagawa theme to go back to

--- Show lotus while `is_local`, and the theme from before when not. Only under kanagawa.
function M.set_local(is_local)
  local ok, kanagawa = pcall(require, "kanagawa")
  if not ok or vim.g.colors_name ~= "kanagawa" then
    return
  end
  local current = kanagawa._CURRENT_THEME
  if is_local and current ~= "lotus" then
    saved_theme = current
    vim.cmd.colorscheme("kanagawa-lotus")
  elseif not is_local and current == "lotus" and saved_theme then
    local back = saved_theme
    saved_theme = nil
    vim.cmd.colorscheme("kanagawa-" .. back)
  end
end

function M.setup()
  M.apply_highlights()
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("notes_theme", { clear = true }),
    callback = M.apply_highlights,
  })
end

return M
