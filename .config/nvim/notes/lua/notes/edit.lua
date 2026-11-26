-- Writing in a page: the keys that make an ordinary buffer write like stderr-blog's
-- browser editor (tools/cosense/editor/commands.js, input.js, checkbox.js), and the
-- window settings a page is read with. Where the editor's behaviour is ported, the
-- function names the one it follows.

local parser = require("notes.parser")
local marks = require("notes.marks")

local M = {}

local function page_lines(buf)
  return vim.api.nvim_buf_get_lines(buf or 0, 0, -1, false)
end

local function parsed_line(lines, row)
  return parser.parse_page(table.concat(lines, "\n"), { inline = false })[row]
end

-- The line's indentation, as written (spaces, tabs, wide spaces).
local function indent_of(line)
  return vim.fn.strcharpart(line, 0, parser.count_indent(line))
end

-- Replace bytes [from, to) of line `row` (1-based) with `text` (may hold newlines) and put the cursor after it.
local function replace(row, from, to, text)
  local new = vim.split(text, "\n", { plain = true })
  vim.api.nvim_buf_set_text(0, row - 1, from, row - 1, to, new)
  local last = row + #new - 1
  local col = #new[#new] + (#new == 1 and from or 0)
  vim.api.nvim_win_set_cursor(0, { last, col })
end

-- ===== Enter (commands.js `enter`) =====

--- What Enter at byte `col` of line `row` inserts: { from, to, text } (bytes of that line).
function M.enter_edit(lines, row, col)
  local line = lines[row]
  local indent = indent_of(line)
  if col == 0 then
    return { from = col, to = col, text = "\n" }
  end
  -- A check line: Enter after its mark starts the next check line; on one that has
  -- nothing but its mark, Enter takes the mark away.
  local check = row >= 2 and marks.check_of(line)
  if check and col >= check.finish then
    if check.finish == #line then
      return { from = check.at, to = #line, text = "" }
    end
    return { from = col, to = col, text = "\n" .. indent .. marks.check_mark(false) }
  end
  local parsed = parsed_line(lines, row)
  local block = parsed.code_block or parsed.table_block
  -- Into the block, one deeper than its code: / table: line (a fence's body needs no indent of its own).
  if block and block.start and not block.fence and col == #line then
    return { from = col, to = col, text = "\n" .. indent .. " " }
  end
  -- An indented line with nothing on it: Enter leaves the outline.
  if #indent > 0 and #indent == #line and not parsed.code_block then
    return { from = 0, to = col, text = "\n" }
  end
  return { from = col, to = col, text = "\n" .. indent:sub(1, col) }
end

function M.enter()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local e = M.enter_edit(page_lines(), row, col)
  replace(row, e.from, e.to, e.text)
end

--- o: a new line under this one, made as Enter at the line's end makes it.
function M.open_below()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local lines = page_lines()
  local line = lines[row]
  local e = M.enter_edit(lines, row, #line)
  if e.text == "" or e.from == 0 then
    -- On an empty indented line or a bare check mark Enter edits this line; o still opens one.
    e = { from = #line, to = #line, text = "\n" .. (e.from == 0 and "" or indent_of(line)) }
  end
  replace(row, e.from, e.to, e.text)
  vim.cmd("startinsert!")
end

--- O: a new line above this one, as deep as this one.
function M.open_above()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local indent = indent_of(vim.api.nvim_get_current_line())
  vim.api.nvim_buf_set_lines(0, row - 1, row - 1, false, { indent })
  vim.api.nvim_win_set_cursor(0, { row, #indent })
  vim.cmd("startinsert!")
end

-- ===== one step deeper / shallower =====

-- The character a line is indented with one step more: its own, else the line above's, else a space.
local function step_char(lines, row)
  for r = row, 1, -1 do
    local first = vim.fn.strcharpart(lines[r], 0, 1)
    if parser.count_indent(lines[r]) > 0 then
      return first
    end
    if r < row then
      break
    end
  end
  return " "
end

--- Lines `first..last` one step deeper (delta 1) or shallower (-1), `count` times
--- (commands.js `shiftLines`: an empty line stays put in a move of several lines; a line
--- that cannot go further left stops the whole move).
function M.shift_lines(first, last, delta, count)
  for _ = 1, count or 1 do
    local lines = page_lines()
    local changes = {}
    for r = first, last do
      local line = lines[r]
      if delta > 0 then
        if not parser.is_empty_line(line) or first == last then
          changes[#changes + 1] = { r, 0, 0, step_char(lines, r) }
        end
      elseif parser.count_indent(line) > 0 then
        changes[#changes + 1] = { r, 0, #vim.fn.strcharpart(line, 0, 1), "" }
      elseif not parser.is_empty_line(line) then
        return
      end
    end
    for _, c in ipairs(changes) do
      vim.api.nvim_buf_set_text(0, c[1] - 1, c[2], c[1] - 1, c[3], { c[4] })
    end
  end
end

--- <Tab> / <S-Tab> in insert mode, called from nvim-cmp's mapping when it shows no
--- candidates (plugin.d/lsp.d/cmp.rc.lua): the line one step deeper or shallower,
--- wherever the cursor is in it. False outside a page.
function M.shift(delta)
  if vim.bo.filetype ~= "notes" then
    return false
  end
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local before = #vim.api.nvim_get_current_line()
  M.shift_lines(row, row, delta, 1)
  local moved = #vim.api.nvim_get_current_line() - before
  vim.api.nvim_win_set_cursor(0, { row, math.max(0, col + moved) })
  return true
end

-- The operator behind > and < (counts and motions included).
function M.shift_operator(kind)
  local first, last = vim.fn.line("'["), vim.fn.line("']")
  M.shift_lines(first, last, vim.g.notes_shift_delta or 1, 1)
  return kind
end

-- ===== [ and ] (input.js `bracketComplete` and the step over a ]) =====

function M.open_bracket()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local lines = page_lines()
  local parsed = parsed_line(lines, row)
  local next = lines[row]:sub(col + 1, col + 1)
  if not parsed.code_block and not parsed.cli and (next == "" or next:match("%s")) then
    return "[]<C-g>U<Left>"
  end
  return "["
end

function M.close_bracket()
  local _, col = unpack(vim.api.nvim_win_get_cursor(0))
  return vim.api.nvim_get_current_line():sub(col + 1, col + 1) == "]" and "<C-g>U<Right>" or "]"
end

-- ===== check lines (checkbox.js `checkKey`) =====

--- No mark → todo: → done(…): → no mark, on the cursor's line.
function M.toggle_check()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  if row < 2 then
    return
  end
  local line = vim.api.nvim_get_current_line()
  local check = marks.check_of(line)
  local from, to, mark
  if check then
    from, to, mark = check.at, check.finish, check.checked and "" or marks.check_mark(true)
  else
    from = #line:match("^%s*")
    to, mark = from, marks.check_mark(false)
  end
  vim.api.nvim_buf_set_text(0, row - 1, from, row - 1, to, { mark })
  if col >= to then
    col = col + #mark - (to - from)
  elseif col >= from and mark ~= "" and not check then
    col = from + #mark -- a cursor at the mark's place is left after it
  end
  vim.api.nvim_win_set_cursor(0, { row, math.max(0, math.min(col, #vim.api.nvim_get_current_line())) })
end

-- ===== ic / ac: a code block or a command line =====

-- What is around the cursor's line: { kind = "code", start, last } (the code: line and the
-- block's last line), { kind = "cli", row, from } (the byte after "$ "), or nil.
local function block_at(row)
  local page = parser.parse_page(table.concat(page_lines(), "\n"), { inline = false })
  local line = page[row]
  if line.code_block then
    local start = row
    while start > 1 and not page[start].code_block.start do
      start = start - 1
    end
    local at = parser.code_block_at(page, start)
    -- The body ends before a fence's closing line; the outer block takes that line too.
    return { kind = "code", start = start, last = at.last, body_last = start + #at.body, body = at.body, fence = page[start].code_block.fence }
  end
  if line.cli then
    local at = line.text:find("[%$%%] ")
    return { kind = "cli", row = row, from = at + 1 }
  end
end

--- Select the block for an operator or in visual mode: `inner` is a code block's body or
--- the command after "$ "; the outer one adds the code: line, or is the command's line.
function M.select(inner)
  local b = block_at(vim.fn.line("."))
  if not b then
    return
  end
  if b.kind == "code" then
    local first = inner and b.start + 1 or b.start
    local last = inner and b.body_last or b.last
    if first > last then
      return
    end
    vim.cmd(("normal! %dGV%dG"):format(first, last))
  elseif inner then
    vim.api.nvim_win_set_cursor(0, { b.row, b.from })
    vim.cmd("normal! vg_")
  else
    vim.cmd("normal! V")
  end
end

-- yic: the body without the block's indentation (decorate.js `codeBlockAt`, what the copy button copies).
local function yank_body(b, register)
  local body = b.body
  if #body == 0 then
    return
  end
  vim.fn.setreg(register, body, "l")
  if register == '"' or register == "+" or register == "*" then
    vim.fn.setreg("0", body, "l")
  end
end

-- cic: the body replaced by one empty line a step deeper than the code: line (as deep as a
-- fence's ```), to type in.
local function change_body(b)
  local indent = indent_of(vim.api.nvim_buf_get_lines(0, b.start - 1, b.start, false)[1]) .. (b.fence and "" or " ")
  vim.api.nvim_buf_set_lines(0, b.start, b.body_last, false, { indent })
  vim.api.nvim_win_set_cursor(0, { b.start + 1, #indent })
  vim.cmd("startinsert!")
end

--- The operator-pending ic: a yank or a change of a code block's body is done here (the
--- operator is cancelled); anything else gets the body selected.
function M.inner_for_operator()
  local b = block_at(vim.fn.line("."))
  local op, register = vim.v.operator, vim.v.register
  if b and b.kind == "code" and (op == "y" or op == "c") then
    vim.schedule(function()
      if op == "y" then
        yank_body(b, register)
      else
        change_body(b)
      end
    end)
    return "<Esc>"
  end
  return "<Cmd>lua require('notes.edit').select(true)<CR>"
end

-- ===== paste (paste.lua) =====

local paste = require("notes.paste")

-- `text` converted for a paste that puts it at byte `col` of line `row`, or for lines
-- put below (`linewise`, after) or above line `row`. Lines put under a code block's,
-- a table's or a command's line are left as they are, as anything pasted into one is.
local function converted(text, row, col, linewise, after)
  local lines = page_lines()
  if linewise then
    local parsed = parsed_line(lines, row)
    if parsed.code_block or parsed.table_block or parsed.cli then
      return text
    end
    local at = after and row + 1 or row
    table.insert(lines, at, "")
    row, col = at, 0
  end
  return paste.transform(lines, row, col, text)
end

--- p / P (and in visual mode): the register's text converted, then put by Vim itself.
function M.put(cmd, visual)
  local register = vim.v.register
  local count = vim.v.count1
  local saved, regtype = vim.fn.getreg(register, 1, true), vim.fn.getregtype(register)
  local function run()
    vim.cmd(("normal! %s\"%s%d%s"):format(visual and "gv" or "", register, count, cmd))
  end
  if regtype:sub(1, 1) == "\22" or #saved == 0 then
    return run()
  end
  local linewise = regtype == "V"
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  if visual then
    local start = vim.fn.getpos("'<")
    row, col = start[2], start[3] - 1
    linewise = linewise or vim.fn.visualmode() == "V"
  elseif cmd == "p" and not linewise then
    local line = vim.api.nvim_get_current_line()
    col = #line == 0 and 0 or col + #vim.fn.strcharpart(line:sub(col + 1), 0, 1)
  end
  local text = converted(table.concat(saved, "\n"), row, col, linewise, cmd == "p")
  local new = vim.split(text, "\n", { plain = true })
  if linewise and #new > 1 and new[#new] == "" then
    table.remove(new)
  end
  vim.fn.setreg(register, new, linewise and "l" or "c")
  run()
  vim.fn.setreg(register, saved, regtype)
end

-- Pasting from the terminal (Cmd+V): converted in a page, in insert and normal mode.
local function wrap_paste()
  local original = vim.paste
  vim.paste = function(lines, phase)
    local mode = vim.api.nvim_get_mode().mode
    if phase == -1 and vim.bo.filetype == "notes" and (mode:find("^i") or mode == "n") then
      local row, col = unpack(vim.api.nvim_win_get_cursor(0))
      if mode == "n" then
        local line = vim.api.nvim_get_current_line()
        col = #line == 0 and 0 or col + #vim.fn.strcharpart(line:sub(col + 1), 0, 1)
      end
      lines = vim.split(converted(table.concat(lines, "\n"), row, col, false), "\n", { plain = true })
    end
    return original(lines, phase)
  end
end

-- ===== the preview of a link's page =====

function M.preview()
  local page = require("notes.page")
  local store = require("notes.store")
  local node = page.node_under_cursor()
  local title = node and not node.project and node.page
  if not title then
    return
  end
  local found = store.find(title)
  local lines
  if found then
    lines = vim.split(store.text_of(found.rel), "\n", { plain = true })
    if lines[#lines] == "" then
      table.remove(lines)
    end
  else
    lines = { title, "", "まだページがありません。このリンク名を書いているページ:" }
    for _, p in ipairs(store.referrers(title)) do
      lines[#lines + 1] = " " .. p.title
    end
  end
  local width = math.min(80, vim.o.columns - 4)
  local buf, win = vim.lsp.util.open_floating_preview(lines, "", {
    focus_id = "notes_preview",
    max_width = width,
    max_height = math.min(20, math.floor(vim.o.lines / 2)),
    wrap = true,
    close_events = { "CursorMoved", "CursorMovedI", "InsertEnter", "BufLeave" },
  })
  vim.bo[buf].tabstop = 1
  vim.wo[win][0].conceallevel = 2
  vim.wo[win][0].concealcursor = ""
  vim.wo[win][0].linebreak = false
  vim.wo[win][0].breakindent = true
  require("notes.decorate").render(buf)
end

-- ===== putting it on a page =====

--- The window settings a page is read with: long lines wrapped at the window's edge and
--- hung at their indentation, the notation concealed off the cursor's line.
--- linebreak stays off: 'breakat' takes ASCII only, so in Japanese text it breaks early
--- at the last half-width space instead of at 、 or 。.
function M.window_options()
  vim.opt_local.wrap = true
  vim.opt_local.linebreak = false
  vim.opt_local.breakindent = true
  vim.opt_local.conceallevel = 2
  vim.opt_local.concealcursor = ""
  vim.opt_local.list = false
end

-- The rule decorate.lua puts above the title is a virtual line above the first line, which
-- Neovim shows only while the window's 'topfill' says so, and moving to the top (gg, k)
-- sets that to 0. Whenever the window shows the first line, it is set to show the rule.
local function show_rule_above_title()
  local view = vim.fn.winsaveview()
  if view.topline == 1 and view.topfill == 0 then
    vim.fn.winrestview({ topfill = 1 })
  end
end

function M.attach(buf)
  vim.bo[buf].tabstop = 1 -- each indentation character is drawn two cells wide by decorate.lua
  vim.api.nvim_create_autocmd("BufWinEnter", { buffer = buf, callback = M.window_options })
  vim.api.nvim_create_autocmd({ "BufWinEnter", "WinScrolled", "CursorMoved" }, { buffer = buf, callback = show_rule_above_title })
  if vim.api.nvim_get_current_buf() == buf then
    M.window_options()
  end
  local map = function(mode, lhs, rhs, desc, opts)
    vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", { buffer = buf, silent = true, desc = "notes: " .. desc }, opts or {}))
  end
  -- Counted moves go by lines of the file, plain ones by the screen's rows.
  for _, key in ipairs({ "j", "k" }) do
    map({ "n", "x" }, key, function()
      return vim.v.count == 0 and ("g" .. key) or key
    end, "画面の行で移動", { expr = true })
  end
  map("i", "<CR>", M.enter, "改行（インデントを引き継ぐ）")
  map("n", "o", M.open_below, "下に行を開く")
  map("n", "O", M.open_above, "上に行を開く")
  for key, delta in pairs({ [">"] = 1, ["<"] = -1 }) do
    map("n", key, function()
      vim.g.notes_shift_delta = delta
      vim.o.operatorfunc = "v:lua.require'notes.edit'.shift_operator"
      return "g@"
    end, "1 段深く / 浅く", { expr = true, nowait = true })
    -- The second > of >> (and < of <<): the cursor's line, with the count.
    map("o", key, function()
      return vim.v.operator == "g@" and "_" or "<Esc>"
    end, "この行", { expr = true })
    map("x", key, function()
      local a, b = vim.fn.line("v"), vim.fn.line(".")
      local count = vim.v.count1
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
      M.shift_lines(math.min(a, b), math.max(a, b), delta, count)
    end, "選んだ行を 1 段深く / 浅く")
  end
  map("i", "[", M.open_bracket, "[ と ] を入れる", { expr = true })
  map("i", "]", M.close_bracket, "] を打つか越える", { expr = true })
  map("n", "<Leader>nt", M.toggle_check, "チェック行を切り替える")
  map("n", "<Leader>nv", M.preview, "リンク先のプレビュー")
  map("o", "ic", M.inner_for_operator, "コードブロックの本文", { expr = true })
  map("o", "ac", "<Cmd>lua require('notes.edit').select(false)<CR>", "コードブロック")
  map("x", "ic", ":<C-u>lua require('notes.edit').select(true)<CR>", "コードブロックの本文")
  map("x", "ac", ":<C-u>lua require('notes.edit').select(false)<CR>", "コードブロック")
  map("n", "p", function()
    M.put("p", false)
  end, "貼り付け（記法に変換）")
  map("n", "P", function()
    M.put("P", false)
  end, "貼り付け（記法に変換）")
  map("x", "p", ":<C-u>lua require('notes.edit').put('p', true)<CR>", "貼り付け（記法に変換）")
  map("x", "P", ":<C-u>lua require('notes.edit').put('P', true)<CR>", "貼り付け（記法に変換）")
end

function M.setup()
  wrap_paste()
end

return M
