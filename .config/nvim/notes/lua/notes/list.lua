-- The card list: one buffer showing the notes as cards under the days they were
-- created and last updated on, after the pinned pages and the pages whose
-- "date:" has come, as stderr-blog's editor lists them (tools/cosense/views/list.js).
-- The same buffer shows a page's related pages. Search and choosing a page to merge
-- into are ddu lists (lua/notes/ddu.lua).

local parser = require("notes.parser")
local marks = require("notes.marks")
local store = require("notes.store")
local theme = require("notes.theme")

local M = {}

local ns = vim.api.nvim_create_namespace("notes_list")
local ns_sel = vim.api.nvim_create_namespace("notes_list_selected")
local ns_label = vim.api.nvim_create_namespace("notes_list_labels")

-- A card: its title on up to TITLE_ROWS rows, the page's first lines on the rows left, and
-- the badges on the last row (TITLE_ROWS as stderr-blog's src/styles/cosense-cards.css
-- `.page-list-item .title` clamps it).
local CARD_W, GAP, INDENT, CARD_H, TITLE_ROWS = 45, 2, 2, 5, 3
local DAYS_PER_LOAD = 30
local LABEL_CHARS = "asdfghjklqwertyuiopzxcvbnm"
local WEEKDAYS = { "日", "月", "火", "水", "木", "金", "土" }

local states = {} -- buf -> state of each list buffer

function M._fit(s, w)
  s = s:gsub("[\t\r\n]", " ")
  if vim.fn.strdisplaywidth(s) > w then
    local out, n = {}, 0
    for _, ch in ipairs(vim.fn.split(s, "\\zs")) do
      local cw = vim.fn.strdisplaywidth(ch)
      if n + cw > w - 1 then
        break
      end
      out[#out + 1], n = ch, n + cw
    end
    s = table.concat(out) .. "…"
  end
  return s .. string.rep(" ", w - vim.fn.strdisplaywidth(s))
end
local fit = M._fit

--- `s` broken into rows at most `w` cells wide, at most `max_rows` of them, the last ending
--- in "…" when the rest does not fit. A run of Latin letters, digits and the like breaks
--- only at a space, as a browser breaks it, unless it is wider than a row by itself; any
--- other character (Japanese) may end a row.
function M._wrap(s, w, max_rows)
  s = s:gsub("[\t\r\n]", " ")
  local units = {}
  for _, ch in ipairs(vim.fn.split(s, "\\zs")) do
    local last = units[#units]
    if ch:match("^[%w%p]$") and last and last:match("^[%w%p]+$") then
      units[#units] = last .. ch
    else
      units[#units + 1] = ch
    end
  end
  local rows, row, n = {}, {}, 0
  local function push()
    rows[#rows + 1] = table.concat(row)
    row, n = {}, 0
  end
  local function add(unit)
    local uw = vim.fn.strdisplaywidth(unit)
    if n == 0 and unit == " " then
      return -- a row does not start with the space it was broken at
    end
    if n + uw > w then
      if uw > w then
        -- A word wider than a row: break it where the row ends.
        for _, ch in ipairs(vim.fn.split(unit, "\\zs")) do
          add(ch)
        end
        return
      end
      push()
      if unit == " " then
        return
      end
    end
    row[#row + 1], n = unit, n + uw
  end
  for _, unit in ipairs(units) do
    add(unit)
  end
  if n > 0 then
    push()
  end
  if #rows > max_rows then
    local rest = table.concat(vim.list_slice(rows, max_rows), " ")
    rows = vim.list_slice(rows, 1, max_rows)
    rows[max_rows] = vim.trim(M._fit(rest, w))
  end
  return rows
end

local function ymd(t)
  return os.date("%Y-%m-%d", t)
end

local function day_heading(day)
  local y, m, d = day:match("(%d+)-(%d+)-(%d+)")
  local w = os.date("*t", os.time({ year = tonumber(y), month = tonumber(m), day = tonumber(d), hour = 12 })).wday
  return ("%s (%s)"):format(day, WEEKDAYS[w])
end

-- A card's `n` text lines: the page's first lines without the page marks, notation removed.
local function card_lines(page, n)
  local out = {}
  for _, d in ipairs(page.descriptions or {}) do
    if not marks.is_mark(d) then
      out[#out + 1] = parser.nodes_to_text(parser.parse_line(d))
      if #out == n then
        break
      end
    end
  end
  return out
end

-- A published page's badge, drawn as a filled label (spaces inside the fill).
local PUBLIC_LABEL = " public "

function M._is_public(page)
  return page.store == "remote" and page.private == false
end

local function badges(card, today)
  local page, out = card.page, {}
  if page.date then
    local m, d = page.date:match("%d+-(%d+)-(%d+)")
    out[#out + 1] = ("%d/%d %s"):format(tonumber(m), tonumber(d), marks.relative_day(page.date, today))
  end
  if card.update_only then
    out[#out + 1] = "↻ 更新"
  end
  if page.pin and page.pin > 0 then
    out[#out + 1] = "pin"
  end
  if M._is_public(page) then
    out[#out + 1] = PUBLIC_LABEL
  end
  if page.closed then
    out[#out + 1] = "closed"
  end
  return table.concat(out, "  ")
end

-- ===== what the list shows =====

local function sections(st, pages, today)
  if st.mode == "related" then
    local r = store.related(st.related_of, pages)
    local out = {}
    local function as_cards(list)
      local cards = {}
      for _, p in ipairs(list) do
        cards[#cards + 1] = { page = p }
      end
      return cards
    end
    if #r.links > 0 then
      out[#out + 1] = { heading = "Links", cards = as_cards(r.links) }
    end
    for _, g in ipairs(r.groups) do
      out[#out + 1] = { heading = g.link, cards = as_cards(g.pages) }
    end
    if #r.new_links > 0 then
      local cards = {}
      for _, title in ipairs(r.new_links) do
        cards[#cards + 1] = { page = { title = title, descriptions = {}, missing = true } }
      end
      out[#out + 1] = { heading = "New Links", cards = cards }
    end
    table.insert(out, 1, { heading = ("「%s」の関連ページ"):format(st.related_of.title), cards = {} })
    return out, false
  end

  local mine = vim.tbl_filter(function(p)
    return p.store == st.store
  end, pages)
  local out = {}
  local pinned = vim.tbl_filter(function(p)
    return p.pin > 0
  end, mine)
  table.sort(pinned, function(a, b)
    return a.pin < b.pin
  end)
  if #pinned > 0 then
    local cards = {}
    for _, p in ipairs(pinned) do
      cards[#cards + 1] = { page = p }
    end
    out[#out + 1] = { heading = "Pinned", cards = cards }
  end
  local due = vim.tbl_filter(function(p)
    return p.pin == 0 and not p.closed and p.date and p.date <= today
  end, mine)
  table.sort(due, function(a, b)
    if a.date ~= b.date then
      return a.date < b.date
    end
    return a.updated > b.updated
  end)
  if #due > 0 then
    local cards = {}
    for _, p in ipairs(due) do
      cards[#cards + 1] = { page = p }
    end
    out[#out + 1] = { heading = "今日まで", cards = cards }
  end
  local is_due = {}
  for _, p in ipairs(due) do
    is_due[p.rel] = true
  end
  -- A page is listed under the day it was created and, sorted by Modified, the day it was last updated.
  local by_day = {}
  local rest = vim.tbl_filter(function(p)
    return p.pin == 0 and not is_due[p.rel]
  end, mine)
  table.sort(rest, function(a, b)
    if a[st.sort] ~= b[st.sort] then
      return a[st.sort] > b[st.sort]
    end
    return a.updated > b.updated
  end)
  for _, p in ipairs(rest) do
    local created = ymd(p.created)
    local days = { created }
    if st.sort == "updated" and ymd(p.updated) ~= created then
      days[#days + 1] = ymd(p.updated)
    end
    for _, day in ipairs(days) do
      by_day[day] = by_day[day] or {}
      table.insert(by_day[day], { page = p, update_only = day ~= created })
    end
  end
  local days = vim.tbl_keys(by_day)
  table.sort(days, function(a, b)
    return a > b
  end)
  for i = 1, math.min(#days, st.shown_days) do
    out[#out + 1] = { heading = day_heading(days[i]), cards = by_day[days[i]] }
  end
  return out, #days > st.shown_days
end

-- ===== drawing =====

local function render(st)
  local buf = st.buf
  local width = vim.api.nvim_win_get_width(vim.fn.bufwinid(buf) ~= -1 and vim.fn.bufwinid(buf) or 0)
  local per_row = math.max(1, math.floor((width - INDENT + GAP) / (CARD_W + GAP)))
  local today = os.date("%Y-%m-%d")
  st.pages = store.pages()
  local secs, more = sections(st, st.pages, today)
  st.more = more

  local lines, hls, cards = {}, {}, {}
  local function add(text, hl)
    lines[#lines + 1] = text
    if hl then
      hls[#hls + 1] = { #lines - 1, 0, #text, hl }
    end
  end

  -- The band: which store this is, across the whole width, in its color.
  local counts = { remote = 0, ["local"] = 0 }
  for _, p in ipairs(st.pages) do
    counts[p.store] = counts[p.store] + 1
  end
  local other = st.store == "remote" and "local" or "remote"
  lines[1] = (" %s  %d pages    Tab: %s %d    並び: %s"):format(st.store:upper(), counts[st.store], other, counts[other], st.sort == "created" and "Created" or "Modified")
  st.band = st.store == "local" and "NotesBandLocal" or "NotesBandRemote"
  -- The keys, each with what it does: the key in the accent, so that it is found at a glance.
  local function help(keys)
    local parts = {}
    for _, kv in ipairs(keys) do
      local start = #table.concat(parts)
      parts[#parts + 1] = kv[1] .. " " .. kv[2] .. "  "
      hls[#hls + 1] = { #lines, start, start + #kv[1], "NotesHelpKey" }
      hls[#hls + 1] = { #lines, start + #kv[1], start + #parts[#parts], "NotesHelp" }
    end
    lines[#lines + 1] = table.concat(parts)
  end
  help({ { "hjkl", "移動" }, { "<CR>", "開く" }, { "f", "文字で開く" }, { "Tab", "remote/local" }, { "/", "検索" }, { "c", "新規" }, { "s", "並び" } })
  help({ { "x", "closed" }, { "p", "pin" }, { "t", "date" }, { "v", "公開/非公開" }, { "m", "マージ" }, { "D", "削除" } })

  for _, sec in ipairs(secs) do
    add("")
    add(sec.heading, "NotesHeading")
    for i = 1, #sec.cards, per_row do
      local top = #lines
      local row = {}
      for r = 1, CARD_H do
        row[r] = string.rep(" ", INDENT)
      end
      local last_j = math.min(i + per_row - 1, #sec.cards)
      for j = i, last_j do
        local card = sec.cards[j]
        local page = card.page
        local title = M._wrap(page.title, CARD_W - 2, TITLE_ROWS)
        local text = card_lines(page, CARD_H - 1 - #title)
        local cells = {}
        for r = 1, CARD_H - 1 do
          cells[r] = r <= #title and title[r] or text[r - #title] or ""
        end
        cells[CARD_H] = badges(card, today)
        local col = #row[1]
        for r = 1, CARD_H do
          local start = #row[r]
          local body = fit(cells[r], CARD_W - 2)
          row[r] = row[r] .. "▎ " .. body
          local bar = #"▎ "
          local is_title, is_badges = r <= #title, r == CARD_H
          local base
          if page.closed then
            base = is_title and "NotesCardClosedTitle" or "NotesCardClosed"
          else
            base = is_title and "NotesCardTitle" or is_badges and "NotesCardBadge" or "NotesCard"
            if is_badges and page.date and page.date <= today then
              base = "NotesCardDue"
            end
          end
          local public = M._is_public(page)
          if public and is_title then
            base = "NotesCardPublicTitle"
          end
          hls[#hls + 1] = { top + r - 1, start, start + bar, page.closed and "NotesCardClosedBar" or "NotesCardBar" }
          hls[#hls + 1] = { top + r - 1, start + bar, start + bar + #body, base }
          local label_at = public and is_badges and body:find(PUBLIC_LABEL, 1, true)
          if label_at then
            hls[#hls + 1] = { top + r - 1, start + bar + label_at - 1, start + bar + label_at - 1 + #PUBLIC_LABEL, "NotesCardPublicLabel", 150 }
          end
          if j < last_j then
            row[r] = row[r] .. string.rep(" ", GAP)
          end
        end
        cards[#cards + 1] = { page = page, line = top + 1, col = col }
      end
      vim.list_extend(lines, row)
      lines[#lines + 1] = ""
    end
  end
  if more then
    add("")
    add("（下へ移動すると続きを読み込みます）", "NotesHelp")
  end
  add("")

  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].modified = false
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  vim.api.nvim_buf_set_extmark(buf, ns, 0, 0, { line_hl_group = st.band })
  for _, h in ipairs(hls) do
    pcall(vim.api.nvim_buf_set_extmark, buf, ns, h[1], h[2], { end_col = h[3], hl_group = h[4], priority = h[5] })
  end
  st.cards = cards
end

local function select(st, i, move_cursor)
  st.cur = math.max(1, math.min(i or 1, #st.cards))
  vim.api.nvim_buf_clear_namespace(st.buf, ns_sel, 0, -1)
  local c = st.cards[st.cur]
  if not c then
    return
  end
  for r = 0, CARD_H - 1 do
    vim.api.nvim_buf_set_extmark(st.buf, ns_sel, c.line - 1 + r, c.col, { end_col = c.col + #"▎", hl_group = "NotesCardSelected", priority = 200 })
  end
  if move_cursor ~= false then
    local win = vim.fn.bufwinid(st.buf)
    if win ~= -1 then
      vim.api.nvim_win_set_cursor(win, { c.line, c.col })
    end
  end
end

--- The card at, or nearest to, a position in the buffer (1-based line, 0-based byte column).
local function nearest_card(st, line, col)
  local best, bd = nil, math.huge
  for i, c in ipairs(st.cards) do
    local rows = line < c.line and c.line - line or line >= c.line + CARD_H and line - (c.line + CARD_H - 1) or 0
    local cols = col < c.col and c.col - col or col >= c.col + CARD_W + GAP and col - (c.col + CARD_W + GAP - 1) or 0
    local d = rows * 1000 + cols
    if d < bd then
      best, bd = i, d
    end
  end
  return best
end

--- Draw again where the list was: the window keeps its scroll position and cursor, and the card
--- there is selected. A card that moved (closed, pinned, dated, edited) is not followed, since
--- following it would carry the view off to wherever it went.
local function redraw(st)
  local win = vim.fn.bufwinid(st.buf)
  local view = win ~= -1 and vim.api.nvim_win_call(win, vim.fn.winsaveview) or nil
  render(st)
  if not view then
    return select(st, st.cur, false)
  end
  vim.api.nvim_win_call(win, function()
    vim.fn.winrestview(view)
  end)
  local cursor = vim.api.nvim_win_get_cursor(win)
  select(st, nearest_card(st, cursor[1], cursor[2]) or 1, false)
end

-- The card nearest the cursor in direction (dr, dc): rows first, then columns.
local function move(st, dr, dc)
  local c = st.cards[st.cur]
  if not c then
    return
  end
  local best, bd = nil, math.huge
  for i, o in ipairs(st.cards) do
    local r, col = o.line - c.line, o.col - c.col
    if (dr ~= 0 and r * dr > 0) or (dc ~= 0 and r == 0 and col * dc > 0) then
      local d = math.abs(r) * 1000 + math.abs(col)
      if d < bd then
        best, bd = i, d
      end
    end
  end
  if best then
    select(st, best)
  end
end

local function current(st)
  local c = st.cards[st.cur]
  return c and c.page
end

-- ===== actions =====

local function after_change(st)
  store.schedule_sync()
  redraw(st)
end

local function open_page(page)
  if page.missing then
    require("notes.page").open_title(page.title, "remote")
  else
    vim.cmd.edit(vim.fn.fnameescape(store.abs(page.rel)))
  end
end

local function ask_title(prompt, default)
  local ok, title = pcall(vim.fn.input, { prompt = prompt, default = default or "", cancelreturn = "" })
  title = ok and parser.trim(title) or ""
  return title ~= "" and title or nil
end

local function confirm(question)
  return vim.fn.confirm(question, "&Yes\n&No", 2) == 1
end

local function warn(msg)
  vim.notify("notes: " .. msg, vim.log.levels.WARN)
end

local actions = {}

function actions.open(st)
  local page = current(st)
  if page then
    open_page(page)
  end
end

--- <Leader>vv: open the page in the window to the list's right, splitting one off when there
--- is none, so that the list stays on the left and pages are opened one after another on the right.
function actions.open_right(st)
  local page = current(st)
  if not page then
    return
  end
  local right = vim.fn.winnr("l")
  if right ~= vim.fn.winnr() then
    vim.api.nvim_set_current_win(vim.fn.win_getid(right))
  else
    vim.cmd("rightbelow vsplit")
    -- A split copies the list's window options (see `show`); the page's window gets the usual ones.
    vim.cmd("setlocal wrap< number< relativenumber< cursorline< signcolumn< list<")
  end
  open_page(page)
end

function actions.new(st)
  local title = ask_title("新しいページのタイトル: ")
  if title then
    require("notes.page").open_title(title, st.mode == "list" and st.store or "remote", true)
  end
end

function actions.toggle_store(st)
  st.mode = "list"
  st.store = st.store == "remote" and "local" or "remote"
  st.shown_days = DAYS_PER_LOAD
  render(st)
  select(st, 1)
  theme.refresh() -- this window's colours follow the tab
end

function actions.search()
  local ok, q = pcall(vim.fn.input, { prompt = "検索: ", cancelreturn = false })
  if ok and q ~= false then
    require("notes.ddu").search(parser.trim(q))
  end
end

function actions.sort(st)
  st.sort = st.sort == "updated" and "created" or "updated"
  render(st)
  select(st, 1)
end

function actions.closed(st)
  local page = current(st)
  if not page or page.missing then
    return
  end
  store.edit_marks(page, function(lines)
    return marks.with_closed(lines, not page.closed)
  end)
  after_change(st)
end

function actions.pin(st)
  local page = current(st)
  if not page or page.missing then
    return
  end
  local ok, err = store.set_pin(page, page.pin == 0)
  if not ok then
    return warn(err)
  end
  after_change(st)
end

function actions.date(st)
  local page = current(st)
  if not page or page.missing then
    return
  end
  local ok, day = pcall(vim.fn.input, { prompt = "取りかかる日 YYYY-MM-DD（空で外す）: ", default = page.date or os.date("%Y-%m-%d"), cancelreturn = false })
  if not ok or day == false then
    return
  end
  day = parser.trim(day)
  if day ~= "" and not marks.date_of("date:" .. day) then
    return warn("日付は YYYY-MM-DD で書いてください")
  end
  store.edit_marks(page, function(lines)
    return marks.with_date(lines, day ~= "" and day or nil)
  end)
  after_change(st)
end

function actions.visibility(st)
  local page = current(st)
  if not page or page.missing then
    return
  end
  local touch = false
  if page.private then
    if not confirm(("「%s」を公開しますか？"):format(page.title)) then
      return
    end
    touch = confirm("作成日（ファイル名の日付）を今日にしますか？")
  elseif not confirm(("「%s」を非公開にしますか？"):format(page.title)) then
    return
  end
  local rel, err = store.set_visibility(page, not page.private, touch, st.pages)
  if not rel then
    return warn(err)
  end
  after_change(st)
end

function actions.delete(st)
  local page = current(st)
  if not page or page.missing then
    return
  end
  if not confirm(("「%s」を削除しますか？"):format(page.title)) then
    return
  end
  store.delete(page.rel)
  after_change(st)
end

function actions.merge(st)
  local page = current(st)
  if not page or page.missing then
    return
  end
  require("notes.ddu").pick_merge_target(page)
end

--- The second half of `m`: `page` merged into the page at `into_path`, chosen in ddu.
function M.merge_into(page, into_path)
  local into_rel = store.rel_of(into_path)
  local into = into_rel and vim.iter(store.pages()):find(function(p)
    return p.rel == into_rel
  end)
  if not into or into.rel == page.rel then
    return warn("マージ先のページが見つかりません")
  end
  if not confirm(("「%s」の本文を「%s」の末尾に足して、「%s」を削除しますか？"):format(page.title, into.title, page.title)) then
    return
  end
  store.merge(page, into)
  store.schedule_sync()
  for _, st in pairs(states) do
    if vim.api.nvim_buf_is_valid(st.buf) and vim.fn.bufwinid(st.buf) ~= -1 then
      redraw(st)
    end
  end
end

-- Labels on the cards in the window; the card whose label is typed is opened.
function actions.label_open(st)
  local win = vim.fn.bufwinid(st.buf)
  local first, last = vim.fn.line("w0", win), vim.fn.line("w$", win)
  local visible = {}
  for i, c in ipairs(st.cards) do
    if c.line >= first and c.line <= last then
      visible[#visible + 1] = i
    end
  end
  if #visible == 0 then
    return
  end
  local n = #LABEL_CHARS
  local two = #visible > n
  local labels = {}
  for k, i in ipairs(visible) do
    local label = two and (LABEL_CHARS:sub(math.floor((k - 1) / n) + 1, math.floor((k - 1) / n) + 1) .. LABEL_CHARS:sub((k - 1) % n + 1, (k - 1) % n + 1)) or LABEL_CHARS:sub(k, k)
    labels[label] = i
    local c = st.cards[i]
    vim.api.nvim_buf_set_extmark(st.buf, ns_label, c.line - 1, c.col + #"▎ ", { virt_text = { { label, "NotesLabel" } }, virt_text_pos = "overlay", priority = 300 })
  end
  vim.cmd.redraw()
  local typed = ""
  local ok = pcall(function()
    repeat
      typed = typed .. vim.fn.getcharstr()
    until labels[typed] or #typed >= (two and 2 or 1)
  end)
  vim.api.nvim_buf_clear_namespace(st.buf, ns_label, 0, -1)
  if ok and labels[typed] then
    select(st, labels[typed])
    open_page(st.cards[labels[typed]].page)
  end
end

-- ===== the buffer =====

local function setup_buffer(st)
  local buf = st.buf
  vim.bo[buf].buftype, vim.bo[buf].bufhidden, vim.bo[buf].swapfile, vim.bo[buf].filetype = "nofile", "hide", false, "notes-list"
  local map = function(lhs, fn)
    vim.keymap.set("n", lhs, function()
      fn(st)
    end, { buffer = buf, nowait = true, silent = true })
  end
  map("j", function()
    move(st, 1, 0)
  end)
  map("k", function()
    move(st, -1, 0)
  end)
  map("l", function()
    move(st, 0, 1)
  end)
  map("h", function()
    move(st, 0, -1)
  end)
  map("<CR>", actions.open)
  map("<Leader>vv", actions.open_right)
  map("f", actions.label_open)
  map("<Tab>", actions.toggle_store)
  map("/", actions.search)
  map("c", actions.new)
  map("s", actions.sort)
  map("x", actions.closed)
  map("p", actions.pin)
  map("t", actions.date)
  map("v", actions.visibility)
  map("D", actions.delete)
  map("m", actions.merge)

  local group = vim.api.nvim_create_augroup("notes_list_" .. buf, { clear = true })
  -- Back on the list: the pages again, other machines' commits, and the dates from git.
  vim.api.nvim_create_autocmd("BufEnter", {
    group = group,
    buffer = buf,
    callback = function()
      store.ensure_history()
      redraw(st)
      local function again()
        if vim.api.nvim_buf_is_valid(buf) and vim.fn.bufwinid(buf) ~= -1 then
          redraw(st)
        end
      end
      store.refresh_history(again)
      store.pull(again)
    end,
  })
  -- The selected card follows the cursor, however it moved (gg, G, <C-f>, a search): the card
  -- under it, or, on a heading or a blank line, the nearest one, so that hjkl go on from there.
  -- Near the end, the next days are loaded.
  vim.api.nvim_create_autocmd("CursorMoved", {
    group = group,
    buffer = buf,
    callback = function()
      local line = vim.fn.line(".")
      local best = nearest_card(st, line, vim.fn.col(".") - 1)
      if best and best ~= st.cur then
        select(st, best, false)
      end
      if st.mode == "list" and st.more and line > vim.api.nvim_buf_line_count(buf) - CARD_H * 3 then
        st.shown_days = st.shown_days + DAYS_PER_LOAD
        local cursor = vim.api.nvim_win_get_cursor(0)
        redraw(st)
        pcall(vim.api.nvim_win_set_cursor, 0, cursor)
      end
    end,
  })
  vim.api.nvim_create_autocmd({ "VimResized", "WinResized" }, {
    group = group,
    callback = function()
      if vim.api.nvim_buf_is_valid(buf) and vim.fn.bufwinid(buf) ~= -1 then
        redraw(st)
      end
    end,
  })
  vim.api.nvim_create_autocmd("BufWipeout", {
    group = group,
    buffer = buf,
    callback = function()
      states[buf] = nil
    end,
  })
end

local function list_buffer()
  for buf, st in pairs(states) do
    if vim.api.nvim_buf_is_valid(buf) then
      return st
    end
  end
  local buf = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_buf_set_name(buf, "notes://list")
  local st = { buf = buf, mode = "list", store = "remote", sort = "updated", shown_days = DAYS_PER_LOAD, cur = 1, cards = {} }
  states[buf] = st
  setup_buffer(st)
  return st
end

local function show(st)
  local win = vim.api.nvim_get_current_win()
  if vim.api.nvim_win_get_buf(win) == st.buf then
    redraw(st)
  else
    vim.api.nvim_win_set_buf(win, st.buf) -- BufEnter draws it
  end
  -- The cursor line's band shows the row the cursor is on, as in a page.
  vim.wo[win].wrap, vim.wo[win].number, vim.wo[win].relativenumber, vim.wo[win].cursorline = false, false, false, true
  vim.wo[win].signcolumn, vim.wo[win].list = "no", false
end

--- A page chosen in the search: the list, in the current window, turned to the page's side
--- (remote / local) with its card selected and in view; the upper card when the page is
--- under two days. When the card is on a day not loaded yet, more days are loaded until it
--- shows if `load_more`, else nothing is changed. Returns whether the card was found.
function M.reveal(rel, load_more)
  local page
  for _, p in ipairs(store.pages()) do
    if p.rel == rel then
      page = p
    end
  end
  if not page then
    return false
  end
  local st = list_buffer()
  local before = { mode = st.mode, store = st.store, shown_days = st.shown_days }
  st.mode = "list"
  if page.store ~= st.store then
    st.store, st.shown_days = page.store, DAYS_PER_LOAD
  end
  local function index()
    render(st)
    for i, c in ipairs(st.cards) do
      if c.page.rel == rel then
        return i
      end
    end
  end
  local i = index()
  while not i and load_more and st.more do
    st.shown_days = st.shown_days + DAYS_PER_LOAD
    i = index()
  end
  if not i then
    st.mode, st.store, st.shown_days = before.mode, before.store, before.shown_days
    render(st)
    return false
  end
  show(st)
  select(st, i)
  require("notes.theme").refresh() -- the window's colours follow the side
  return true
end

--- The list of pages, in the current window.
function M.open()
  if not store.ensure_root() then
    return
  end
  local st = list_buffer()
  st.mode = "list"
  show(st)
  if #st.cards > 0 and not st.cards[st.cur] then
    select(st, 1)
  end
end

--- The related pages of `page` ({ rel, title }), as cards.
function M.open_related(page)
  local st = list_buffer()
  st.mode, st.related_of = "related", page
  show(st)
  select(st, 1)
end

-- For tests.
--- Whether the list in `buf` is showing the local pages.
function M.shows_local(buf)
  local st = states[buf]
  return st ~= nil and st.mode == "list" and st.store == "local"
end

M._state = function()
  local st = list_buffer()
  return st
end
M._actions = actions
M._move = move

return M
