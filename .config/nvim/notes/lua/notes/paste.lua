-- What pasted text becomes in a page: a port of stderr-blog's
-- tools/cosense/editor/input.js `transformPaste` (the authority, compared with
-- this port by tests/paste_diff.lua). Markdown is turned into the notation, URLs
-- of images and media are bracketed, lines pasted into a code block or a table are
-- indented into it, and so on; see the steps below, in the same order.

local parser = require("notes.parser")

local M = {}

-- The editor's own pages, whose URLs paste as links: the dev server's address
-- (stderr-blog's astro.config.mjs `server.port`) and tools/cosense/routes.js `BASE`.
M.OWN = "http://localhost:39321/__cosense/"

local function vre(pattern)
  return "\\v\\C" .. pattern
end

local function test(s, pattern, ignorecase)
  return vim.fn.match(s, (ignorecase and "\\v\\c" or "\\v\\C") .. pattern) >= 0
end

-- ===== URLs =====

local RESERVED = {} -- what decodeURI leaves encoded
for c in (";/?:@&=+$,#"):gmatch(".") do
  RESERVED[c] = true
end

-- JavaScript's decodeURI / decodeURIComponent: nil where JavaScript throws (a malformed sequence).
local function decode(s, keep_reserved)
  local out, i = {}, 1
  while i <= #s do
    local c = s:sub(i, i)
    if c ~= "%" then
      out[#out + 1] = c
      i = i + 1
    else
      -- One character: a lead byte's %XX and its continuation bytes'.
      local hex = s:match("^%%(%x%x)", i)
      if not hex then
        return nil
      end
      local b = tonumber(hex, 16)
      local n = b < 0x80 and 1 or b >= 0xF0 and b < 0xF8 and 4 or b >= 0xE0 and 3 or b >= 0xC2 and b < 0xE0 and 2 or nil
      if not n then
        return nil
      end
      local bytes, raw = { string.char(b) }, s:sub(i, i + 2)
      for k = 1, n - 1 do
        local h = s:match("^%%(%x%x)", i + 3 * k)
        local cb = h and tonumber(h, 16)
        if not cb or cb < 0x80 or cb > 0xBF then
          return nil
        end
        bytes[#bytes + 1] = string.char(cb)
        raw = raw .. s:sub(i + 3 * k, i + 3 * k + 2)
      end
      local ch = table.concat(bytes)
      if vim.fn.strchars(ch) ~= 1 or vim.str_utf_pos(ch)[1] ~= 1 then
        return nil
      end
      out[#out + 1] = (keep_reserved and n == 1 and RESERVED[ch]) and raw or ch
      i = i + 3 * n
    end
  end
  return table.concat(out)
end

local function is_url(s)
  return test(s, "^https?://\\S+$")
end

local IMAGE = "\\.%(png|jpe?g|gif|svg|webp)%(\\?\\S+)?$"
local MEDIA = "\\.%(mp4|webm|mov|wav|mp3|weba|ogg|aac)$"
local EMBED_HOST = "^https?://%(%(www\\.|music\\.)?youtube\\.com/|youtu\\.be/|vimeo\\.com/\\d|open\\.spotify\\.com/|%(i\\.|[a-z0-9-]+\\.)?gyazo\\.com/[0-9a-f]{32})"

--- One pasted URL as notation, or nil to leave it as it is (input.js `convertUrl`).
local function convert_url(url)
  local decoded = decode(url, true) or url
  if vim.startswith(decoded, M.OWN) then
    local rest = decode((url:sub(#M.OWN + 1):match("^[^?#]*")), false)
    if rest and rest ~= "" and rest ~= "search" then
      return "[" .. rest:gsub("_", " ") .. "]"
    end
  end
  local maps = vim.fn.matchlist(decoded, vre("google\\.[a-z.]+/maps/%(place/([^/]+)/)?\\@(-?\\d+\\.\\d+),(-?\\d+\\.\\d+),(\\d+)%(\\.\\d+)?z"))
  if #maps > 0 then
    local place, lat, lng, zoom = maps[2], maps[3], maps[4], maps[5]
    local ns = tonumber(lat) < 0 and ("S" .. lat:sub(2)) or ("N" .. lat)
    local ew = tonumber(lng) < 0 and ("W" .. lng:sub(2)) or ("E" .. lng)
    return ("[%s,%s,Z%s%s]"):format(ns, ew, zoom, place ~= "" and (" " .. place:gsub("%+", " ")) or "")
  end
  if test(decoded, IMAGE, true) or test(decoded, MEDIA, true) or test(decoded, EMBED_HOST, true) then
    return "[" .. decoded .. "]\n"
  end
  return decoded ~= url and decoded or nil
end

-- ===== Markdown =====

local function looks_like_markdown(lines)
  local some = false
  for _, l in ipairs(lines) do
    if test(l, "^\\s*%(#{1,6} |[-*+] |\\d+\\. |```|\\|.*\\|)") then
      some = true
    end
    if test(l, "^\\s*%(code:|table:|\\>)") then
      return false
    end
  end
  return some
end

local function strip_markdown(lines)
  local out = {}
  local fence = false
  for i, line in ipairs(lines) do
    local fenced = vim.fn.matchlist(line, vre("^(\\s*)```\\s*(\\S*)"))
    if #fenced > 0 then
      if not fence then
        out[#out + 1] = fenced[2] .. "code:" .. (fenced[3] ~= "" and fenced[3] or "txt")
      end
      fence = not fence
    elseif fence then
      out[#out + 1] = " " .. line
    elseif test(line, "^\\s*\\|.*\\|\\s*$") then
      if not test(line, "^\\s*\\|[[:space:]:|-]+\\|\\s*$") then -- the |---| separator row
        if not test(lines[i - 1] or "", "^\\s*\\|") then
          out[#out + 1] = "table:table"
        end
        local inner = parser.trim(line):gsub("^|", ""):gsub("|$", "")
        local cells = {}
        for _, c in ipairs(vim.split(inner, "|", { plain = true })) do
          cells[#cells + 1] = parser.trim(c)
        end
        out[#out + 1] = " " .. table.concat(cells, "\t")
      end
    else
      local heading = vim.fn.matchlist(line, vre("^(#{1,6}) (.*)$"))
      if #heading > 0 then
        out[#out + 1] = ("[%s %s]"):format(("*"):rep(math.max(1, 5 - #heading[2])), heading[3])
      else
        local item = vim.fn.matchlist(line, vre("^(\\s*)%([-*+]|\\d+\\.) (.*)$"))
        local body = #item > 0 and ((" "):rep(math.floor(#item[2] / 2) + 1) .. item[3]) or line
        body = vim.fn.substitute(body, vre("!\\[[^\\]]*\\]\\((\\S{-1,})\\)"), "[\\1]", "g")
        body = vim.fn.substitute(body, vre("\\[([^\\]]+)\\]\\((\\S{-1,})\\)"), "[\\1 \\2]", "g")
        body = vim.fn.substitute(body, vre("\\*\\*([^*]+)\\*\\*"), "[* \\1]", "g")
        body = vim.fn.substitute(body, vre("\\~\\~([^~]+)\\~\\~"), "[- \\1]", "g")
        out[#out + 1] = body
      end
    end
  end
  return out
end

-- ===== the paste =====

local function quote_line(line)
  if line.number_list or line.table_block then
    return false
  end
  local nodes = line.nodes
  if #nodes == 1 and nodes[1].type == "indent" then
    nodes = nodes[1].children
  end
  return #nodes == 1 and nodes[1].type == "quote"
end

--- The text to insert for `text` pasted at byte `col` of line `lnum` (1-based) of a page
--- whose lines are `lines` (input.js `transformPaste`).
function M.transform(lines, lnum, col, text)
  local page = parser.parse_page(table.concat(lines, "\n"))
  local parsed = page[lnum]
  local line = lines[lnum]
  local pasted = vim.split((text:gsub("\r\n?", "\n")), "\n", { plain = true })
  local code = parsed.code_block or parsed.cli
  local before = vim.fn.strcharpart(line:sub(1, col), vim.fn.strchars(line:sub(1, col)) - 1)
  local after = vim.fn.strcharpart(line:sub(col + 1), 0, 1)
  local inside_notation = before == "[" or before == "`" or after == "]" or after == "`"
  if not code and not inside_notation then
    local all_urls = true
    for _, l in ipairs(pasted) do
      if l ~= "" and not is_url(parser.trim(l)) then
        all_urls = false
      end
    end
    if all_urls then
      local out = {}
      for i, l in ipairs(pasted) do
        out[i] = l ~= "" and (convert_url(parser.trim(l)) or l) or l
      end
      return (table.concat(out, "\n"):gsub("\n\n$", "\n"))
    end
  end
  -- A block ends at the first line not indented deeper than its first, so the lines
  -- pasted into one are indented into it: an empty or unindented one would end it.
  local block = parsed.code_block or parsed.table_block
  if block then
    local start = lnum
    local key = parsed.code_block and "code_block" or "table_block"
    while start > 1 and not page[start][key].start do
      start = start - 1
    end
    return table.concat(pasted, "\n" .. (" "):rep(page[start].indent + 1))
  end
  if code or parsed.title then
    return table.concat(pasted, "\n")
  end
  if #pasted > 1 and looks_like_markdown(pasted) then
    pasted = strip_markdown(pasted)
  end
  if #pasted > 1 and quote_line(parsed) then
    local kept = {}
    for i, l in ipairs(pasted) do
      if not (l == "" and pasted[i - 1] == "") then
        kept[#kept + 1] = l
      end
    end
    for i = 2, #kept do
      kept[i] = "> " .. kept[i]
    end
    pasted = kept
  end
  -- Pasting several lines onto an indent-only line keeps them all at that depth.
  if #pasted > 1 and line ~= "" and parser.is_empty_line(line) then
    local indent = line:sub(1, col)
    for i = 2, #pasted do
      pasted[i] = indent .. pasted[i]
    end
  end
  return table.concat(pasted, "\n")
end

return M
