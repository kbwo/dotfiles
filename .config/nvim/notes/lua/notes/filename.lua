-- Page filenames: "<YYYY-MM-DD> <title>.txt", the date being the day the page
-- was created. The site's URL is made from the part after the date, so a page is
-- renamed only when its title changes, and keeps its date when it is.
-- A port of stderr-blog's src/lib/post-filename.mjs, the authority.

local parser = require("notes.parser")

local M = {}

M.EXT = ".txt"
M.PRIVATE_DIR = "private"
M.LOCAL_DIR = "private/local"
-- Linux refuses a name over 255 bytes; the rest of the room is for " (2)".
local MAX_FILE_NAME_BYTES = 200
local CUT_MARK = "…"

--- The filename without its directory and extension.
function M.stem(path)
  local base = path:match("[^/]*$")
  return (base:gsub("%.[tT][xX][tT]$", ""):gsub("%.[mM][dD]$", ""))
end

--- A filename stem's leading date ("YYYY-MM-DD" or nil) and the title part after it.
function M.parse(stem)
  local y, m, d, rest = stem:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)[ _%-]+(.*)$")
  if not y then
    return { date = nil, title = parser.trim(stem) }
  end
  return { date = ("%s-%s-%s"):format(y, m, d), title = parser.trim(rest) }
end

--- Whether a page path (relative to the pages directory) is under a private directory, at any depth, in any case.
function M.is_private(rel)
  local dirs = vim.split(rel, "/", { plain = true })
  for i = 1, #dirs - 1 do
    if dirs[i]:lower() == M.PRIVATE_DIR then
      return true
    end
  end
  return false
end

--- "local" for a page kept on this machine only, else "remote".
function M.store_of(rel)
  return rel:lower():sub(1, #M.LOCAL_DIR + 1) == M.LOCAL_DIR .. "/" and "local" or "remote"
end

--- A title with the characters a filename cannot hold taken out; "" if nothing usable is left.
function M.safe_title(title)
  local s = title:gsub("[\\/?*:%[%]{}|<>]", "")
  return parser.trim(vim.fn.substitute(s, [[\v[ \t\n\r\x0b\x0c   -     　﻿]+]], " ", "g"))
end

-- `safe` as it goes into "<prefix><title>.txt": cut, ending in CUT_MARK, when the name would be too long.
local function fit_title(prefix, safe)
  local room = MAX_FILE_NAME_BYTES - #prefix - #M.EXT
  if #safe <= room then
    return safe
  end
  local kept, used = {}, #CUT_MARK
  for _, ch in ipairs(vim.fn.split(safe, "\\zs")) do
    used = used + #ch
    if used > room then
      break
    end
    kept[#kept + 1] = ch
  end
  local cut = table.concat(kept)
  cut = vim.fn.substitute(cut, [[\v[ \t　…]+$]], "", "")
  return cut .. CUT_MARK
end

--- The filename for a new page made on `date` ("YYYY-MM-DD"), or nil when the title has nothing usable.
--- A title that already starts with that date is the whole name.
function M.for_new(date, title)
  local safe = M.safe_title(title)
  if safe == "" then
    return nil
  end
  local owns = safe:sub(1, #date) == date and (#safe == #date or safe:sub(#date + 1, #date + 1):match("[ _%-]"))
  local prefix = owns and "" or (date .. " ")
  return prefix .. fit_title(prefix, safe) .. M.EXT
end

--- An existing page's path for a new title: same directory and leading date, new title part.
function M.for_title(rel, title)
  local safe = M.safe_title(title)
  if safe == "" then
    return nil
  end
  local dir = rel:match("^(.*/)") or ""
  local date = M.parse(M.stem(rel)).date
  local prefix = date and (date .. " ") or ""
  return dir .. prefix .. fit_title(prefix, safe) .. M.EXT
end

--- The same page with `date` as its leading date (its created date): directory and title part kept.
--- nil when that could move the page's URL, which happens only for a file without a leading date.
function M.with_date(rel, date)
  local dir = rel:match("^(.*/)") or ""
  local parsed = M.parse(M.stem(rel))
  local prefix = date .. " "
  local moved = dir .. prefix .. fit_title(prefix, parsed.title) .. M.EXT
  -- ponytail: without a leading date the URL could move; refused outright rather than porting
  -- post-filename.mjs's slugify (Unicode letter classes) to compare the two URLs exactly.
  return parsed.date and moved or nil
end

--- `wanted`, or "<name> (2).txt", "(3)", ... — the first that `exists` says is free (or is `except`).
function M.free(wanted, except, exists)
  local candidate = wanted
  local i = 2
  while candidate ~= except and exists(candidate) do
    candidate = wanted:sub(1, -#M.EXT - 1) .. (" (%d)"):format(i) .. M.EXT
    i = i + 1
  end
  return candidate
end

return M
