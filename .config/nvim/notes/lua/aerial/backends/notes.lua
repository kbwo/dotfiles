-- aerial's backend for notes pages: their headings ([** ] and up, and Markdown's # lines) as the outline, a heading
-- with more *s holding the smaller ones under it. aerial finds a backend by requiring
-- aerial.backends.<name>, hence this module's place.
local backend_util = require("aerial.backends.util")
local backends = require("aerial.backends")
local util = require("aerial.util")

local M = {}

M.is_supported = function(bufnr)
  if not vim.tbl_contains(util.get_filetypes(bufnr), "notes") then
    return false, "Filetype is not notes"
  end
  return true, nil
end

M.fetch_symbols_sync = function(bufnr)
  bufnr = bufnr or 0
  local text = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, true), "\n")
  local items, stack = {}, {}
  for _, h in ipairs(require("notes.parser").headings(text)) do
    while #stack > 0 and stack[#stack].stars <= h.stars do
      table.remove(stack)
    end
    local parent = stack[#stack]
    local item = { kind = "Interface", name = h.name, level = #stack, parent = parent, lnum = h.lnum, col = h.col, stars = h.stars }
    if parent then
      parent.children = parent.children or {}
      table.insert(parent.children, item)
    else
      table.insert(items, item)
    end
    table.insert(stack, item)
  end
  -- Each heading's range runs to the line before the next one at its level or above.
  require("aerial.backends.treesitter.extensions").markdown.postprocess_symbols(bufnr, items)
  backends.set_symbols(bufnr, items, { backend_name = "notes", lang = "notes" })
end

M.fetch_symbols = M.fetch_symbols_sync

M.attach = function(bufnr)
  backend_util.add_change_watcher(bufnr, "notes")
end

M.detach = function(bufnr)
  backend_util.remove_change_watcher(bufnr, "notes")
end

return M
