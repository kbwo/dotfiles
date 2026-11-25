-- Cosense notation, as far as the notes need it: which parts of a line are
-- links, tags, icons and images, which lines are code or tables, a page's title
-- and first lines.
--
-- A port of stderr-blog's src/lib/cosense/parser.mjs, which follows Cosense's
-- own parser rule for rule. That file is the authority: the rules, their order
-- and the way they compose are copied from it, translated from JavaScript
-- regular expressions into Vim's (very magic). tests/parser_diff.lua checks the
-- port against it on every line of a real set of pages.
--
-- Positions are byte offsets (Lua strings), where parser.mjs counts UTF-16
-- units; nothing here hands a position to anything that counts otherwise.

local M = {}

-- JavaScript's \s, for use inside a [...] collection.
local S = [[ \t\n\r\x0b\x0c   -     　﻿]]

local function pat(source, ignorecase)
  source = source:gsub("@NB@", "[^\\]" .. S .. "]"):gsub("@WS@", "[" .. S .. "]"):gsub("@NS@", "[^" .. S .. "]"):gsub("@S@", S)
  return (ignorecase and "\\v\\c" or "\\v\\C") .. source
end

-- URL fragments shared by several rules (parser.mjs's constants of the same names).
local IMG_EXT = "%(png|jpe=g|gif|svg|webp)"
local IMAGE_URL = "https=://@NB@*\\." .. IMG_EXT .. "%(\\?@NB@+)="
local GYAZO_PAGE = "https=://%([a-z][a-z0-9-]*[a-z0-9]\\.|)gyazo\\.com/[0-9a-f]{32}"
local GYAZO_FILE = "https=://%([a-z][a-z0-9-]*[a-z0-9]\\.|i\\.|)gyazo\\.com/[a-z0-9]{32}\\.[^.@S@]+"
local ANY_URL = "https=://@NB@+"
local VIDEO_URL = "https=://@NB@*\\.%(mp4|webm|mov)%(\\?@NB@+)="
local LOCAL_IMAGE = "/img/@NB@+\\.%(png|jpe=g|gif|svg|webp|avif)"

local CONTAINERS = { indent = true, quote = true, strong = true, deco = true }

local function text(raw)
  return { type = "text", raw = raw }
end

local function container(type, raw, prefix, content, suffix, fields)
  local node = { type = type, raw = raw, prefix = prefix, suffix = suffix, children = content == "" and {} or { text(content) } }
  for k, v in pairs(fields or {}) do
    node[k] = v
  end
  return node
end

-- m: vim.fn.matchlist's result, so m[1] is the whole match and m[n + 1] group n.
local function leaf(type, fields_of)
  return function(m)
    local node = fields_of and fields_of(m) or {}
    node.type, node.raw = type, m[1]
    return { node }
  end
end

local function nonempty(s)
  return s ~= "" and s or nil
end

-- What a piece must contain for the rule to match it, read off the rule's first
-- token, so that a piece without it is passed over without running the regex.
-- Purely a shortcut: a rule that names nothing is always run.
local function required_text(source)
  if source:match("^\\%[") then
    return "["
  elseif source:sub(1, 1) == "`" then
    return "`"
  elseif source:find("^%(https") then
    return "http"
  elseif source:find("^%(%^|") then
    return "#"
  elseif source:find("^%^%(\\>") then
    return ">"
  end
end

local function rule(source, ignorecase, build)
  return { pat = pat(source, ignorecase), build = build, needs = required_text(source) }
end

-- One rule over one string piece: every match split out as nodes (parser.mjs `rule`).
local function apply_to_string(r, str)
  if r.needs and not str:find(r.needs, 1, true) then
    return { text(str) }
  end
  local out, last, pos = {}, 0, 0
  while pos <= #str do
    local found = vim.fn.matchstrpos(str, r.pat, pos)
    local s, e = found[2], found[3]
    if s < 0 then
      break
    end
    if e == s then
      -- An empty match is skipped, as matchAll steps over it.
      pos = s + math.max(1, #vim.fn.strcharpart(str:sub(s + 1), 0, 1))
    else
      if s > last then
        out[#out + 1] = text(str:sub(last + 1, s))
      end
      -- Cosense re-matches the isolated piece, so anchors see the piece, not the line.
      local again = vim.fn.matchlist(found[1], r.pat)
      local produced = #again > 0 and r.build(again) or { text(found[1]) }
      for _, n in ipairs(produced) do
        if n.raw ~= "" then
          out[#out + 1] = n
        end
      end
      last, pos = e, e
    end
  end
  if last == 0 then
    return { text(str) }
  end
  if last < #str then
    out[#out + 1] = text(str:sub(last + 1))
  end
  return out
end

local function apply(r, nodes)
  local out = {}
  for _, node in ipairs(nodes) do
    if node.type == "text" then
      vim.list_extend(out, apply_to_string(r, node.raw))
    else
      if CONTAINERS[node.type] then
        node.children = apply(r, node.children)
      end
      out[#out + 1] = node
    end
  end
  return out
end

local indent_rule = rule("^(@WS@+)(.*)$", false, function(m)
  return { container("indent", m[1], m[2], m[3], "") }
end)

local function src(group, link_group, gyazo)
  return function(m)
    return { src = m[group + 1], link = link_group and m[link_group + 1] or nil, gyazo = gyazo or nil }
  end
end

local function href(group)
  return function(m)
    return { href = m[group + 1] }
  end
end

local function icon(project_group, page_group)
  return function(m)
    return { project = project_group and m[project_group + 1] or nil, page = m[page_group + 1] }
  end
end

local RULES = {
  indent_rule,
  rule("^(\\> =)(.{-})$", false, function(m)
    local node = container("quote", m[1], m[2], m[3], "")
    node.children = apply(indent_rule, node.children)
    return { node }
  end),
  rule("`(%(\\\\`|[^`])*)`", false, leaf("code", function(m)
    return { content = m[2] }
  end)),
  rule("\\[(@WS@+)\\]", false, leaf("blank", function(m)
    return { content = m[2] }
  end)),

  -- decoration, formula
  rule([=[\[([!"#%&'()*+,./{|}<>_~-]+) (%(\[[^[\]]+\]|[^\]])+)\]]=], false, function(m)
    return { container("deco", m[1], "[" .. m[2] .. " ", m[3], "]", { deco = m[2] }) }
  end),
  rule([=[\[(\$ (.{-1,} ))\]]=], false, leaf("formula", function(m)
    return { formula = m[3] }
  end)),
  rule([=[\[(\$ ([^\]]+))\]]=], false, leaf("formula", function(m)
    return { formula = m[3] }
  end)),

  -- strong icon
  rule([=[\[\[(/([a-zA-Z0-9-]+)/([^[\]]+)\.icon)\]\]]=], false, leaf("strongIcon", icon(2, 3))),
  rule([=[\[\[(/([a-zA-Z0-9-]+)/([^[\]]+)\.icon([*x])([1-9]\d*))\]\]]=], false, leaf("strongIcon", icon(2, 3))),
  rule([=[\[\[(([^[\]]+)\.icon)\]\]]=], false, leaf("strongIcon", icon(nil, 2))),
  rule([=[\[\[(([^[\]]+)\.icon([*x])([1-9]\d*))\]\]]=], false, leaf("strongIcon", icon(nil, 2))),

  -- strong image
  rule("\\[\\[(" .. GYAZO_PAGE .. ")\\]\\]", false, leaf("strongImage", src(1, nil, true))),
  rule("\\[\\[(" .. GYAZO_FILE .. ")\\]\\]", false, leaf("strongImage", src(1, nil, true))),
  rule("\\[\\[(" .. IMAGE_URL .. ")\\]\\]", true, leaf("strongImage", src(1))),
  rule("\\[\\[(" .. LOCAL_IMAGE .. ")\\]\\]", true, leaf("strongImage", src(1))),
  rule("\\[\\[((" .. ANY_URL .. ")@WS@+(" .. GYAZO_PAGE .. "))\\]\\]", false, leaf("strongImage", src(3, 2, true))),
  rule("\\[\\[((" .. GYAZO_PAGE .. ")@WS@+(" .. ANY_URL .. "))\\]\\]", false, leaf("strongImage", src(2, 3, true))),
  rule("\\[\\[((" .. ANY_URL .. ")@WS@+(" .. GYAZO_FILE .. "))\\]\\]", false, leaf("strongImage", src(3, 2, true))),
  rule("\\[\\[((" .. GYAZO_FILE .. ")@WS@+(" .. ANY_URL .. "))\\]\\]", false, leaf("strongImage", src(2, 3, true))),
  rule("\\[\\[((" .. ANY_URL .. ")@WS@+(" .. IMAGE_URL .. "))\\]\\]", false, leaf("strongImage", src(3, 2))),
  rule("\\[\\[((" .. IMAGE_URL .. ")@WS@+(" .. ANY_URL .. "))\\]\\]", false, leaf("strongImage", src(2, 3))),

  rule([=[\[\[(%([^[]|\[[^[]).{-}\]*)\]\]]=], false, function(m)
    return { container("strong", m[1], "[[", m[2], "]]") }
  end),

  -- embeds: recognised so they are not mistaken for page links
  rule([=[\[(https=://%(www\.|music\.|)youtube\.com/watch\?(%([^@S@\]]+\&|)v\=([a-zA-Z0-9_-]+)%(\&[^@S@\]]+|)))\]]=], false, leaf("youtube", href(1))),
  rule([=[\[(https=://youtu\.be/([a-zA-Z0-9_-]+)%(\?([^@S@\]]{0,100})|))\]]=], false, leaf("youtube", href(1))),
  rule([=[\[(https=://%(www\.|)youtube\.com/shorts/([a-zA-Z0-9_-]+)%(\?([^@S@\]]+)|))\]]=], false, leaf("youtube", href(1))),
  rule([=[\[(https=://%(www\.|music\.|)youtube\.com/playlist\?(%([^@S@\]]+\&|)list\=([a-zA-Z0-9_-]+)%(\&[^@S@\]]+|)))\]]=], false, leaf("youtube", href(1))),
  rule([=[\[(https=://%(www\.|)youtube\.com/live/([a-zA-Z0-9_-]+)%(\?([^@S@\]]+)|))\]]=], false, leaf("youtube", href(1))),

  rule([=[\[(([NS]\d+%(\.\d+)=),([EW]\d+%(\.\d+)=)%(|,Z(\d+)))\]]=], false, leaf("location")),
  rule([=[\[(([NS]\d+%(\.\d+)=),([EW]\d+%(\.\d+)=)%(|,Z(\d+)) ([^[\]]+))\]]=], false, leaf("location")),
  rule([=[\[(([^[\]]+) ([NS]\d+%(\.\d+)=),([EW]\d+%(\.\d+)=)%(|,Z(\d+)))\]]=], false, leaf("location")),

  rule([=[\[(https=://vimeo\.com/([0-9]+)%(\?[^@S@\]]+|))\]]=], true, leaf("vimeo", href(1))),
  rule([=[\[(https=://vimeo\.com/([0-9]+)/([a-z0-9]+)%(\?[^@S@\]]+|))\]]=], true, leaf("vimeo", href(1))),

  rule([=[\[(https=://open\.spotify\.com/%([^/]+/|)(track|artist|playlist|album|episode|show)/([a-zA-Z0-9_-]+)%(\?[^@S@]{0,100}|))\]]=], true, leaf("spotify", href(1))),
  rule([=[\[(https=://anchor\.fm/([a-zA-Z0-9_-]+)/episodes/([a-zA-Z0-9_-]+%(/[a-zA-Z0-9_-]+)=)%(\?[^@S@]{0,100}|))\]]=], true, leaf("spotify", href(1))),
  rule([=[\[(https=://podcasters\.spotify\.com/pod/show/([a-zA-Z0-9_-]+)/episodes/([a-zA-Z0-9_-]+%(/[a-zA-Z0-9_-]+)=)%(\?[^@S@]{0,100}|))\]]=], true, leaf("spotify", href(1))),

  rule([=[\[(https=://@NB@*\.%(wav|mp3|weba|ogg|aac))\]]=], true, leaf("audio", href(1))),
  rule([=[\[(https=://@NB@+\.%(mp4|webm|mov))\]]=], true, leaf("video", href(1))),
  rule("\\[((" .. ANY_URL .. ")@WS@+(" .. VIDEO_URL .. "))\\]", true, leaf("video", href(3))),
  rule("\\[((" .. VIDEO_URL .. ")@WS@+(" .. ANY_URL .. "))\\]", true, leaf("video", href(2))),

  -- image
  rule("\\[(" .. GYAZO_PAGE .. "%(/raw)=)\\]", false, leaf("image", src(1, nil, true))),
  rule("\\[(" .. GYAZO_FILE .. ")\\]", false, leaf("image", src(1, nil, true))),
  rule("\\[(" .. IMAGE_URL .. ")\\]", true, leaf("image", src(1))),
  rule("\\[(" .. LOCAL_IMAGE .. ")\\]", true, leaf("image", src(1))),
  rule("\\[((" .. ANY_URL .. ")@WS@+(" .. GYAZO_PAGE .. "%(/raw)=))\\]", false, leaf("image", src(3, 2, true))),
  rule("\\[((" .. ANY_URL .. ")@WS@+(" .. GYAZO_FILE .. "))\\]", false, leaf("image", src(3, 2, true))),
  rule("\\[((" .. GYAZO_PAGE .. "%(/raw)=)@WS@+(" .. ANY_URL .. "))\\]", false, leaf("image", src(2, 3, true))),
  rule("\\[((" .. GYAZO_FILE .. ")@WS@+(" .. ANY_URL .. "))\\]", false, leaf("image", src(2, 3, true))),
  rule("\\[((" .. ANY_URL .. ")@WS@+(" .. IMAGE_URL .. "))\\]", true, leaf("image", src(3, 2))),
  rule("\\[((" .. IMAGE_URL .. ")@WS@+(" .. ANY_URL .. "))\\]", true, leaf("image", src(2, 3))),

  rule([=[\[((https=://[^@S@\]]+\.%(wav|mp3|weba|ogg|aac))@WS@+([^\]]*))\]]=], true, leaf("audio", href(2))),
  rule([=[\[(([^[\]]+)@WS@+(https=://[^@S@\]]+\.%(wav|mp3|weba|ogg|aac)))\]]=], true, leaf("audio", href(3))),

  -- external link, bare URL
  rule([=[\[((https=://[^@S@\]]+)(@WS@+)([^\]]*@NS@))\]]=], false, leaf("urlLink", function(m)
    return { href = m[3], title = m[5] }
  end)),
  rule([=[\[(([^[\]]*@NS@)(@WS@+)(https=://[^@S@\]]+))\]]=], false, leaf("urlLink", function(m)
    return { href = m[5], title = m[3] }
  end)),
  rule([=[\[(https=://[^@S@\]]+)\]]=], false, leaf("urlLink", href(1))),
  rule([=[(https=://@NS@+)]=], false, leaf("url", href(1))),

  -- icon
  rule([=[\[(/([a-zA-Z0-9-]+)/([^[\]]+)\.icon)\]]=], false, leaf("icon", icon(2, 3))),
  rule([=[\[(/([a-zA-Z0-9-]+)/([^[\]]+)\.icon([*x])([1-9]\d*))\]]=], false, leaf("icon", icon(2, 3))),
  rule([=[\[(([^[\]]+)\.icon)\]]=], false, leaf("icon", icon(nil, 2))),
  rule([=[\[(([^[\]]+)\.icon([*x])([1-9]\d*))\]]=], false, leaf("icon", icon(nil, 2))),

  -- page link
  rule([=[\[(/([a-z0-9-]+)/=)\]]=], true, leaf("link", function(m)
    return { project = m[3] }
  end)),
  rule([=[\[(/([a-z0-9-]+)/([^[\]]+)#([a-f0-9]{24,32}))\]]=], true, leaf("link", function(m)
    return { project = m[3], page = m[4], line = m[5] }
  end)),
  rule([=[\[(/([a-z0-9-]+)/([^[\]]+))\]]=], true, leaf("link", icon(2, 3))),
  rule([=[\[(([^[\]]+)#([a-f0-9]{24,32}))\]]=], false, leaf("link", function(m)
    return { page = m[3], line = m[4] }
  end)),
  rule([=[\[([^[\]]+)\]]=], false, leaf("link", function(m)
    return { page = m[2] }
  end)),

  -- hashtag: the leading whitespace is matched but stays plain text
  rule("(^|@WS@)#(@NS@+)", false, function(m)
    if m[3]:match("^#+$") then
      return { text(m[1]) }
    end
    return { text(m[2]), { type = "hashTag", raw = "#" .. m[3], page = m[3] } }
  end),
}

local function merge_text(nodes)
  local out = {}
  for _, node in ipairs(nodes) do
    if node.children then
      node.children = merge_text(node.children)
    end
    local prev = out[#out]
    if node.type == "text" and prev and prev.type == "text" then
      prev.raw = prev.raw .. node.raw
    else
      out[#out + 1] = node
    end
  end
  return out
end

--- One line's inline notation: nodes whose `raw`s concatenate back to the line.
function M.parse_line(line)
  if line == "" then
    return {}
  end
  local nodes = { text(line) }
  for _, r in ipairs(RULES) do
    nodes = apply(r, nodes)
  end
  return merge_text(nodes)
end

-- ===== Lines =====

-- JavaScript's \s beyond ASCII, as UTF-8 (the classification below runs on
-- every line of every page when the list is built, so it stays in plain Lua).
local WIDE_SPACES = {}
for _, cp in ipairs({ 0xa0, 0x1680, 0x2000, 0x2001, 0x2002, 0x2003, 0x2004, 0x2005, 0x2006, 0x2007, 0x2008, 0x2009, 0x200a, 0x2028, 0x2029, 0x202f, 0x205f, 0x3000, 0xfeff }) do
  WIDE_SPACES[vim.fn.nr2char(cp)] = true
end

--- The length in bytes of the whitespace character at byte `i`, or nil.
local function space_at(s, i)
  local b = s:byte(i)
  if not b then
    return nil
  end
  if b == 32 or (b >= 9 and b <= 13) then
    return 1
  end
  if b >= 0xC2 then
    for len = 2, 3 do
      if WIDE_SPACES[s:sub(i, i + len - 1)] then
        return len
      end
    end
  end
  return nil
end

--- How a line starts: its indentation in characters, and the byte after it.
local function leading_space(line)
  local i, n = 1, 0
  while true do
    local len = space_at(line, i)
    if not len then
      return n, i
    end
    i, n = i + len, n + 1
  end
end

--- The indentation of a line, in characters.
function M.count_indent(line)
  return (leading_space(line))
end

function M.is_empty_line(line)
  local _, after = leading_space(line)
  return after > #line
end

--- JavaScript's String.prototype.trim.
function M.trim(s)
  return vim.fn.substitute(s, pat("^@WS@+|@WS@+$"), "", "g")
end

local function block_end(texts, start)
  local indent = M.count_indent(texts[start])
  local last = start
  for i = start + 1, #texts do
    if indent >= M.count_indent(texts[i]) then
      break
    end
    last = i
  end
  return last
end

local CODE_START_NAMED = pat("^@WS@*code:(.+)\\(([^()]+)\\)$")
local CODE_START = pat("^@WS@*code:(.+)$")
local TABLE_START = pat("^@WS@*table:(.+)$")

local function code_block_start(line)
  local _, after = leading_space(line)
  if line:sub(after, after + 4) ~= "code:" then
    return nil
  end
  local m = vim.fn.matchlist(line, CODE_START_NAMED)
  if #m == 0 then
    m = vim.fn.matchlist(line, CODE_START)
  end
  if #m == 0 then
    return nil
  end
  local filename = M.trim(m[2])
  local lang = m[3] ~= "" and m[3] or (filename:match("([^.]*)$") or "")
  return lang ~= "" and { filename = filename, lang = vim.fn.tolower(lang) } or nil
end

--- Every line of a page, classified, with the inline notation parsed where it applies
--- (unless `opts.inline == false`, for callers that only need the classification):
--- { text, indent, nodes, title?, code_block?, table_block?, cli?, helpfeel?, horizontal_rule? }
function M.parse_page(page_text, opts)
  local texts = vim.split(page_text, "\n", { plain = true })
  local lines = {}
  for i, t in ipairs(texts) do
    local indent, after = leading_space(t)
    lines[i] = { text = t, indent = indent, after = after, nodes = {} }
  end
  lines[1].title = true

  local i = 2
  while i <= #lines do
    local found = code_block_start(texts[i])
    if found then
      local last = block_end(texts, i)
      for j = i, last do
        lines[j].code_block = { filename = found.filename, lang = found.lang, start = j == i, ["end"] = j == last }
      end
      i = last
    end
    i = i + 1
  end

  i = 2
  while i <= #lines do
    local line = lines[i]
    if texts[i]:sub(line.after, line.after + 5) == "table:" and vim.fn.match(texts[i], TABLE_START) == 0 then
      local last = block_end(texts, i)
      for j = i, last do
        lines[j].table_block = { start = j == i, ["end"] = j == last }
      end
      i = last
    end
    i = i + 1
  end

  for _, line in ipairs(lines) do
    if not line.title then
      -- `^\s*([%$]) (.+)`, `^\s*(\?) (.+)`, `^\s*(\d+)\. `, `^-{3,}\s*$`
      local rest = line.text:sub(line.after)
      line.cli = rest:match("^[%%$] .") and true or nil
      line.helpfeel = rest:match("^%? .") and true or nil
      line.number_list = rest:match("^%d+%. ") and true or nil
      local dashes = line.text:match("^%-%-%-+")
      line.horizontal_rule = dashes and M.is_empty_line(line.text:sub(#dashes + 1)) or nil
    end
    line.after = nil
  end

  if not opts or opts.inline ~= false then
    for _, line in ipairs(lines) do
      if not line.title and not line.code_block and not line.cli and not line.helpfeel then
        line.nodes = M.parse_line(line.text)
      end
    end
  end
  return lines
end

-- ===== Nodes =====

--- Visit every node, containers' children included, with the byte offset each starts at in its line.
function M.each_node(nodes, visit, offset)
  offset = offset or 0
  for _, node in ipairs(nodes) do
    visit(node, offset)
    if node.children then
      M.each_node(node.children, visit, offset + #node.prefix)
    end
    offset = offset + #node.raw
  end
end

--- What a reader sees of parsed nodes: the text with its notation removed (parser.mjs `nodesToText`).
--- `tag_names` writes `#tag` as `tag`, as Cosense does when it makes a title.
function M.nodes_to_text(nodes, tag_names)
  local out = {}
  for _, n in ipairs(nodes) do
    local t
    if n.children then
      t = M.nodes_to_text(n.children, tag_names)
    elseif n.type == "hashTag" then
      t = tag_names and n.page or n.raw
    elseif n.type == "text" or n.type == "url" then
      t = n.raw
    elseif n.type == "code" or n.type == "blank" then
      t = n.content
    elseif n.type == "formula" then
      t = n.formula
    elseif n.type == "link" then
      t = n.page or n.raw:sub(2, -2)
    elseif n.type == "urlLink" then
      t = n.title or n.href
    elseif n.type == "icon" or n.type == "strongIcon" then
      t = n.page
    elseif n.type == "image" or n.type == "strongImage" then
      t = ""
    else
      t = n.href or n.raw
    end
    out[#out + 1] = t
  end
  return table.concat(out)
end

-- ===== Titles and links =====

--- Two link strings name the same page when these are equal.
function M.to_title_lc(title)
  return vim.fn.tolower((title:gsub(" ", "_")))
end

local LINE_BREAK = "[\r\n\226\128\168\226\128\169]" -- CR, LF, U+2028, U+2029 as UTF-8

--- Whether a string can be a page title, and therefore a link target.
function M.is_valid_title(title)
  return type(title) == "string"
    and #title >= 1
    and vim.fn.strutf16len(title) <= 240
    and not title:find(LINE_BREAK)
    and not title:match("^[./]+$")
    and not title:find("[%[%]]")
    and vim.fn.match(title, pat("\\.icon@WS@*$")) < 0
    and not title:find("https?://")
end

--- The page's title: the first line, else the first non-empty line, else "Untitled".
function M.title_of(page_text)
  for _, line in ipairs(vim.split(page_text, "\n", { plain = true })) do
    local t = M.trim(line)
    if t ~= "" then
      return t
    end
  end
  return "Untitled"
end

--- The title of a page split off from `lines`: the first line that, read without its
--- notation and cleaned up, is a valid title, so `[foo] bar` gives "foo bar" (parser.mjs `splitTitleOf`).
function M.split_title_of(lines)
  for _, line_text in ipairs(lines) do
    -- Parsed as a body line: a leading dummy line keeps it from being read as a title.
    local line = M.parse_page("\n" .. line_text)[2]
    local seen = #line.nodes > 0 and M.nodes_to_text(line.nodes, true) or line.text
    seen = seen:gsub("[%[%]]", ""):gsub("https?://", "")
    local title = M.trim(vim.fn.substitute(seen, pat("\\.icon@WS@*$"), "", ""))
    if M.is_valid_title(title) then
      return title
    end
  end
end

--- `s` cut to `n` UTF-16 units, as JavaScript's slice(0, n) cuts it. Counted per
--- code point from the bytes: Vim's own character splitting joins composing
--- characters (an emoji's variation selector) to the one before.
local function utf16_slice(s, n)
  local used, i = 0, 1
  while i <= #s do
    local b = s:byte(i)
    local len = b < 0x80 and 1 or b < 0xE0 and 2 or b < 0xF0 and 3 or 4
    local w = len == 4 and 2 or 1
    if used + w > n then
      return s:sub(1, i - 1)
    end
    used, i = used + w, i + len
  end
  return s
end

--- A page's title and opening lines, as the list's cards show them (parser.mjs `analyzePage`'s
--- `title` and `descriptions`). Only the lines' kinds are needed, not their inline notation,
--- which keeps it fast enough to run over every page.
function M.summary(page_text)
  local descriptions = {}
  for _, line in ipairs(M.parse_page(page_text, { inline = false })) do
    if #descriptions == 5 then
      break
    end
    if not line.title and not (line.code_block and line.code_block.start) and not M.is_empty_line(line.text) and not line.horizontal_rule then
      local t = M.trim(line.text)
      if line.code_block or line.cli or line.helpfeel then
        descriptions[#descriptions + 1] = "`" .. utf16_slice((t:gsub("`", "\\`")), 198) .. "`"
      else
        descriptions[#descriptions + 1] = utf16_slice(t, 200)
      end
    end
  end
  return { title = M.title_of(page_text), descriptions = descriptions }
end

--- The page links of one line, with where each is: { page, start, finish } (byte offsets, finish exclusive).
--- Links to other Cosense projects are left out: no page here answers them.
function M.links_in_line(nodes)
  local out = {}
  M.each_node(nodes, function(node, offset)
    if node.page and not node.project and (node.type == "link" or node.type == "hashTag" or node.type == "icon" or node.type == "strongIcon") then
      out[#out + 1] = { page = node.page, start = offset, finish = offset + #node.raw, type = node.type }
    end
  end)
  return out
end

--- Every image a page embeds, in order, de-duplicated.
function M.image_sources(page_text)
  local seen, out = {}, {}
  for _, line in ipairs(M.parse_page(page_text)) do
    M.each_node(line.nodes, function(node)
      if (node.type == "image" or node.type == "strongImage") and not seen[node.src] then
        seen[node.src] = true
        out[#out + 1] = node.src
      end
    end)
  end
  return out
end

--- Every page a page links to (links, tags and icons), in order, de-duplicated by spelling.
function M.links_of(page_text)
  local seen, out = {}, {}
  for _, line in ipairs(M.parse_page(page_text)) do
    for _, link in ipairs(M.links_in_line(line.nodes)) do
      if M.is_valid_title(link.page) and not seen[link.page] then
        seen[link.page] = true
        out[#out + 1] = link.page
      end
    end
  end
  return out
end

-- A hashtag ends at whitespace, so only titles without any can be written as one.
local function as_hashtag(title)
  local joined = title:gsub(" ", "_")
  return vim.fn.match(joined, pat("@WS@")) < 0 and "#" .. joined or nil
end

--- Rewrite every reference to page `from` ([from], #from, [from.icon], [[from.icon]]) so it points at `to`.
--- The title line is left alone: it is not notation (links.mjs `replaceLinksInText`).
function M.replace_links(page_text, from, to)
  local from_lc = M.to_title_lc(from)
  local out = {}
  for _, line in ipairs(M.parse_page(page_text)) do
    local edits = {}
    M.each_node(line.nodes, function(node, offset)
      if node.children or node.project or not node.page or M.to_title_lc(node.page) ~= from_lc then
        return
      end
      local replacement
      if node.type == "link" then
        replacement = "[" .. to .. (node.line and "#" .. node.line or "") .. "]"
      elseif node.type == "hashTag" then
        replacement = as_hashtag(to) or ("[" .. to .. "]")
      elseif node.type == "icon" then
        replacement = "[" .. to .. node.raw:sub(2 + #node.page)
      elseif node.type == "strongIcon" then
        replacement = "[[" .. to .. node.raw:sub(3 + #node.page)
      end
      if replacement then
        edits[#edits + 1] = { start = offset, finish = offset + #node.raw, replacement = replacement }
      end
    end)
    local t = line.text
    for k = #edits, 1, -1 do
      local e = edits[k]
      t = t:sub(1, e.start) .. e.replacement .. t:sub(e.finish + 1)
    end
    out[#out + 1] = t
  end
  return table.concat(out, "\n")
end

return M
