-- The notes in ddu: search (one page per item, ranked as the browser editor ranks
-- them) and choosing the page to merge into. The ddu source itself is
-- denops/@ddu-sources/notes.ts; it asks `items` here for what to list, so the
-- search stays the one in notes/store.lua.

local parser = require("notes.parser")
local store = require("notes.store")

local M = {}

local pending_merge = nil -- the page `m` was pressed on, while its target is being chosen

-- The first line under the title that holds one of `words`, and its number.
local function first_hit(rel, words)
  local lines = vim.split(store.text_of(rel), "\n", { plain = true })
  for i = 2, #lines do
    local lower = vim.fn.tolower(lines[i])
    for _, w in ipairs(words) do
      if lower:find(w, 1, true) then
        return parser.trim(lines[i]), i
      end
    end
  end
  return "", 1
end

--- What the ddu source lists. params: { mode = "search" | "titles", input, except }.
function M.items(params)
  local pages = store.pages()
  local out = {}
  if params.mode == "search" then
    local words = {}
    for term in vim.fn.tolower(params.input or ""):gmatch("%S+") do
      if term:sub(1, 1) ~= "-" then
        words[#words + 1] = term
      end
    end
    for _, page in ipairs(store.search(params.input or "", pages)) do
      local line, lnum = first_hit(page.rel, words)
      local display = line ~= "" and (page.title .. "  ─  " .. line) or page.title
      out[#out + 1] = { word = display, action = { path = store.abs(page.rel), lineNr = lnum } }
    end
  else
    table.sort(pages, function(a, b)
      return a.updated > b.updated
    end)
    for _, page in ipairs(pages) do
      if page.rel ~= params.except then
        out[#out + 1] = { word = page.title, action = { path = store.abs(page.rel) } }
      end
    end
  end
  return out
end

--- Search the notes in ddu, starting from `query`; editing the filter searches again.
function M.search(query)
  vim.fn["ddu#start"]({
    name = "notes-search",
    input = query or "",
    sources = { { name = "notes", params = { mode = "search" } } },
    -- The source does the matching and the order itself, on every change of the input.
    -- <CR> shows the chosen page's card in the list ("reveal").
    sourceOptions = { notes = { volatile = true, matchers = {}, sorters = {}, converters = {}, defaultAction = "reveal" } },
  })
end

-- Whether a chosen page's card on a day the list has not loaded yet is loaded (true), or the page is opened instead.
M.REVEAL_LOADS_MORE = true

--- The source's "reveal" action: the chosen page's card in the list. Given a `command` (the
--- ddu buffer's <Leader>vv / ss / tt pass vsplit / split / tabnew), the page is opened with
--- it at the matching line instead, as the file kind's open does.
function M.reveal_picked(path, lnum, command)
  vim.schedule(function()
    local function open(cmd)
      vim.cmd(("%s %s"):format(cmd, vim.fn.fnameescape(path)))
      if lnum and lnum > 0 then
        pcall(vim.api.nvim_win_set_cursor, 0, { lnum, 0 })
      end
    end
    if command and command ~= "" then
      return open(command)
    end
    local rel = store.rel_of(path)
    if not (rel and require("notes.list").reveal(rel, M.REVEAL_LOADS_MORE)) then
      open("edit")
    end
  end)
end

--- `m` in the list: choose, in ddu, the page to merge `page` into.
function M.pick_merge_target(page)
  pending_merge = page
  vim.fn["ddu#start"]({
    name = "notes-merge",
    sources = { { name = "notes", params = { mode = "titles", except = page.rel } } },
    sourceOptions = { notes = { defaultAction = "merge" } },
  })
end

--- Called by the source's "merge" action with the chosen page's path.
function M.merge_picked(path)
  local page = pending_merge
  pending_merge = nil
  if page then
    vim.schedule(function()
      require("notes.list").merge_into(page, path)
    end)
  end
end

return M
