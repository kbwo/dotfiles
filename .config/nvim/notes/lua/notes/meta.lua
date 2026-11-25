-- The pages directory's .cosense.json: the pins ("pins": { "<title, lowercased,
-- spaces as _>": <unix seconds pinned at> }) and the update times recorded when
-- posts were migrated from Markdown ("migrated": { "<path>": <unix seconds> }).
--
-- Several programs write this file (stderr-blog's dev server, its migration
-- scripts, its iOS app, and this), and git merges it line by line, so every
-- writer must produce the same bytes for the same content: JSON.stringify(meta,
-- null, 2) plus a newline, keys in the order they were read (stderr-blog's
-- src/lib/cosense/meta-file.mjs). vim.json would lose the order, hence the small
-- ordered reader and writer here.

local M = {}

M.NAME = ".cosense.json"

-- An ordered object: { keys = { k1, k2, ... }, map = { [k] = v } }.
local function object()
  return { keys = {}, map = {}, is_object = true }
end

local function set(obj, key, value)
  if obj.map[key] == nil then
    obj.keys[#obj.keys + 1] = key
  end
  obj.map[key] = value
end

local function delete(obj, key)
  if obj.map[key] == nil then
    return
  end
  obj.map[key] = nil
  for i, k in ipairs(obj.keys) do
    if k == key then
      table.remove(obj.keys, i)
      return
    end
  end
end

-- ===== reading =====

local function decode(s)
  local pos = 1
  local function ws()
    pos = s:find("[^ \t\r\n]", pos) or #s + 1
  end
  local value
  local function str()
    local out = {}
    pos = pos + 1
    while true do
      local c = s:sub(pos, pos)
      if c == '"' then
        pos = pos + 1
        return table.concat(out)
      elseif c == "\\" then
        local e = s:sub(pos + 1, pos + 1)
        if e == "u" then
          local cp = tonumber(s:sub(pos + 2, pos + 5), 16)
          pos = pos + 6
          if cp >= 0xD800 and cp <= 0xDBFF and s:sub(pos, pos + 1) == "\\u" then
            local low = tonumber(s:sub(pos + 2, pos + 5), 16)
            cp = 0x10000 + (cp - 0xD800) * 0x400 + (low - 0xDC00)
            pos = pos + 6
          end
          out[#out + 1] = vim.fn.nr2char(cp)
        else
          out[#out + 1] = ({ b = "\b", f = "\f", n = "\n", r = "\r", t = "\t" })[e] or e
          pos = pos + 2
        end
      elseif c == "" then
        error("unterminated string")
      else
        local stop = s:find('["\\]', pos) or #s + 1
        out[#out + 1] = s:sub(pos, stop - 1)
        pos = stop
      end
    end
  end
  function value()
    ws()
    local c = s:sub(pos, pos)
    if c == "{" then
      local obj = object()
      pos = pos + 1
      ws()
      if s:sub(pos, pos) == "}" then
        pos = pos + 1
        return obj
      end
      while true do
        ws()
        local key = str()
        ws()
        assert(s:sub(pos, pos) == ":", "expected :")
        pos = pos + 1
        set(obj, key, value())
        ws()
        local sep = s:sub(pos, pos)
        pos = pos + 1
        if sep == "}" then
          return obj
        end
        assert(sep == ",", "expected , or }")
      end
    elseif c == "[" then
      local arr = { is_array = true }
      pos = pos + 1
      ws()
      if s:sub(pos, pos) == "]" then
        pos = pos + 1
        return arr
      end
      while true do
        arr[#arr + 1] = value()
        ws()
        local sep = s:sub(pos, pos)
        pos = pos + 1
        if sep == "]" then
          return arr
        end
        assert(sep == ",", "expected , or ]")
      end
    elseif c == '"' then
      return str()
    elseif s:sub(pos, pos + 3) == "true" then
      pos = pos + 4
      return true
    elseif s:sub(pos, pos + 4) == "false" then
      pos = pos + 5
      return false
    elseif s:sub(pos, pos + 3) == "null" then
      pos = pos + 4
      return vim.NIL
    else
      local num = s:match("^-?%d+%.?%d*[eE]?[-+]?%d*", pos)
      assert(num and num ~= "", "unexpected character")
      pos = pos + #num
      return tonumber(num)
    end
  end
  return value()
end

--- The parsed file, or an empty one when it is missing or unreadable (meta-file.mjs `parseMeta`).
function M.parse(text)
  local ok, meta = pcall(decode, text or "")
  if ok and type(meta) == "table" and meta.is_object then
    return meta
  end
  local empty = object()
  set(empty, "pins", object())
  return empty
end

-- ===== writing =====

local ESCAPES = { ['"'] = '\\"', ["\\"] = "\\\\", ["\b"] = "\\b", ["\f"] = "\\f", ["\n"] = "\\n", ["\r"] = "\\r", ["\t"] = "\\t" }

local function encode_string(s)
  return '"' .. s:gsub('[%c"\\]', function(c)
    return ESCAPES[c] or ("\\u%04x"):format(c:byte())
  end) .. '"'
end

local function encode(v, indent)
  local inner = indent .. "  "
  if type(v) == "table" and v.is_object then
    if #v.keys == 0 then
      return "{}"
    end
    local parts = {}
    for _, k in ipairs(v.keys) do
      parts[#parts + 1] = inner .. encode_string(k) .. ": " .. encode(v.map[k], inner)
    end
    return "{\n" .. table.concat(parts, ",\n") .. "\n" .. indent .. "}"
  elseif type(v) == "table" and v.is_array then
    if #v == 0 then
      return "[]"
    end
    local parts = {}
    for _, item in ipairs(v) do
      parts[#parts + 1] = inner .. encode(item, inner)
    end
    return "[\n" .. table.concat(parts, ",\n") .. "\n" .. indent .. "]"
  elseif type(v) == "string" then
    return encode_string(v)
  elseif type(v) == "number" then
    return v == math.floor(v) and ("%d"):format(v) or ("%.17g"):format(v)
  elseif type(v) == "boolean" then
    return tostring(v)
  end
  return "null"
end

--- The file's bytes for `meta` (meta-file.mjs `serializeMeta`).
function M.serialize(meta)
  return encode(meta, "") .. "\n"
end

-- ===== the file =====

function M.read(pages_dir)
  local f = io.open(pages_dir .. "/" .. M.NAME, "rb")
  if not f then
    return M.parse("")
  end
  local text = f:read("*a")
  f:close()
  return M.parse(text)
end

function M.write(pages_dir, meta)
  local f = assert(io.open(pages_dir .. "/" .. M.NAME, "wb"))
  f:write(M.serialize(meta))
  f:close()
end

local function pins(meta)
  if not meta.map.pins then
    set(meta, "pins", object())
  end
  return meta.map.pins
end

--- When the page `title_lc` was pinned (unix seconds), or nil.
function M.pin_of(meta, title_lc)
  local p = meta.map.pins
  return p and p.map[title_lc] or nil
end

--- Pin the page `title_lc` now, or unpin it when `pinned` is false.
function M.set_pin(meta, title_lc, pinned)
  if pinned then
    set(pins(meta), title_lc, os.time())
  else
    delete(pins(meta), title_lc)
  end
end

--- A pin follows its page through a rename.
function M.move_pin(meta, from_lc, to_lc)
  local p = pins(meta)
  local at = p.map[from_lc]
  if at == nil then
    return
  end
  delete(p, from_lc)
  set(p, to_lc, at)
end

--- The update time recorded for a migrated page, while the migration is its only commit
--- (stderr-blog's src/lib/cosense/migrated-dates.mjs `updatedTime`).
function M.updated_time(meta, rel, commits, git_updated)
  local migrated = meta.map.migrated
  local recorded = migrated and migrated.map[rel]
  return (type(recorded) == "number" and commits <= 1) and recorded or git_updated
end

return M
