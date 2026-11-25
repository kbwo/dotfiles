-- The Lua ports against the stderr-blog code they port, on every page under a
-- directory: Cosense notation (lua/notes/parser.lua against src/lib/cosense/parser.mjs:
-- the links found and where, each page's links, title, first lines and images) and
-- the filename a page gets when published with today's date (lua/notes/filename.lua
-- against src/lib/post-filename.mjs). Exits non-zero, listing the first differences.
--
-- usage: nvim -l tests/parser_diff.lua <stderr-blog repo> [pages dir]
local here = vim.fs.dirname(vim.fs.normalize(arg[0]))
vim.opt.rtp:prepend(vim.fs.dirname(here))
local parser = require("notes.parser")

local repo = assert(arg[1], "usage: nvim -l parser_diff.lua <stderr-blog repo> [pages dir]")
local pages_dir = arg[2] or (repo .. "/src/content/pages")
local result = vim.system({ "node", here .. "/parser_reference.mjs", repo, pages_dir }, { text = true }):wait()
assert(result.code == 0, result.stderr)

local failures, checked_pages, checked_lines = {}, 0, 0
local function fail(file, what, want, got)
  failures[#failures + 1] = ("%s: %s\n  parser.mjs: %s\n  lua:        %s"):format(file, what, vim.inspect(want), vim.inspect(got))
end

for line in result.stdout:gmatch("[^\n]+") do
  local want = vim.json.decode(line)
  local text = table.concat(vim.fn.readfile(pages_dir .. "/" .. want.file, "b"), "\n")
  checked_pages = checked_pages + 1
  for i, parsed in ipairs(parser.parse_page(text)) do
    checked_lines = checked_lines + 1
    local got = {}
    for _, l in ipairs(parser.links_in_line(parsed.nodes)) do
      got[#got + 1] = { l.type, l.page, l.start, l.finish }
    end
    if not vim.deep_equal(got, want.links[i]) then
      fail(want.file, ("links of line %d: %s"):format(i, parsed.text), want.links[i], got)
    end
  end
  local page_links = parser.links_of(text)
  if not vim.deep_equal(page_links, want.pageLinks) then
    fail(want.file, "page links", want.pageLinks, page_links)
  end
  -- Publishing with today as the created date: the new name, or nil when the URL would move
  -- (post-filename.mjs `postFileWithDate`, ported in lua/notes/filename.lua).
  local dated = require("notes.filename").with_date(want.file:match("[^/]*$"), "2100-01-01", want.title)
  if dated ~= (want.datedName ~= vim.NIL and want.datedName or nil) then
    fail(want.file, "name when published with today's date", want.datedName, dated)
  end
  local summary = parser.summary(text)
  if summary.title ~= want.title then
    fail(want.file, "title", want.title, summary.title)
  end
  if not vim.deep_equal(summary.descriptions, want.descriptions) then
    fail(want.file, "descriptions", want.descriptions, summary.descriptions)
  end
  if not vim.deep_equal(parser.image_sources(text), want.images) then
    fail(want.file, "images", want.images, parser.image_sources(text))
  end
end

print(("%d pages, %d lines checked, %d differences"):format(checked_pages, checked_lines, #failures))
for i = 1, math.min(#failures, 20) do
  print(failures[i])
end
os.exit(#failures == 0 and 0 or 1)
