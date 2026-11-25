-- Link completion: an nvim-cmp source offering page titles while the cursor is in
-- [ ] or on a #tag (stderr-blog's tools/cosense/editor/suggest.js). The candidates are
-- the pages and the link names no page has yet (tools/cosense/store.js `allTitles`),
-- found and ordered as suggest.js `rankTitles` does; nvim-cmp's own matching and
-- sorting are kept out of it by the comparator registered in `setup`. Accepting a
-- candidate writes the whole bracket or tag, as suggest.js `accept` does.

local parser = require("notes.parser")
local store = require("notes.store")

local M = {}

local LIMIT = 6

-- ===== what is being typed =====

--- The bracket or hashtag being typed at byte `col` of `line` (suggest.js `contextAt`):
--- { kind = "link" | "tag", from, to (byte offsets, to exclusive), query }, or nil.
function M.context_at(line, col, parsed)
  if parsed.title or parsed.code_block or parsed.cli or parsed.helpfeel then
    return nil
  end
  local before, after = line:sub(1, col), line:sub(col + 1)
  local open = before:match(".*()%[")
  if open and not before:sub(open):find("]", 1, true) then
    local close = after:find("]", 1, true)
    local rest = close and after:sub(1, close - 1) or ""
    local query = before:sub(open + 1) .. rest
    if not vim.regex([=[\v^[!"#%&'()*+,\-./{|}<>_~]+ |^\$ |^https?://|^\[]=]):match_str(query) and not rest:find("[", 1, true) then
      return { kind = "link", from = open - 1, to = close and (col + close) or col, query = query }
    end
  end
  local tag = before:match("^#(%S*)$") or before:match("%s#(%S*)$")
  if tag then
    local tail = after:match("^%S*")
    return { kind = "tag", from = col - #tag - 1, to = col + #tail, query = tag .. tail }
  end
  return nil
end

-- ===== ranking (suggest.js `rankTitles`) =====

local function norm(s)
  return vim.fn.tolower(s):gsub("_", "")
end

-- Digit runs count as one character, so "2026-07-04 読んだ記事" is not pushed down by its date.
local function length_for_sort(title)
  return vim.fn.strchars((title:gsub("%d+", "0")))
end

--- Whether `needle` occurs in `haystack` allowing one edit (Sellers' algorithm, by character).
local function fuzzy_includes(haystack, needle)
  local n = vim.fn.split(needle, "\\zs")
  local column = {}
  for i = 0, #n do
    column[i] = i
  end
  for _, ch in ipairs(vim.fn.split(haystack, "\\zs")) do
    local next = { [0] = 0 }
    for i = 1, #n do
      next[i] = math.min(column[i - 1] + (n[i] == ch and 0 or 1), column[i] + 1, next[i - 1] + 1)
    end
    column = next
    if column[#n] <= 1 then
      return true
    end
  end
  return false
end

local function stable_sort(list, less)
  for i, v in ipairs(list) do
    v._i = i
  end
  table.sort(list, function(a, b)
    if less(a, b) then
      return true
    elseif less(b, a) then
      return false
    end
    return a._i < b._i
  end)
end

--- Titles matching `query`, best first: those containing every word, then (for a query of
--- 3+ characters with few of those) the ones matching with one edit allowed. Within each,
--- the names most recently written as links first, then the last visited, then the
--- shortest, then the most recently updated.
function M.rank(titles, query, kind, current_title, visited_at)
  local words = {}
  for _, w in ipairs(vim.split(query, kind == "tag" and "_+" or "%s+")) do
    w = norm(w)
    if w ~= "" then
      words[#words + 1] = w
    end
  end
  local skip = { [norm(current_title or "")] = true, [norm(query)] = true }
  local function order(list)
    stable_sort(list, function(a, b)
      local la, lb = length_for_sort(a.title), length_for_sort(b.title)
      if la ~= lb then
        return la < lb
      end
      return a.updated > b.updated
    end)
    stable_sort(list, function(a, b)
      return visited_at(a.title) > visited_at(b.title)
    end)
    stable_sort(list, function(a, b)
      return (a.linked_at or 0) > (b.linked_at or 0)
    end)
    return list
  end
  local exact, rest = {}, {}
  for _, t in ipairs(titles) do
    local n = norm(t.title)
    if not skip[n] then
      local all = true
      for _, w in ipairs(words) do
        if not n:find(w, 1, true) then
          all = false
          break
        end
      end
      if all then
        exact[#exact + 1] = t
      else
        rest[#rest + 1] = t
      end
    end
  end
  order(exact)
  if vim.fn.strchars(query) < 3 or #exact > 10 then
    return vim.list_slice(exact, 1, LIMIT)
  end
  local fuzzy = {}
  for _, t in ipairs(rest) do
    local n = norm(t.title)
    local all = true
    for _, w in ipairs(words) do
      if not fuzzy_includes(n, w) then
        all = false
        break
      end
    end
    if all then
      fuzzy[#fuzzy + 1] = t
    end
  end
  order(fuzzy)
  return vim.list_slice(vim.list_extend(exact, fuzzy), 1, LIMIT)
end

-- ===== the candidates (store.js `allTitles`) =====

local cached = nil -- { titles, visited } until a page is saved

--- Call `done(titles, visited_at)`.
local function candidates(done)
  if cached then
    return done(cached.titles, cached.visited)
  end
  local pages = store.pages()
  store.page_links(pages, function(links)
    local linked_at = {}
    for _, p in ipairs(pages) do
      for _, l in ipairs(links[p.rel] or {}) do
        local lc = parser.to_title_lc(l)
        linked_at[lc] = math.max(linked_at[lc] or 0, p.updated)
      end
    end
    local titles, seen = {}, {}
    for _, p in ipairs(pages) do
      local lc = parser.to_title_lc(p.title)
      seen[lc] = true
      titles[#titles + 1] = { title = p.title, updated = p.updated, linked_at = linked_at[lc] or 0 }
    end
    for _, p in ipairs(pages) do
      for _, l in ipairs(links[p.rel] or {}) do
        local lc = parser.to_title_lc(l)
        if not seen[lc] then
          seen[lc] = true
          titles[#titles + 1] = { title = l, updated = p.updated, linked_at = linked_at[lc] }
        end
      end
    end
    -- When each page was last opened: Neovim's own record of the files it edited, newest first.
    local title_of = {}
    for _, p in ipairs(pages) do
      title_of[vim.fs.normalize(vim.fn.resolve(store.abs(p.rel)))] = p.title
    end
    local rank = {}
    local old = vim.v.oldfiles
    for i, f in ipairs(old) do
      local t = title_of[vim.fs.normalize(vim.fn.resolve(vim.fn.expand(f)))]
      if t and not rank[t] then
        rank[t] = #old - i + 1
      end
    end
    local visited = function(title)
      return rank[title] or 0
    end
    cached = { titles = titles, visited = visited }
    done(titles, visited)
  end)
end

function M.forget()
  cached = nil
end

--- Start building the candidates, so that the first completion does not wait for it.
function M.prepare()
  vim.schedule(function()
    candidates(function() end)
  end)
end

-- ===== the nvim-cmp source =====

local source = {}

function source:is_available()
  return vim.bo.filetype == "notes"
end

function source:get_trigger_characters()
  return { "[", "#" }
end

-- The query starts right after the [ or the #, spaces included.
function source:get_keyword_pattern()
  return [=[\%(\[\|#\)\zs[^\[\]]*]=]
end

local function current_context()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local parsed = parser.parse_page(table.concat(lines, "\n"), { inline = false })[row]
  return M.context_at(lines[row], col, parsed), row, lines
end

function source:complete(params, callback)
  local ctx, _, lines = current_context()
  if not ctx then
    return callback({ items = {}, isIncomplete = true })
  end
  local typed = params.context.cursor_before_line:sub(params.offset)
  candidates(function(titles, visited)
    local items = {}
    for i, t in ipairs(M.rank(titles, ctx.query, ctx.kind, parser.title_of(table.concat(lines, "\n")), visited)) do
      items[#items + 1] = {
        label = t.title,
        -- Everything offered matches what was typed: the choice is rankTitles', not nvim-cmp's.
        filterText = typed,
        sortText = ("%04d"):format(i),
        -- A tag's spaces as _, so that the tag found again in `execute` is the whole of it.
        insertText = ctx.kind == "tag" and (t.title:gsub(" ", "_")) or t.title,
        data = { notes_rank = i, title = t.title },
      }
    end
    callback({ items = items, isIncomplete = true })
  end)
end

-- Accepting writes the whole notation over what was being typed (suggest.js `accept`).
function source:execute(item, callback)
  local ctx, row = current_context()
  local title = item.data.title
  if ctx then
    local line = vim.api.nvim_get_current_line()
    -- nvim-cmp has put the title in already; the context is found again around it.
    local as_tag = ctx.kind == "tag" and not title:gsub(" ", "_"):find("%s")
    local insert = as_tag and ("#" .. title:gsub(" ", "_")) or ("[" .. title .. "]")
    vim.api.nvim_buf_set_text(0, row - 1, ctx.from, row - 1, math.min(ctx.to, #line), { insert })
    vim.api.nvim_win_set_cursor(0, { row, ctx.from + #insert })
  end
  callback(item)
end

--- Register the source, and in pages put it before every other: while it has
--- candidates (in [ ] or on a #tag) nothing else is offered.
function M.setup()
  local ok, cmp = pcall(require, "cmp")
  if not ok then
    return
  end
  cmp.register_source("notes", source)
  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("notes_cmp", { clear = true }),
    pattern = "notes",
    callback = function()
      local config = cmp.get_config()
      local sources = { { name = "notes", group_index = 0 } }
      for _, s in ipairs(config.sources) do
        sources[#sources + 1] = s
      end
      local comparators = {
        -- The notes' own order, between its candidates only.
        function(a, b)
          local ra, rb = a.completion_item.data and a.completion_item.data.notes_rank, b.completion_item.data and b.completion_item.data.notes_rank
          if ra and rb then
            return ra < rb
          end
        end,
      }
      vim.list_extend(comparators, config.sorting.comparators)
      cmp.setup.buffer({ sources = sources, sorting = { priority_weight = config.sorting.priority_weight, comparators = comparators } })
    end,
  })
end

return M
