-- The notes UI on a throwaway notes directory: the card list (layout, moving
-- between cards, sections, loading more days), and what saving and the list's
-- operations do to the files.
--
-- usage: nvim --headless -u NONE -l tests/notes_test.lua
local here = vim.fs.dirname(vim.fs.normalize(arg[0]))
vim.opt.rtp:prepend(vim.fs.dirname(here))
vim.o.columns, vim.o.lines = 140, 50
vim.o.swapfile, vim.o.shada = false, ""
-- No "3 lines yanked": headless Neovim 0.11.6 crashes printing one in a window with a
-- winbar and wrapped lines (a page's), which a terminal UI does not.
vim.o.report = 10000
vim.g.mapleader = " "
vim.cmd("filetype on")

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
check("the band says which store this is", text[1]:find("^ REMOTE ") ~= nil, text[1])
local band = vim.api.nvim_buf_get_extmarks(st.buf, -1, { 0, 0 }, { 0, -1 }, { details = true })
check("the band is colored across the width", vim.iter(band):any(function(m)
  return m[4].line_hl_group == "NotesBandRemote"
end))
local wrap = list._wrap
check("a title wraps at spaces between Latin words", vim.deep_equal(wrap("Building a Tiny Task Runner in Lua", 20, 3), { "Building a Tiny Task", "Runner in Lua" }), wrap("Building a Tiny Task Runner in Lua", 20, 3))
check("Japanese wraps anywhere", vim.deep_equal(wrap("あいうえおかきくけこ", 10, 3), { "あいうえお", "かきくけこ" }), wrap("あいうえおかきくけこ", 10, 3))
check("a word wider than a row is broken", vim.deep_equal(wrap("abcdefghij", 4, 3), { "abcd", "efgh", "ij" }), wrap("abcdefghij", 4, 3))
local long = wrap(("長い"):rep(30), 10, 3)
check("at most 3 rows, the last ending in …", #long == 3 and long[3]:find("…$") ~= nil and vim.fn.strdisplaywidth(long[3]) <= 10, long)
local card_rows = {}
for i, l in ipairs(text) do
  if l:find("日本語のとても長いタイトル", 1, true) then
    card_rows = { l, text[i + 1] }
    break
  end
end
check("a long title goes on to the next row instead of being cut", card_rows[1] and not card_rows[1]:find("…", 1, true) and (card_rows[1] .. card_rows[2]):gsub("[ ▎]", ""):find("日本語のとても長いタイトルが入っているページ", 1, true) ~= nil, card_rows)
local closed_hl = vim.api.nvim_get_hl(0, { name = "NotesCardClosed" })
local card_hl = vim.api.nvim_get_hl(0, { name = "NotesCard" })
check("a card not closed stands on a ground of its own; a closed one's text is dimmed but not as far as its card", closed_hl.bg ~= card_hl.bg and closed_hl.fg ~= card_hl.fg and closed_hl.fg ~= closed_hl.bg, { closed_hl, card_hl })

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

-- x on a page under 今日まで: it moves to its created day, and the view stays where it was.
for i, c in ipairs(st.cards) do
  if c.page.title == "公開ページ" then
    vim.api.nvim_win_set_cursor(0, { c.line, c.col })
    vim.api.nvim_exec_autocmds("CursorMoved", { buffer = st.buf })
    break
  end
end
local before_view = vim.fn.winsaveview()
list._actions.closed(st)
local after_view = vim.fn.winsaveview()
check("x: the page is closed", store.find("公開ページ").closed)
check("x: the view stays where it was, not carried to the page's day", after_view.topline == before_view.topline and after_view.lnum == before_view.lnum, { before_view, after_view })

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

write("private/2026-11-14 short_2.txt", "short_2\nbody\n")

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

local ddu = require("notes.ddu")
local titles = ddu.items({ mode = "titles", except = page("short_2").rel })
check("m: the merge target list has every page but the one being merged", #titles == #store.pages() - 1 and not vim.iter(titles):any(function(i)
  return i.word == "short_2"
end))
answers = { 1 } -- yes, merge
list.merge_into(page("short_2"), store.abs(page("short").rel))
check("m: the body is appended and the page deleted", page("short_2") == nil and select(2, read(page("short").rel):gsub("body", "")) == 2, read(page("short").rel))

local hits = ddu.items({ mode = "search", input = "short" })
check("/: ddu lists one item per page, the title-match first, opening at the matching line", hits[1] and hits[1].word:find("^short") and hits[1].action.path == store.abs(page("short").rel), hits[1])

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

-- ===== how a page looks =====

local function page_buffer(rel, lines)
  write(rel, table.concat(lines, "\n") .. "\n")
  vim.cmd.edit(vim.fn.fnameescape(root .. "/pages/" .. rel))
  require("notes.decorate").forget_titles()
  require("notes.decorate").render(0)
  return vim.api.nvim_get_current_buf()
end
local decorate_ns = vim.api.nvim_create_namespace("notes_decorate")
local function marks_on(row)
  return vim.api.nvim_buf_get_extmarks(0, decorate_ns, { row, 0 }, { row, -1 }, { details = true })
end
local function find_mark(row, pred)
  for _, mk in ipairs(marks_on(row)) do
    if pred(mk[4], mk[3]) then
      return mk
    end
  end
end

page_buffer("private/2026-11-15 見た目.txt", { "見た目", " [A] と [まだ無い] と [* 太字]", "  二段目", "> 引用", " 1. 番号", "code:x.lua", " local a = 1", "[https://example.com 公式]" })
check("a page gets filetype notes", vim.bo.filetype == "notes", vim.bo.filetype)
check("the title is drawn as a title", find_mark(0, function(d)
  return d.hl_group == "NotesTitle"
end) ~= nil)
check("the title has room above it and a rule under it", find_mark(0, function(d)
  return d.virt_lines_above and d.virt_lines
end) ~= nil and find_mark(0, function(d)
  return not d.virt_lines_above and d.virt_lines and d.virt_lines[1][1][1]:find("^─") ~= nil
end) ~= nil)
check("a link's [ is concealed", find_mark(1, function(d, col)
  return d.conceal == "" and col == 1
end) ~= nil)
check("a link to a page is NotesLink, to none NotesLinkMissing", find_mark(1, function(d)
  return d.hl_group == "NotesLink"
end) ~= nil and find_mark(1, function(d)
  return d.hl_group == "NotesLinkMissing"
end) ~= nil)
check("[* ] is strong", find_mark(1, function(d)
  return d.hl_group == "NotesStrong"
end) ~= nil)
page_buffer("private/2026-11-15 見出し.txt", { "見出し", "[*** 大きい]", "[** 小さい]" })
check("a heading gets as many bars as its *s", find_mark(1, function(d)
  return d.virt_text and d.virt_text[1][1] == "▌▌▌ "
end) ~= nil and find_mark(2, function(d)
  return d.virt_text and d.virt_text[1][1] == "▌▌ "
end) ~= nil and find_mark(1, function(d)
  return d.hl_group == "NotesHeading"
end) ~= nil)
page_buffer("private/2026-11-15 見た目.txt", { "見た目", " [A] と [まだ無い] と [* 太字]", "  二段目", "> 引用", " 1. 番号", "code:x.lua", " local a = 1", "[https://example.com 公式]" })
local function dots(row)
  local out = {}
  for _, mk in ipairs(marks_on(row)) do
    if mk[4].virt_text then
      out[#out + 1] = mk[4].virt_text[1][1]
    end
  end
  return out
end
check("each indentation character two cells wide, the deepest with a dot", vim.deep_equal(dots(2), { " ", "•" }), dots(2))
check("a numbered line's dot is a dash", vim.deep_equal(dots(4), { "–" }), dots(4))
check("a URL link shows its title only", find_mark(7, function(d, col)
  return d.conceal == "" and col == 0
end) ~= nil and find_mark(7, function(d)
  return d.hl_group == "NotesUrl"
end) ~= nil)
check("the window conceals off the cursor's line and wraps", vim.wo.conceallevel == 2 and vim.wo.concealcursor == "" and vim.wo.wrap and vim.wo.linebreak and vim.wo.breakindent)
if pcall(vim.treesitter.language.add, "lua") then
  check("a code block is coloured by treesitter", find_mark(6, function(d)
    return d.hl_group and d.hl_group:find("%.lua$")
  end) ~= nil, marks_on(6))
end

local decorate = require("notes.decorate")
local function in_days(n)
  return os.date("%Y-%m-%d", os.time() + n * 86400)
end
local label = decorate.mark_label("date:" .. in_days(3))
check("date: a label with the weekday and how far off", label and label.text:find("^%d+%-%d+%-%d+ %(..-%) · あと3日$") ~= nil and not label.due, label)
label = decorate.mark_label("date:" .. in_days(-2))
check("date: a label filled once its day has come", label and label.text:find("2日前$") ~= nil and label.due, label)
label = decorate.mark_label("closed(2026-11-20 10:00:00):")
check("closed: a label with when", label and label.text == "closed · 2026-11-20 10:00:00", label)

page_buffer("private/2026-11-15 印.txt", { "印", "date:2026-11-28", " todo:牛乳", " done(2026-11-25 10:00:00):卵", "> 引用", "最後" })
local swap_ns = vim.api.nvim_create_namespace("notes_decorate_swaps")
local function swapped(row)
  local out = {}
  for _, mk in ipairs(vim.api.nvim_buf_get_extmarks(0, swap_ns, { row, 0 }, { row, -1 }, { details = true })) do
    out[#out + 1] = mk[4].virt_text[1][1]
  end
  return table.concat(out, "|")
end
vim.api.nvim_win_set_cursor(0, { 6, 0 })
decorate.place_swaps(0, true)
check("off the cursor's line: the label, the boxes with a checked line's time, the quote's bar", swapped(1):find("2026%-11%-28") and swapped(2) == "☐ " and swapped(3) == "☑ |  2026-11-25 10:00" and swapped(4) == "▎ ", { swapped(1), swapped(2), swapped(3), swapped(4) })
vim.api.nvim_win_set_cursor(0, { 3, 0 })
decorate.place_swaps(0)
check("on the cursor's line: the line as written", swapped(2) == "" and swapped(3) ~= "", { swapped(2), swapped(3) })

-- ===== writing =====

local edit = require("notes.edit")
local function enter_at(lines, row, col)
  local e = edit.enter_edit(lines, row, col)
  local line = lines[row]
  return line:sub(1, e.from) .. e.text .. line:sub(e.to + 1)
end
check("Enter keeps the indentation", enter_at({ "t", "  item" }, 2, 6) == "  item\n  ")
check("Enter at a line's start inserts a line break only", enter_at({ "t", "  item" }, 2, 0) == "\n  item")
check("Enter on an empty indented line leaves the outline", enter_at({ "t", "  " }, 2, 2) == "\n")
check("Enter after a code: line goes one deeper", enter_at({ "t", " code:x.js" }, 2, 10) == " code:x.js\n  ")
check("Enter on a check line starts another", enter_at({ "t", " todo:a" }, 2, 7) == " todo:a\n todo:")
check("Enter on a bare check mark takes it away", enter_at({ "t", " todo:" }, 2, 6) == " ")

local buf = page_buffer("private/2026-11-15 書く.txt", { "書く", "a", "\tb", "c", "" })
edit.shift_lines(2, 2, 1, 1)
edit.shift_lines(4, 4, 1, 1)
check("one step deeper: with the line above's character, else a space", vim.deep_equal(vim.api.nvim_buf_get_lines(buf, 1, 4, false), { " a", "\tb", "\tc" }), vim.api.nvim_buf_get_lines(buf, 1, 4, false))
edit.shift_lines(2, 4, -1, 1)
check("one step shallower, over several lines", vim.deep_equal(vim.api.nvim_buf_get_lines(buf, 1, 4, false), { "a", "b", "c" }), vim.api.nvim_buf_get_lines(buf, 1, 4, false))
vim.api.nvim_win_set_cursor(0, { 2, 0 })
vim.cmd("normal 2>>")
check(">> takes a count", vim.deep_equal(vim.api.nvim_buf_get_lines(buf, 1, 3, false), { " a", " b" }), vim.api.nvim_buf_get_lines(buf, 1, 3, false))

vim.api.nvim_win_set_cursor(0, { 4, 0 })
edit.toggle_check()
local c1 = vim.api.nvim_get_current_line()
edit.toggle_check()
local c2 = vim.api.nvim_get_current_line()
edit.toggle_check()
local c3 = vim.api.nvim_get_current_line()
check("the check key: todo:, done(time):, nothing", c1 == "todo:c" and c2:match("^done%(%d+%-%d+%-%d+ %d+:%d+:%d+%):c$") ~= nil and c3 == "c", { c1, c2, c3 })

buf = page_buffer("private/2026-11-15 コード.txt", { "コード", " code:a.sh", "  echo 1", "   echo 2", " 後ろ", "$ ls -la" })
vim.api.nvim_win_set_cursor(0, { 3, 0 })
vim.cmd('normal "ayic')
vim.wait(50)
check("yic: the body without the block's indentation", vim.fn.getreg("a") == "echo 1\n echo 2\n" and vim.fn.getregtype("a") == "V", vim.fn.getreg("a"))
vim.cmd('normal "byac')
check("yac: the code: line and the body as they are", vim.fn.getreg("b") == " code:a.sh\n  echo 1\n   echo 2\n", vim.fn.getreg("b"))
vim.api.nvim_win_set_cursor(0, { 6, 0 })
vim.cmd('normal "cyic')
vim.wait(50)
check("yic on a command line: the command", vim.fn.getreg("c") == "ls -la", vim.fn.getreg("c"))
vim.api.nvim_win_set_cursor(0, { 3, 0 })
vim.cmd("normal dic")
check("dic: the body lines go", vim.deep_equal(vim.api.nvim_buf_get_lines(buf, 1, 3, false), { " code:a.sh", " 後ろ" }), vim.api.nvim_buf_get_lines(buf, 0, -1, false))

buf = page_buffer("private/2026-11-15 貼る.txt", { "貼る", "", "" })
vim.api.nvim_win_set_cursor(0, { 2, 0 })
vim.fn.setreg("a", { "# 見出し", "- 項目" }, "l")
vim.cmd('normal "ap')
check("p converts Markdown", vim.deep_equal(vim.api.nvim_buf_get_lines(buf, 2, 4, false), { "[**** 見出し]", " 項目" }), vim.api.nvim_buf_get_lines(buf, 0, -1, false))
check("p leaves the register as it was", vim.fn.getreg("a") == "# 見出し\n- 項目\n")

-- ===== link completion =====

local complete = require("notes.complete")
local parsed = parser.parse_page("t\nこれは [Neo と", { inline = false })[2]
local ctx = complete.context_at("これは [Neo と", #"これは [Neo", parsed)
check("completion: the bracket being typed", ctx and ctx.kind == "link" and ctx.query == "Neo" and ctx.from == #"これは " and ctx.to == #"これは [Neo", ctx)
ctx = complete.context_at("[Neo vim] と", #"[Neo", parsed)
check("completion: a bracket closed after the cursor is the whole of it", ctx and ctx.query == "Neo vim" and ctx.to == #"[Neo vim]", ctx)
ctx = complete.context_at("a #ta", 5, parsed)
check("completion: the tag being typed", ctx and ctx.kind == "tag" and ctx.query == "ta", ctx)
local ranked = complete.rank({
  { title = "Neovim の設定", updated = 1, linked_at = 1 },
  { title = "Neovim", updated = 2, linked_at = 0 },
  { title = "neovim plugin", updated = 3, linked_at = 5 },
  { title = "Nevim typo", updated = 4, linked_at = 9 },
}, "neovim", "link", "今のページ")
check("completion: every word first, the most recently linked first; one-edit matches after; not the title typed", vim.deep_equal(vim.tbl_map(function(t)
  return t.title
end, ranked), { "neovim plugin", "Neovim の設定", "Nevim typo" }), ranked)

-- ===== the preview =====

page_buffer("private/2026-11-15 プレビュー.txt", { "プレビュー", "[A] を見る" })
vim.api.nvim_win_set_cursor(0, { 2, 1 })
edit.preview()
local floats = vim.tbl_filter(function(w)
  return vim.api.nvim_win_get_config(w).relative ~= ""
end, vim.api.nvim_list_wins())
check("<Space>nv: the linked page's first lines in a floating window", #floats == 1 and vim.api.nvim_buf_get_lines(vim.api.nvim_win_get_buf(floats[1]), 0, 1, false)[1] == "A", floats)
vim.cmd("enew!")

-- ===== local's ground =====

-- catppuccin is not on this test's runtimepath: local's colorscheme is missing, and nothing changes.
local theme = require("notes.theme")
vim.cmd.colorscheme("default")
theme.set_local(true)
local shown = vim.g.colors_name
theme.set_local(false)
check("local: without its colorscheme, the one in use stays", shown == "default" and vim.g.colors_name == "default", shown)
-- A colorscheme standing in for it: switched to, and back from.
theme.LOCAL_COLORSCHEME = "blue"
local guicursor = vim.o.guicursor
theme.set_local(true)
shown = vim.g.colors_name
local local_guicursor = vim.o.guicursor
theme.set_local(false)
check("local: its colorscheme while local is in front, the one before after", shown == "blue" and vim.g.colors_name == "default", { shown, vim.g.colors_name })
check("local: the cursor's box in NotesCursor, the cursor as before after", local_guicursor:find("a:NotesCursor$") ~= nil and vim.o.guicursor == guicursor, { local_guicursor, vim.o.guicursor })
vim.fn.delete(store.links_file())

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
