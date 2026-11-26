-- How a page looks in its buffer: stderr-blog's tools/cosense/editor/decorate.js
-- in extmarks. The notation is coloured; on every line but the cursor's its marks
-- ([, ], the decoration's symbols, a URL link's URL, ...) are concealed, which
-- Neovim itself undoes on the cursor's line ('concealcursor' empty), as the
-- browser editor shows that line as typed. Each indentation character is drawn
-- two cells wide, the deepest with a dot ("–" on a quote or numbered line), on
-- the cursor's line too. Code blocks are coloured by treesitter.

local parser = require("notes.parser")
local marks = require("notes.marks")

local M = {}

local ns = vim.api.nvim_create_namespace("notes_decorate")

-- ===== which link names have a page =====

local known = nil -- title_lc -> true

local function known_titles()
  if not known then
    known = {}
    for _, p in ipairs(require("notes.store").pages()) do
      known[parser.to_title_lc(p.title)] = true
    end
  end
  return known
end

--- Forget the titles, after pages were created, renamed or deleted.
function M.forget_titles()
  known = nil
end

-- ===== marks =====

local function mark(buf, row, from, to, opts)
  opts.end_col = to
  opts.end_row = row
  pcall(vim.api.nvim_buf_set_extmark, buf, ns, row, from, opts)
end

local function hl(buf, row, from, to, group, priority)
  if to > from then
    mark(buf, row, from, to, { hl_group = group, priority = priority })
  end
end

local function hide(buf, row, from, to)
  if to > from then
    mark(buf, row, from, to, { conceal = "" })
  end
end

-- An item's dot: large, as the small "•" was hard to see among the text.
local DOT = "●"

--- Each of the first `count` characters of `text` (its indentation) two cells wide, the last with `dot`.
local function indent_marks(buf, row, text, count, dot)
  for i = 0, count - 1 do
    local shown = (i == count - 1 and dot) and dot or " "
    local col = vim.str_byteindex(text, "utf-32", i, false)
    pcall(vim.api.nvim_buf_set_extmark, buf, ns, row, col, { virt_text = { { shown, "NotesIndentDot" } }, virt_text_pos = "inline", right_gravity = false })
  end
end

-- The decoration's symbols, as decorate.js `decoClass` reads them.
local function deco_groups(deco)
  local groups = {}
  local stars = select(2, deco:gsub("%*", ""))
  if stars >= 2 then
    groups[#groups + 1] = "NotesHeading"
  elseif stars == 1 then
    groups[#groups + 1] = "NotesStrong"
  end
  if deco:find("/", 1, true) then
    groups[#groups + 1] = "NotesItalic"
  end
  if deco:find("-", 1, true) then
    groups[#groups + 1] = "NotesStrike"
  end
  if deco:find("_", 1, true) then
    groups[#groups + 1] = "NotesUnderline"
  end
  return groups
end

local CELL_NODES = { link = true, hashTag = true, icon = true, url = true, urlLink = true }

-- Decorate a line's nodes (decorate.js `walk`): colour, and conceal what the browser hides off the cursor's line.
local function walk(buf, row, nodes, offset, line, ctx)
  for _, node in ipairs(nodes) do
    local s, e = offset, offset + #node.raw
    local function link_group(page, project)
      if project then
        return "NotesUrl"
      end
      return known_titles()[parser.to_title_lc(page)] and "NotesLink" or "NotesLinkMissing"
    end
    local function bracketed(group, open, close)
      hide(buf, row, s, s + open)
      hl(buf, row, s + open, e - close, group)
      hide(buf, row, e - close, e)
    end
    local t = node.type
    if ctx.cell_only and not CELL_NODES[t] then
      if t == "indent" then
        walk(buf, row, node.children, s + #node.prefix, line, ctx)
      end
    elseif t == "indent" then
      -- A check line's box and a page mark's label stand where the dot would.
      local dot = not ctx.no_dot and ((line.number_list or ctx.quote) and "–" or DOT) or nil
      indent_marks(buf, row, line.text, vim.fn.strchars(node.prefix), dot)
      walk(buf, row, node.children, s + #node.prefix, line, ctx)
    elseif t == "quote" then
      -- The > gives way to a grey bar off the cursor's line, as the site's blockquote has.
      hide(buf, row, s, s + #node.prefix)
      ctx.swaps[#ctx.swaps + 1] = { row = row, col = s, chunks = { { "▎ ", "NotesQuoteBar" } } }
      hl(buf, row, s + #node.prefix, e, "NotesQuote")
      walk(buf, row, node.children, s + #node.prefix, line, ctx)
    elseif t == "deco" or t == "strong" then
      local from, to = s + #node.prefix, e - #node.suffix
      hide(buf, row, s, from)
      hide(buf, row, to, e)
      -- A heading: bars standing in for the size a terminal cannot change, fewer the larger it
      -- is, as a Markdown heading has fewer #s: [***** ] one, each * less one more; a Markdown
      -- heading as many as its #s.
      local stars = parser.heading_stars(node)
      if stars > 0 then
        local bars = node.markdown and #node.prefix:match("^#+") or math.max(6 - stars, 1)
        pcall(vim.api.nvim_buf_set_extmark, buf, ns, row, s, { virt_text = { { ("▌"):rep(bars) .. " ", "NotesHeading" } }, virt_text_pos = "inline", right_gravity = false })
      end
      for _, g in ipairs(t == "strong" and { "NotesStrong" } or deco_groups(node.deco)) do
        hl(buf, row, from, to, g)
      end
      walk(buf, row, node.children, from, line, ctx)
    elseif t == "code" then
      bracketed("NotesCode", 1, 1)
      hl(buf, row, s + 1, e - 1, "NotesCodeGround")
    elseif t == "formula" then
      bracketed("NotesCode", 3, 1)
    elseif t == "blank" then
      hide(buf, row, s, s + 1)
      hide(buf, row, e - 1, e)
    elseif t == "hashTag" then
      hl(buf, row, s, e, link_group(node.page))
    elseif t == "link" then
      -- [page#lineId]: line links are not implemented, so the id is not shown.
      bracketed(link_group(node.page or "", node.project), 1, (node.line and not node.project) and #node.line + 2 or 1)
    elseif t == "icon" or t == "strongIcon" then
      local open = t == "icon" and 1 or 2
      local dot_icon = node.raw:find("%.icon[^.]*$")
      bracketed(link_group(node.page, node.project), open, #node.raw - dot_icon + 1)
    elseif t == "urlLink" then
      if not node.title then
        bracketed("NotesUrl", 1, 1)
      elseif node.raw:sub(1, 1 + #node.href) == "[" .. node.href then
        hide(buf, row, s, e - 1 - #node.title)
        hl(buf, row, e - 1 - #node.title, e - 1, "NotesUrl")
        hide(buf, row, e - 1, e)
      else
        hide(buf, row, s, s + 1)
        hl(buf, row, s + 1, s + 1 + #node.title, "NotesUrl")
        hide(buf, row, s + 1 + #node.title, e)
      end
    elseif t == "url" then
      hl(buf, row, s, e, "NotesUrl")
    elseif t == "youtube" or t == "vimeo" or t == "spotify" or t == "audio" or t == "video" or t == "location" then
      bracketed("NotesUrl", 1, 1)
    elseif t == "image" or t == "strongImage" then
      local open = t == "image" and 1 or 2
      bracketed("NotesImage", open, open)
    end
    offset = e
  end
end

local function quote_line(nodes)
  local first = nodes[1]
  if first and first.type == "indent" then
    first = first.children[1]
  end
  return first ~= nil and first.type == "quote"
end

-- ===== code blocks =====

local function ts_lang(code_block)
  local ft = vim.filetype.match({ filename = code_block.filename })
    or vim.filetype.match({ filename = "x." .. code_block.lang })
    or code_block.lang
  local lang = vim.treesitter.language.get_lang(ft) or ft
  local ok, added = pcall(vim.treesitter.language.add, lang)
  if not ok or added == false then
    return nil
  end
  return lang
end

local token_cache = {} -- lang .. "\n" .. code -> { {row, col, end_row, end_col, group} }

local function tokens(lang, code)
  local key = lang .. "\n" .. code
  if token_cache[key] then
    return token_cache[key]
  end
  local out = {}
  local ok_parser, ts_parser = pcall(vim.treesitter.get_string_parser, code, lang)
  local query = ok_parser and vim.treesitter.query.get(lang, "highlights")
  if query then
    local tree = ts_parser:parse()[1]
    for id, node in query:iter_captures(tree:root(), code) do
      local name = query.captures[id]
      if name:sub(1, 1) ~= "_" and name ~= "spell" and name ~= "nospell" then
        local r1, c1, r2, c2 = node:range()
        out[#out + 1] = { r1, c1, r2, c2, "@" .. name .. "." .. lang }
      end
    end
  end
  token_cache[key] = out
  return out
end

-- Colour the body of the code block whose first line is `start` (1-based).
local function code_block(buf, lines, start)
  local block = lines[start].code_block
  local lang = ts_lang(block)
  local body = parser.code_block_at(lines, start).body
  if not lang or #body == 0 then
    return
  end
  local offsets = {}
  for r, code in ipairs(body) do
    offsets[r] = #lines[start + r].text - #code
  end
  for _, tk in ipairs(tokens(lang, table.concat(body, "\n"))) do
    local r1, c1, r2, c2, group = unpack(tk)
    for r = r1, math.min(r2, #body - 1) do
      local from = r == r1 and c1 or 0
      local to = r == r2 and c2 or #body[r + 1]
      if to > from then
        mark(buf, start + r, from + offsets[r + 1], to + offsets[r + 1], { hl_group = group, priority = 110 })
      end
    end
  end
end

-- ===== the whole page =====

local function block_start(lines, i, key)
  while i > 1 and not lines[i][key].start do
    i = i - 1
  end
  return i
end

-- A line's inline notation by its text: a keystroke changes one line, and parsing
-- every line again made a long page slow to type in. Emptied when it grows large.
local parsed_lines, parsed_count = {}, 0

local function parse_page(text)
  local lines = parser.parse_page(text, { inline = false })
  for _, line in ipairs(lines) do
    if not line.title and not line.code_block and not line.cli and not line.helpfeel then
      local nodes = parsed_lines[line.text]
      if not nodes then
        if parsed_count > 20000 then
          parsed_lines, parsed_count = {}, 0
        end
        nodes = parser.line_nodes(line.text)
        parsed_lines[line.text], parsed_count = nodes, parsed_count + 1
      end
      line.nodes = nodes
    end
  end
  return lines
end

-- ===== what stands in for a line's marks off the cursor's line =====

-- A page mark's label, a check line's box and a quote's bar are text put in (inline
-- virtual text), which conceal cannot take away on the cursor's line as it does the
-- marks themselves. They are kept per buffer and put on every line but the cursor's,
-- again whenever the cursor moves.
local swap_ns = vim.api.nvim_create_namespace("notes_decorate_swaps")
local swaps = {} -- buf -> { { row, col, chunks } }
local placed_for = {} -- buf -> the cursor row the swaps were last placed around

--- Put the swaps on every line but the cursor's; `force` even when that row has not changed.
function M.place_swaps(buf, force)
  buf = buf == 0 and vim.api.nvim_get_current_buf() or buf
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  local cursor_row = vim.api.nvim_get_current_buf() == buf and (vim.api.nvim_win_get_cursor(0)[1] - 1) or -1
  if not force and placed_for[buf] == cursor_row then
    return
  end
  placed_for[buf] = cursor_row
  vim.api.nvim_buf_clear_namespace(buf, swap_ns, 0, -1)
  for _, s in ipairs(swaps[buf] or {}) do
    if s.row ~= cursor_row then
      pcall(vim.api.nvim_buf_set_extmark, buf, swap_ns, s.row, s.col, { virt_text = s.chunks, virt_text_pos = "inline", right_gravity = false })
    end
  end
end

local function weekday(day)
  local y, m, d = day:match("(%d+)-(%d+)-(%d+)")
  return ({ "日", "月", "火", "水", "木", "金", "土" })[tonumber(os.date("%w", os.time({ year = tonumber(y), month = tonumber(m), day = tonumber(d), hour = 12 }))) + 1]
end

-- How far a day is from today (page-marks.mjs `relativeDay`).
local function relative_day(day)
  local function at_noon(s)
    local y, m, d = s:match("(%d+)-(%d+)-(%d+)")
    return os.time({ year = tonumber(y), month = tonumber(m), day = tonumber(d), hour = 12 })
  end
  local days = math.floor((at_noon(day) - at_noon(os.date("%Y-%m-%d"))) / 86400 + 0.5)
  return days == 0 and "今日" or days < 0 and (-days .. "日前") or ("あと" .. days .. "日")
end

--- A page mark's label, as checkbox.js `pageMarkAt` writes it: { text, due }, or nil.
function M.mark_label(text)
  local day = marks.date_of(text)
  if day then
    return { text = ("%s (%s) · %s"):format(day, weekday(day), relative_day(day)), due = day <= os.date("%Y-%m-%d") }
  end
  if marks.is_closed(text) then
    local time = text:match("closed%(([^()]*)%):")
    return { text = (time and time ~= "") and ("closed · " .. time) or "closed", due = false }
  end
end

function M.render(buf)
  buf = buf == 0 and vim.api.nvim_get_current_buf() or buf
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  local text = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
  local lines = parse_page(text)
  local found = {}
  swaps[buf] = found
  for i, line in ipairs(lines) do
    local row = i - 1
    local len = #line.text
    local ctx = { swaps = found }
    local label = not line.title and not line.code_block and not line.table_block and M.mark_label(line.text)
    local check = not line.title and not line.code_block and not line.table_block and row > 0 and marks.check_of(line.text)
    if label then
      -- date:… / closed: — the whole line a label, filled once its day has come.
      local at = #line.text:match("^%s*")
      indent_marks(buf, row, line.text, line.indent, nil)
      hide(buf, row, at, len)
      hl(buf, row, at, len, "NotesMark")
      found[#found + 1] = { row = row, col = at, chunks = { { " " .. label.text .. " ", label.due and "NotesMarkDue" or "NotesMarkLabel" } } }
    elseif check then
      -- todo: / done(…): — a box where the dot would be; a checked line fainter, its time after it.
      ctx.no_dot = true
      walk(buf, row, line.nodes, 0, line, vim.tbl_extend("force", ctx, { quote = quote_line(line.nodes) }))
      hide(buf, row, check.at, check.finish)
      hl(buf, row, check.at, check.finish, "NotesCheckMark")
      local chunks = { { check.checked and "☑ " or "☐ ", "NotesCheckBox" } }
      local time = check.checked and line.text:sub(check.at + 1, check.finish):match("^done%((%d+%-%d+%-%d+ %d+:%d+)")
      if check.checked then
        hl(buf, row, check.finish, len, "NotesChecked")
      end
      found[#found + 1] = { row = row, col = check.at, chunks = chunks }
      if time then
        found[#found + 1] = { row = row, col = len, chunks = { { "  " .. time, "NotesCheckTime" } } }
      end
    elseif line.title then
      hl(buf, row, 0, len, "NotesTitle")
      -- A terminal cannot draw the title larger: it stands between two rules instead.
      local rule = { { { ("─"):rep(300), "NotesTitleRule" } } }
      pcall(vim.api.nvim_buf_set_extmark, buf, ns, 0, 0, { virt_lines_above = true, virt_lines = rule })
      pcall(vim.api.nvim_buf_set_extmark, buf, ns, 0, 0, { virt_lines = rule })
    elseif line.code_block or line.table_block then
      local key = line.code_block and "code_block" or "table_block"
      if line.code_block then
        -- A code block on a ground of its own, across the window (decorate.js `.cs-code-line`).
        pcall(vim.api.nvim_buf_set_extmark, buf, ns, row, 0, { line_hl_group = "NotesCodeGround" })
      end
      if line[key].start then
        indent_marks(buf, row, line.text, line.indent, DOT)
        local at = vim.str_byteindex(line.text, "utf-32", line.indent, false)
        if line.code_block and line.code_block.fence then
          -- ```lang: the line as it is, as a header (and its closing ``` the same, below).
          hl(buf, row, at, len, "NotesCodeHeader")
        elseif line.code_block then
          -- code:main.ts — the file's name only, as a header, off the cursor's line.
          hide(buf, row, at, at + #"code:")
          hl(buf, row, at + #"code:", len, "NotesCodeHeader")
        else
          hl(buf, row, at, len, "NotesBlockStart")
        end
        if line.code_block then
          code_block(buf, lines, i)
        end
      elseif line.code_block and line.code_block.fence then
        -- A fence's body line keeps the indentation its code does not have.
        indent_marks(buf, row, line.text, line.code_block.from, nil)
        if line.code_block.close then
          local at = vim.str_byteindex(line.text, "utf-32", line.code_block.from, false)
          hl(buf, row, at, len, "NotesCodeHeader")
        end
      else
        indent_marks(buf, row, line.text, lines[block_start(lines, i, key)].indent + 1, nil)
        if line.table_block then
          walk(buf, row, line.nodes, 0, line, { cell_only = true })
        end
      end
    elseif line.cli or line.helpfeel then
      indent_marks(buf, row, line.text, line.indent, DOT)
      local at = vim.str_byteindex(line.text, "utf-32", line.indent, false)
      hl(buf, row, at, at + 1, "NotesPrefix")
      hl(buf, row, at + 1, len, "NotesCode")
    else
      walk(buf, row, line.nodes, 0, line, vim.tbl_extend("force", ctx, { quote = quote_line(line.nodes) }))
      local heading = parser.line_heading(line)
      if heading then
        -- A rule under a heading as under the title, from where the heading starts (each
        -- indentation character is drawn two cells wide, by indent_marks).
        local from = (" "):rep(2 * vim.fn.strchars(line.text:sub(1, heading.col)))
        pcall(vim.api.nvim_buf_set_extmark, buf, ns, row, 0, { virt_lines = { { { from }, { ("─"):rep(300), "NotesHeadingRule" } } } })
      end
    end
  end
  M.place_swaps(buf, true)
end

--- Keep `buf` decorated as it changes.
function M.attach(buf)
  local pending = false
  local function later()
    if pending then
      return
    end
    pending = true
    vim.schedule(function()
      pending = false
      M.render(buf)
    end)
  end
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, { buffer = buf, callback = later })
  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "BufLeave" }, {
    buffer = buf,
    callback = function(ev)
      -- Leaving: no cursor line any more, so every line shows its swaps.
      if ev.event == "BufLeave" then
        vim.schedule(function()
          M.place_swaps(buf)
        end)
      else
        M.place_swaps(buf)
      end
    end,
  })
  -- Pages may have been made, renamed or deleted since (in the list, by a save elsewhere).
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
    buffer = buf,
    callback = function()
      M.forget_titles()
      later()
    end,
  })
  M.render(buf)
end

return M
