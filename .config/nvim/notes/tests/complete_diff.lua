-- lua/notes/complete.lua `rank` against the stderr-blog code it ports
-- (tools/cosense/editor/suggest.js `rankTitles`): the titles of the pages under a
-- directory, ranked for a set of queries by both. Exits non-zero, listing the first differences.
--
-- usage: nvim -l tests/complete_diff.lua <stderr-blog repo> [pages dir]
local here = vim.fs.dirname(vim.fs.normalize(arg[0]))
vim.opt.rtp:prepend(vim.fs.dirname(here))
local complete = require("notes.complete")
local parser = require("notes.parser")

local repo = assert(arg[1], "usage: nvim -l complete_diff.lua <stderr-blog repo> [pages dir]")
local pages_dir = arg[2] or (repo .. "/src/content/pages")

-- Each page's title, with its file's time as updated and a made-up, often tied, linked time.
local titles = {}
for i, file in ipairs(vim.fn.globpath(pages_dir, "**/*.txt", false, true)) do
  local text = table.concat(vim.fn.readfile(file, "b", 1), "\n")
  titles[#titles + 1] = { title = parser.title_of(text), updated = vim.fn.getftime(file), linked_at = (i * 7919) % 13 }
end

-- Queries: pieces of real titles (every word, several words, a typo), and a few fixed ones.
local queries = { "", "a", "ne", "neovim", "nevoim", "Claude Code", "設定", "せってい", "2026", "記事 読", "x y z" }
for i = 1, #titles, math.max(1, math.floor(#titles / 60)) do
  local t = titles[i].title
  queries[#queries + 1] = vim.fn.strcharpart(t, 0, 4)
  queries[#queries + 1] = vim.fn.strcharpart(t, 1, 5)
  local chars = vim.fn.split(t, "\\zs")
  if #chars > 4 then
    table.remove(chars, 3) -- one character missing
    queries[#queries + 1] = table.concat(chars)
  end
end

local cases, input = {}, {}
for _, q in ipairs(queries) do
  for _, kind in ipairs({ "link", "tag" }) do
    local query = kind == "tag" and q:gsub(" ", "_") or q
    cases[#cases + 1] = { query = query, kind = kind }
    input[#input + 1] = vim.json.encode({ titles = titles, query = query, kind = kind, current = titles[1].title })
  end
end
local result = vim.system({ "node", here .. "/complete_reference.mjs", repo }, { stdin = table.concat(input, "\n") .. "\n", text = true }):wait()
assert(result.code == 0, result.stderr)
local want = vim.split(vim.trim(result.stdout), "\n", { plain = true })
assert(#want == #cases, ("suggest.js answered %d of %d cases"):format(#want, #cases))

local never = function()
  return 0
end
local failures = {}
for i, c in ipairs(cases) do
  local got = vim.tbl_map(function(t)
    return t.title
  end, complete.rank(titles, c.query, c.kind, titles[1].title, never))
  local expected = vim.json.decode(want[i])
  if not vim.deep_equal(got, expected) and #failures < 10 then
    failures[#failures + 1] = ("%s %q\n  suggest.js: %s\n  lua:        %s"):format(c.kind, c.query, vim.inspect(expected), vim.inspect(got))
  end
end
if #failures > 0 then
  io.stderr:write(table.concat(failures, "\n") .. "\n")
  os.exit(1)
end
print(("complete.lua ranks as suggest.js does on %d queries over %d titles"):format(#cases, #titles))
