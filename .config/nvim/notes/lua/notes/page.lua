-- A page being edited: an ordinary buffer on its txt file. Saving it does what
-- stderr-blog's editor does on a save (a new title renames the file, keeping its
-- date, and the links to the old title can be rewritten), and a few keys reach
-- what the editor's page has: following a link, images, splitting lines off into
-- a new page, the related pages.

local parser = require("notes.parser")
local store = require("notes.store")

local M = {}

local function warn(msg)
  vim.notify("notes: " .. msg, vim.log.levels.WARN)
end

local function buffer_text(buf)
  return table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n") .. "\n"
end

local function rel_of_buf(buf)
  return store.rel_of(vim.api.nvim_buf_get_name(buf))
end

--- Open the page titled `title`, or start a new one in `store_name` (written on its first
--- save, as in the browser editor; at once when `write_now`).
function M.open_title(title, store_name, write_now)
  local page = store.find(title)
  if page then
    vim.cmd.edit(vim.fn.fnameescape(store.abs(page.rel)))
    return
  end
  if write_now then
    local rel = store.create(title .. "\n", store_name)
    store.schedule_sync()
    vim.cmd.edit(vim.fn.fnameescape(store.abs(rel)))
    return
  end
  local rel = store.path_for_new(title, store_name)
  vim.cmd.edit(vim.fn.fnameescape(store.abs(rel)))
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { title, "" })
  vim.api.nvim_win_set_cursor(0, { 2, 0 })
end

-- ===== saving =====

local function after_write(buf)
  local rel = rel_of_buf(buf)
  if not rel then
    return
  end
  local old_title = vim.b[buf].notes_title
  local text = buffer_text(buf)
  local title = parser.title_of(text)
  local ok, now = pcall(store.after_save, rel, old_title, text)
  if not ok then
    warn("保存のあとの処理に失敗しました: " .. tostring(now))
    now = rel
  end
  vim.b[buf].notes_title = title
  if old_title and parser.to_title_lc(old_title) ~= parser.to_title_lc(title) then
    local referrers = store.referrers(old_title, now)
    if #referrers > 0 and vim.fn.confirm(("「%s」は %d ページからリンクされています。リンクを「%s」に書き換えますか？"):format(old_title, #referrers, title), "&Yes\n&No", 1) == 1 then
      local changed = store.replace_links(old_title, title)
      vim.notify(("notes: %d ページのリンクを書き換えました"):format(changed))
    end
  end
  -- A title opens one page only: a second page of the same title is reachable from the list alone.
  for _, p in ipairs(store.pages()) do
    if p.rel ~= now and parser.to_title_lc(p.title) == parser.to_title_lc(title) then
      warn(("同じタイトルのページがあります（%s）。一覧の m で統合できます"):format(p.rel))
      break
    end
  end
  store.schedule_sync()
end

-- ===== under the cursor =====

-- The node of the cursor's line under the cursor, in a line that carries notation.
local function node_under_cursor()
  local lnum, col = unpack(vim.api.nvim_win_get_cursor(0))
  local lines = parser.parse_page((buffer_text(0):gsub("\n$", "")))
  local found
  parser.each_node(lines[lnum] and lines[lnum].nodes or {}, function(node, offset)
    if not node.children and col >= offset and col < offset + #node.raw then
      found = node
    end
  end)
  return found
end

--- <C-CR>: open the page a link or tag names (starting it when there is none), or the image.
function M.follow()
  local node = node_under_cursor()
  if not node then
    return
  end
  if (node.type == "image" or node.type == "strongImage") then
    local file = node.src:match("^/img/") and store.image_file(node.src) or node.src
    if not file then
      return warn(("画像が見つかりません: %s"):format(node.src))
    end
    vim.ui.open(file)
  elseif node.page and not node.project then
    local rel = rel_of_buf(0)
    M.open_title(node.page, rel and require("notes.filename").store_of(rel) or "remote")
  end
end

-- ===== images =====

local function insert_at_cursor(text)
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()
  local at = #line == 0 and 0 or math.min(col + 1, #line)
  vim.api.nvim_buf_set_text(0, row - 1, at, row - 1, at, { text })
  vim.api.nvim_win_set_cursor(0, { row, at + #text - 1 })
end

--- <Space>nu: copy an image file into the page's images and write it into the page.
function M.upload()
  local rel = rel_of_buf(0)
  if not rel then
    return
  end
  local ok, path = pcall(vim.fn.input, { prompt = "画像ファイル: ", completion = "file", cancelreturn = "" })
  path = ok and vim.fs.normalize(vim.trim(path)) or ""
  if path == "" then
    return
  end
  if not vim.uv.fs_stat(path) then
    return warn("ファイルがありません: " .. path)
  end
  local name, err = store.store_image(path, vim.fs.basename(path), rel)
  if not name then
    return warn(err)
  end
  insert_at_cursor(("[/img/%s]"):format(name))
end

-- The clipboard's image as a PNG file, or nil.
local function clipboard_png()
  local tmp = vim.fn.tempname() .. ".png"
  if vim.fn.has("mac") == 1 then
    vim.system({
      "osascript",
      "-e", ("set f to (open for access POSIX file %q with write permission)"):format(tmp),
      "-e", "try",
      "-e", "write (the clipboard as «class PNGf») to f",
      "-e", "end try",
      "-e", "close access f",
    }):wait()
  elseif vim.fn.executable("wl-paste") == 1 then
    local r = vim.system({ "wl-paste", "--type", "image/png" }):wait()
    if r.code == 0 then
      vim.fn.writefile({ r.stdout }, tmp, "b")
    end
  elseif vim.fn.executable("xclip") == 1 then
    local r = vim.system({ "xclip", "-selection", "clipboard", "-t", "image/png", "-o" }):wait()
    if r.code == 0 then
      vim.fn.writefile({ r.stdout }, tmp, "b")
    end
  end
  local stat = vim.uv.fs_stat(tmp)
  return stat and stat.size > 0 and tmp or nil
end

--- <Space>np: the clipboard's image, stored and written into the page.
function M.paste_image()
  local rel = rel_of_buf(0)
  if not rel then
    return
  end
  local png = clipboard_png()
  if not png then
    return warn("クリップボードに画像がありません")
  end
  local name, err = store.store_image(png, "image.png", rel)
  os.remove(png)
  if not name then
    return warn(err)
  end
  insert_at_cursor(("[/img/%s]"):format(name))
end

-- ===== splitting lines off =====

--- <Space>ns on lines: they become a page of their own (or are added to the page of that
--- title), and a link to it takes their place (tools/cosense/editor/popup.js `split`).
function M.split(first, last)
  local rel = rel_of_buf(0)
  if not rel then
    return
  end
  local lines = vim.api.nvim_buf_get_lines(0, first - 1, last, false)
  local title = parser.split_title_of(lines) or ("Untitled " .. os.date("%Y/%m/%d %H:%M:%S"))
  local depth = math.huge
  for _, l in ipairs(lines) do
    if not parser.is_empty_line(l) then
      depth = math.min(depth, parser.count_indent(l))
    end
  end
  local body = { "from [" .. parser.title_of(buffer_text(0)) .. "]" }
  local title_taken = false
  for _, l in ipairs(lines) do
    if not title_taken and parser.trim(l) == title then
      title_taken = true
    else
      local cut = math.min(depth, parser.count_indent(l))
      body[#body + 1] = vim.fn.strcharpart(l, cut)
    end
  end
  body[#body + 1] = ""
  local existing = store.find(title)
  if existing then
    store.append(existing.rel, table.concat(body, "\n"))
  else
    store.create(title .. "\n" .. table.concat(body, "\n"), require("notes.filename").store_of(rel))
  end
  vim.api.nvim_buf_set_lines(0, first - 1, last, false, { "[" .. title .. "]" })
  vim.notify(("notes: %s「%s」"):format(existing and "追記しました" or "作りました", title))
  store.schedule_sync()
end

-- ===== a URL with its page's title =====

local function decode_entities(s)
  return (s:gsub("&amp;", "&"):gsub("&lt;", "<"):gsub("&gt;", ">"):gsub("&quot;", '"'):gsub("&#0?39;", "'"))
end

--- :NotesPasteUrl: the clipboard's URL, then, once its page has answered, `[URL title]` in its
--- place (the browser editor's Shift+paste of a URL; dev server `embedTitle`).
function M.paste_url()
  local url = vim.trim(vim.fn.getreg("+"))
  if not url:match("^https?://%S+$") then
    return warn("クリップボードが URL ではありません")
  end
  local buf = vim.api.nvim_get_current_buf()
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  insert_at_cursor(url)
  local col = vim.api.nvim_win_get_cursor(0)[2] - #url + 1
  local mark = vim.api.nvim_buf_set_extmark(buf, vim.api.nvim_create_namespace("notes_paste_url"), row, col, { end_col = col + #url })
  vim.system({ "curl", "-sL", "--max-time", "8", "--max-filesize", "524288", "-A", "Mozilla/5.0 (cosense-editor)", url }, { text = true }, function(r)
    vim.schedule(function()
      local html = (r.stdout or ""):sub(1, 512 * 1024)
      local title = html:match("<[tT][iI][tT][lL][eE][^>]*>(.-)</[tT][iI][tT][lL][eE]>")
      if not title or not vim.api.nvim_buf_is_valid(buf) then
        return
      end
      title = vim.trim(decode_entities(title):gsub("%s+", " "):gsub("[%[%]]", ""))
      local ns = vim.api.nvim_create_namespace("notes_paste_url")
      local at = vim.api.nvim_buf_get_extmark_by_id(buf, ns, mark, { details = true })
      vim.api.nvim_buf_del_extmark(buf, ns, mark)
      if #at == 0 or title == "" then
        return
      end
      local srow, scol, erow, ecol = at[1], at[2], at[3].end_row, at[3].end_col
      if vim.api.nvim_buf_get_text(buf, srow, scol, erow, ecol, {})[1] ~= url then
        return -- the URL was edited meanwhile: leave it
      end
      vim.api.nvim_buf_set_text(buf, srow, scol, erow, ecol, { ("[%s %s]"):format(url, title) })
    end)
  end)
end

-- ===== setup =====

function M.attach(buf)
  if vim.b[buf].notes_attached then
    return
  end
  vim.b[buf].notes_attached = true
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  -- A file that does not exist yet has no title to rename from.
  vim.b[buf].notes_title = vim.uv.fs_stat(vim.api.nvim_buf_get_name(buf)) and parser.title_of(table.concat(lines, "\n")) or nil
  local map = function(mode, lhs, fn, desc)
    vim.keymap.set(mode, lhs, fn, { buffer = buf, silent = true, desc = desc })
  end
  map("n", "<C-CR>", M.follow, "notes: リンク先のページか画像を開く")
  map("n", "<Leader>nu", M.upload, "notes: 画像ファイルを入れる")
  map("n", "<Leader>np", M.paste_image, "notes: クリップボードの画像を貼る")
  map("x", "<Leader>ns", function()
    local a, b = vim.fn.line("v"), vim.fn.line(".")
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
    M.split(math.min(a, b), math.max(a, b))
  end, "notes: 選んだ行を新しいページに切り出す")
  map("n", "<Leader>nk", function()
    local rel = rel_of_buf(buf)
    if rel then
      require("notes.list").open_related({ rel = rel, title = parser.title_of(buffer_text(buf)) })
    end
  end, "notes: 関連ページ")
  vim.api.nvim_create_autocmd("BufWritePost", {
    buffer = buf,
    callback = function()
      after_write(buf)
    end,
  })
end

return M
