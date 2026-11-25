-- How a page looks in its buffer: stderr-blog's tools/cosense/editor/decorate.js
-- in extmarks. The notation is coloured; on every line but the cursor's its marks
-- ([, ], the decoration's symbols, a URL link's URL, ...) are concealed, which
-- Neovim itself undoes on the cursor's line ('concealcursor' empty), as the
-- browser editor shows that line as typed. Each indentation character is drawn
-- two cells wide, the deepest with a dot ("–" on a quote or numbered line), on
-- the cursor's line too. Code blocks are coloured by treesitter.

local parser = require("notes.parser")

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
      local dot = (line.number_list or ctx.quote) and "–" or "•"
      indent_marks(buf, row, line.text, vim.fn.strchars(node.prefix), dot)
      walk(buf, row, node.children, s + #node.prefix, line, ctx)
    elseif t == "quote" then
      hide(buf, row, s, s + #node.prefix)
      hl(buf, row, s + #node.prefix, e, "NotesQuote")
      walk(buf, row, node.children, s + #node.prefix, line, ctx)
    elseif t == "deco" or t == "strong" then
      local from, to = s + #node.prefix, e - #node.suffix
      hide(buf, row, s, from)
      hide(buf, row, to, e)
      -- A heading: as many bars as its *s, standing in for the size a terminal cannot change.
      local stars = t == "deco" and select(2, node.deco:gsub("%*", "")) or 0
      if stars >= 2 then
        pcall(vim.api.nvim_buf_set_extmark, buf, ns, row, s, { virt_text = { { ("▌"):rep(stars) .. " ", "NotesHeading" } }, virt_text_pos = "inline", right_gravity = false })
      end
      for _, g in ipairs(t == "strong" and { "NotesStrong" } or deco_groups(node.deco)) do
        hl(buf, row, from, to, g)
      end
      walk(buf, row, node.children, from, line, ctx)
    elseif t == "code" then
      bracketed("NotesCode", 1, 1)
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

-- Colour the body of the code block whose `code:` line is `start` (1-based), lines `start + 1 .. last`.
local function code_block(buf, lines, start, last)
  local block = lines[start].code_block
  local lang = ts_lang(block)
  if not lang or last <= start then
    return
  end
  local cut = lines[start].indent + 1
  local body = {}
  for i = start + 1, last do
    body[#body + 1] = vim.fn.strcharpart(lines[i].text, cut)
  end
  local offsets = {}
  for i = start + 1, last do
    offsets[#offsets + 1] = #lines[i].text - #body[i - start]
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
        nodes = parser.parse_line(line.text)
        parsed_lines[line.text], parsed_count = nodes, parsed_count + 1
      end
      line.nodes = nodes
    end
  end
  return lines
end

function M.render(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  local text = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
  local lines = parse_page(text)
  for i, line in ipairs(lines) do
    local row = i - 1
    local len = #line.text
    if line.title then
      hl(buf, row, 0, len, "NotesTitle")
    elseif line.code_block or line.table_block then
      local key = line.code_block and "code_block" or "table_block"
      if line[key].start then
        indent_marks(buf, row, line.text, line.indent, "•")
        hl(buf, row, vim.str_byteindex(line.text, "utf-32", line.indent, false), len, "NotesBlockStart")
        if line.code_block then
          local last = i
          while lines[last + 1] and lines[last + 1].code_block and not lines[last + 1].code_block.start do
            last = last + 1
          end
          code_block(buf, lines, i, last)
        end
      else
        indent_marks(buf, row, line.text, lines[block_start(lines, i, key)].indent + 1, nil)
        if line.table_block then
          walk(buf, row, line.nodes, 0, line, { cell_only = true })
        end
      end
    elseif line.cli or line.helpfeel then
      indent_marks(buf, row, line.text, line.indent, "•")
      local at = vim.str_byteindex(line.text, "utf-32", line.indent, false)
      hl(buf, row, at, at + 1, "NotesPrefix")
      hl(buf, row, at + 1, len, "NotesCode")
    else
      walk(buf, row, line.nodes, 0, line, { quote = quote_line(line.nodes) })
    end
  end
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
