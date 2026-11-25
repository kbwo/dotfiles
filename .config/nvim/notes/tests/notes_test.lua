-- The notes UI on a throwaway notes directory: the card list (layout, moving
-- between cards, sections, loading more days), and what saving and the list's
-- operations do to the files.
--
-- usage: nvim --headless -u NONE -l tests/notes_test.lua
local here = vim.fs.dirname(vim.fs.normalize(arg[0]))
vim.opt.rtp:prepend(vim.fs.dirname(here))
vim.o.columns, vim.o.lines = 140, 50
vim.o.swapfile, vim.o.shada = false, ""
vim.g.mapleader = " "

local root = vim.fn.tempname()
local store = require("notes.store")
store.root = root
vim.fn.mkdir(root .. "/pages/private", "p")
vim.fn.mkdir(root .. "/img", "p")
require("notes").setup()
local list = require("notes.list")
local parser = require("notes.parser")
local meta = require("notes.meta")

-- confirm() and input() would wait for a key: answers are queued instead.
local answers = {}
vim.fn.confirm = function()
  return table.remove(answers, 1) or 2
end
vim.fn.input = function(opts)
  return table.remove(answers, 1) or (type(opts) == "table" and opts.cancelreturn or "")
end

local failures = 0
local function check(name, ok, detail)
  print((ok and "ok   " or "FAIL ") .. name .. (ok and "" or ("\n     " .. vim.inspect(detail))))
  if not ok then
    failures = failures + 1
  end
end

local function write(rel, text, mtime)
  local path = root .. "/pages/" .. rel
  vim.fn.mkdir(vim.fs.dirname(path), "p")
  vim.fn.writefile(vim.split(text, "\n", { plain = true }), path, "b")
  if mtime then
    vim.uv.fs_utime(path, mtime, mtime)
  end
end
local function exists(rel)
  return vim.uv.fs_stat(root .. "/pages/" .. rel) ~= nil
end
local function read(rel)
  return table.concat(vim.fn.readfile(root .. "/pages/" .. rel, "b"), "\n")
end
local function day_time(day)
  local y, m, d = day:match("(%d+)-(%d+)-(%d+)")
  return os.time({ year = tonumber(y), month = tonumber(m), day = tonumber(d), hour = 12 })
end

-- ===== the list =====

write("private/2026-11-20 日本語のとても長いタイトルが入っているページ.txt", "日本語のとても長いタイトルが入っているページ\n一行目の本文です #tag\n[リンク先] へ\n", day_time("2026-11-24"))
write("private/2026-11-20 short.txt", "short\nbody\n", day_time("2026-11-20"))
write("2026-11-19 公開ページ.txt", "公開ページ\ndate:2000-01-01\n本文\n", day_time("2026-11-19"))
write("private/2026-11-18 閉じた.txt", "閉じた\nclosed(2026-11-18 10:00:00):\n本文\n", day_time("2026-11-18"))
write("private/2026-11-17 ピン.txt", "ピン\n本文\n", day_time("2026-11-17"))
local m = meta.read(root .. "/pages")
meta.set_pin(m, parser.to_title_lc("ピン"), true)
meta.write(root .. "/pages", m)

list.open()
local st = list._state()
local text = vim.api.nvim_buf_get_lines(st.buf, 0, -1, false)
local function index_of(line)
  for i, l in ipairs(text) do
    if l == line then
      return i
    end
  end
end

-- Every card row is the same width on screen, Japanese titles included.
local widths = {}
for _, l in ipairs(text) do
  if l:find("▎") then
    widths[(vim.fn.strdisplaywidth(l) - 2) % 32] = true
  end
end
check("card rows line up with full-width text", vim.tbl_count(widths) == 1, widths)

local pinned, due, d24, d20 = index_of("Pinned"), index_of("今日まで"), index_of("2026-11-24 (火)"), index_of("2026-11-20 (金)")
check("sections: Pinned, then due pages, then days newest first", pinned and due and d24 and d20 and pinned < due and due < d24 and d24 < d20, { pinned, due, d24, d20 })
local joined = table.concat(text, "\n")
check("a page is under the day it was created and the day it was last updated", select(2, joined:gsub("日本語のとても長いタイトル", "")) == 2)
check("the day it was only updated on says so", joined:find("↻ 更新") ~= nil)
check("a closed page is listed", joined:find("閉じた") ~= nil)
check("a published page is marked public", joined:find("public") ~= nil)

local first = st.cards[st.cur]
list._move(st, 1, 0)
check("j moves to a card below", st.cards[st.cur].line > first.line, { st.cur })
list._move(st, -1, 0)
check("k moves back up", st.cards[st.cur].line == first.line)

-- After the cursor jumps (G, <C-f>, ...) onto a heading or a blank line, j/k go on from there.
local last = st.cards[#st.cards]
vim.api.nvim_win_set_cursor(0, { vim.api.nvim_buf_line_count(st.buf), 0 })
vim.api.nvim_exec_autocmds("CursorMoved", { buffer = st.buf })
check("G: the selection follows to the nearest card", st.cards[st.cur].line == last.line, { st.cur, #st.cards })
vim.api.nvim_win_set_cursor(0, { 1, 0 })
vim.api.nvim_exec_autocmds("CursorMoved", { buffer = st.buf })
check("gg: the selection follows to the first card", st.cur == 1, { st.cur })
list._move(st, 1, 0)
check("gg then j: the next row down from the top, not back where the cursor was", st.cards[st.cur].line > st.cards[1].line and st.cards[st.cur].line < last.line, { st.cur })

-- ===== loading more days =====

for i = 1, 40 do
  local day = os.date("%Y-%m-%d", day_time("2025-01-01") + i * 86400)
  write(("private/%s day%d.txt"):format(day, i), ("day%d\nbody\n"):format(i), day_time(day))
end
list.open()
st = list._state()
local function headings()
  local n = 0
  for _, l in ipairs(vim.api.nvim_buf_get_lines(st.buf, 0, -1, false)) do
    if l:match("^%d%d%d%d%-%d%d%-%d%d %(") then
      n = n + 1
    end
  end
  return n
end
check("30 days with pages are shown at first", headings() == 30, headings())
vim.api.nvim_win_set_cursor(0, { vim.api.nvim_buf_line_count(st.buf) - 2, 0 })
vim.api.nvim_exec_autocmds("CursorMoved", { buffer = st.buf })
check("going to the end loads the next days", headings() > 30, headings())

-- ===== search =====

local results = store.search("本文", store.pages())
check("search finds the pages holding the word", #results >= 4, #results)
results = store.search("short", store.pages())
check("a page whose title has the word comes first", results[1] and results[1].title == "short", results[1])
check("a -word leaves pages out", #store.search("本文 -closed", store.pages()) < #store.search("本文", store.pages()))

-- ===== saving a new title =====

write("private/2026-11-10 古い名前.txt", "古い名前\n本文\n")
write("private/2026-11-11 参照元.txt", "参照元\n[古い名前] と #古い名前\n")
m = meta.read(root .. "/pages")
meta.set_pin(m, parser.to_title_lc("古い名前"), true)
meta.write(root .. "/pages", m)
vim.cmd.edit(root .. "/pages/private/2026-11-10 古い名前.txt")
vim.api.nvim_buf_set_lines(0, 0, 1, false, { "新しい名前" })
answers = { 1 } -- rewrite the links
vim.cmd("silent write")
check("a new title renames the file, keeping its date", exists("private/2026-11-10 新しい名前.txt") and not exists("private/2026-11-10 古い名前.txt"))
check("the buffer follows the file", vim.api.nvim_buf_get_name(0):find("新しい名前") ~= nil)
check("links to the old title are rewritten", read("private/2026-11-11 参照元.txt"):find("[新しい名前] と #新しい名前", 1, true) ~= nil, read("private/2026-11-11 参照元.txt"))
m = meta.read(root .. "/pages")
check("the pin follows the page", meta.pin_of(m, parser.to_title_lc("新しい名前")) ~= nil and meta.pin_of(m, parser.to_title_lc("古い名前")) == nil)
vim.api.nvim_buf_set_lines(0, 1, 2, false, { "書き足した" })
vim.cmd("silent write")
check("a save that keeps the title keeps the name", exists("private/2026-11-10 新しい名前.txt"))

-- ===== operations =====

local function page(title)
  return store.find(title)
end
store.edit_marks(page("short"), function(lines)
  return require("notes.marks").with_closed(lines, true)
end)
check("x: closed puts a closed mark", page("short").closed)
store.edit_marks(page("short"), function(lines)
  return require("notes.marks").with_closed(lines, false)
end)
check("x again: opens it", not page("short").closed)

store.edit_marks(page("short"), function(lines)
  return require("notes.marks").with_date(lines, "2026-12-01")
end)
check("t: a date line", page("short").date == "2026-12-01" and read(page("short").rel):find("^short\ndate:2026%-12%-01\n") ~= nil, read(page("short").rel))

local _, dup = store.duplicate(page("short"), store.pages())
check("y: a duplicate titled _2", dup == "short_2" and page("short_2") ~= nil and page("short_2").private)

vim.fn.mkdir(root .. "/pages/private/img", "p")
vim.fn.writefile({ "png" }, root .. "/pages/private/img/shot.png", "b")
write("private/2026-11-12 画像あり.txt", "画像あり\n[/img/shot.png]\n")
local rel = store.set_visibility(page("画像あり"), false, false, store.pages())
check("v: publishing moves the page out of private/", rel == "2026-11-12 画像あり.txt" and exists(rel), rel)
check("v: and its images to the published ones", vim.uv.fs_stat(root .. "/img/shot.png") ~= nil)
rel = store.set_visibility(page("画像あり"), true, false, store.pages())
check("v again: back to private/, images too", rel == "private/2026-11-12 画像あり.txt" and vim.uv.fs_stat(root .. "/pages/private/img/shot.png") ~= nil, rel)
local today_rel = store.set_visibility(page("画像あり"), false, true, store.pages())
check("v with today as created date: the date is replaced, the title part stays", today_rel == os.date("%Y-%m-%d") .. " 画像あり.txt", today_rel)

store.merge(page("short_2"), page("short"))
check("m: the body is appended and the page deleted", page("short_2") == nil and select(2, read(page("short").rel):gsub("body", "")) == 2, read(page("short").rel))

store.delete(page("short").rel)
check("D: deleted", page("short") == nil)

-- ===== splitting lines off =====

vim.cmd.edit(root .. "/pages/private/2026-11-11 参照元.txt")
vim.api.nvim_buf_set_lines(0, -1, -1, false, { "切り出す見出し", "  中身" })
local n = vim.api.nvim_buf_line_count(0)
require("notes.page").split(n - 1, n)
check("split: the lines become a page titled by the first", page("切り出す見出し") ~= nil and read(page("切り出す見出し").rel):find("^切り出す見出し\nfrom %[参照元%]\n  中身") ~= nil, page("切り出す見出し") and read(page("切り出す見出し").rel))
check("split: a link takes their place", vim.api.nvim_buf_get_lines(0, -2, -1, false)[1] == "[切り出す見出し]")

-- ===== related pages =====

write("private/2026-11-13 A.txt", "A\n[B] と [共通]\n")
write("private/2026-11-13 B.txt", "B\n本文\n")
write("private/2026-11-13 C.txt", "C\n[共通] [A]\n")
local r = store.related(page("A"), store.pages())
check("related: Links holds the linked and the linking pages", #r.links == 2, vim.tbl_map(function(p)
  return p.title
end, r.links))
check("related: a group per shared link name", r.groups[1] and r.groups[1].link == "共通" and r.groups[1].pages[1].title == "C", r.groups)

-- ===== following a link =====

vim.cmd.edit(root .. "/pages/private/2026-11-13 A.txt")
vim.api.nvim_win_set_cursor(0, { 2, 1 })
require("notes.page").follow()
check("<C-CR> on [B] opens the page B", vim.api.nvim_buf_get_name(0):find("B%.txt$") ~= nil, vim.api.nvim_buf_get_name(0))
vim.cmd.edit(root .. "/pages/private/2026-11-13 A.txt")
vim.api.nvim_win_set_cursor(0, { 2, #"[B] と [" + 1 })
require("notes.page").follow()
check("<C-CR> on a link with no page starts one with that title, unsaved", vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] == "共通" and not vim.uv.fs_stat(vim.api.nvim_buf_get_name(0)), vim.api.nvim_buf_get_name(0))
vim.cmd("enew!")

-- ===== git =====

local git = require("notes.git")
local origin, clone = vim.fn.tempname(), vim.fn.tempname()
local function sh(cmd, cwd)
  local r = vim.system(cmd, { cwd = cwd, text = true, env = { GIT_AUTHOR_NAME = "t", GIT_AUTHOR_EMAIL = "t@t", GIT_COMMITTER_NAME = "t", GIT_COMMITTER_EMAIL = "t@t" } }):wait()
  return r
end
sh({ "git", "init", "-q", "--bare", "-b", "main", origin })
sh({ "git", "clone", "-q", origin, clone })
sh({ "git", "-C", clone, "config", "user.name", "t" })
sh({ "git", "-C", clone, "config", "user.email", "t@t" })
vim.fn.mkdir(clone .. "/content/pages", "p")
vim.fn.writefile({ "first", "" }, clone .. "/content/pages/2026-01-01 first.txt", "b")
sh({ "git", "add", "-A" }, clone)
sh({ "git", "commit", "-q", "-m", "init" }, clone)
sh({ "git", "push", "-q", "-u", "origin", "main" }, clone)
local repo = git.repo_of(clone .. "/content/pages")
check("git: the repository and the pages' path in it", repo and repo.path == "content/pages", repo)

vim.fn.writefile({ "second", "" }, clone .. "/content/pages/2026-01-02 second.txt", "b")
local finished
git.sync(repo, { repo.path }, function(ok, committed)
  finished = { ok = ok, committed = committed }
end)
vim.wait(10000, function()
  return finished ~= nil
end)
check("git: a save is committed and pushed", finished and finished.ok and finished.committed, finished)
local remote_log = sh({ "git", "--git-dir", origin, "log", "--format=%s", "main" }).stdout
check("git: the remote has the commit", remote_log:find("update pages") ~= nil, remote_log)

local h
git.history(repo, { repo.path }, function(result)
  h = result
end)
vim.wait(10000, function()
  return h ~= nil
end)
check("git: when each page was last committed", h and h.last["content/pages/2026-01-02 second.txt"] and h.commits["content/pages/2026-01-01 first.txt"] == 1, h)
vim.fn.delete(origin, "rf")
vim.fn.delete(clone, "rf")

print(failures == 0 and "all passed" or (failures .. " failed"))
vim.fn.delete(root, "rf")
os.exit(failures == 0 and 0 or 1)
