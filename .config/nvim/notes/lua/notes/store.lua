-- The notes on disk: the index of every page (what the list shows), search,
-- related pages, and the operations on a page that touch files (create, rename,
-- delete, duplicate, merge, publish, pin, the page marks, images).
--
-- Layout, under the root (~/notes):
--   pages/                the pages, one txt each; pages/private/ is never published,
--                         pages/private/local/ never leaves this machine
--   pages/.cosense.json   the pins
--   img/                  images of published pages
--   pages/private/img/, pages/private/local/img/   images of private and local pages
-- On a machine with stderr-blog, pages/ and img/ are symlinks to its
-- src/content/pages/ and public/img/.

local parser = require("notes.parser")
local marks = require("notes.marks")
local filename = require("notes.filename")
local meta = require("notes.meta")
local git = require("notes.git")

local M = {}

M.root = vim.fs.normalize("~/notes")

function M.pages_dir()
  return M.root .. "/pages"
end

function M.img_dir()
  return M.root .. "/img"
end

--- The pages directory exists, or the user agreed to make the layout here now.
function M.ensure_root()
  if vim.uv.fs_stat(M.pages_dir()) then
    return true
  end
  local answer = vim.fn.confirm(("%s がありません。メモ置き場として作りますか？\n（stderr-blog があるマシンなら、作らずに pages と img の symlink を張ってください）"):format(M.pages_dir()), "&Yes\n&No", 2)
  if answer ~= 1 then
    return false
  end
  vim.fn.mkdir(M.pages_dir(), "p")
  vim.fn.mkdir(M.img_dir(), "p")
  return true
end

--- A page's absolute path from its path relative to the pages directory.
function M.abs(rel)
  return M.pages_dir() .. "/" .. rel
end

--- A file's path relative to the pages directory, or nil when it is not a page.
function M.rel_of(path)
  path = vim.fs.normalize(path)
  local dir = M.pages_dir() .. "/"
  local real_dir = (vim.uv.fs_realpath(M.pages_dir()) or M.pages_dir()) .. "/"
  for _, d in ipairs({ dir, real_dir }) do
    if path:sub(1, #d) == d and path:sub(-#filename.EXT) == filename.EXT then
      return path:sub(#d + 1)
    end
  end
end

local function exists(rel)
  return vim.uv.fs_stat(M.abs(rel)) ~= nil
end

local function read(path)
  local f = io.open(path, "rb")
  if not f then
    return nil
  end
  local text = f:read("*a")
  f:close()
  return text
end
M.read = read

--- The text of a page as stored: always ending with a newline.
local function normalize(text)
  text = text:gsub("\r\n?", "\n")
  return text:sub(-1) == "\n" and text or text .. "\n"
end

-- A page's text replaced, through its buffer when one is loaded (so an open window
-- shows it and an unsaved edit is not overwritten from under it), else on disk.
local function write_page(rel, text)
  local buf = vim.fn.bufnr(M.abs(rel))
  if buf ~= -1 and vim.api.nvim_buf_is_loaded(buf) then
    local lines = vim.split(text:gsub("\n$", ""), "\n", { plain = true })
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_buf_call(buf, function()
      vim.cmd("silent noautocmd write")
    end)
  else
    vim.fn.mkdir(vim.fs.dirname(M.abs(rel)), "p")
    local f = assert(io.open(M.abs(rel), "wb"))
    f:write(normalize(text))
    f:close()
  end
end

--- A page's text: its loaded buffer's if it has one, else the file's.
function M.text_of(rel)
  local buf = vim.fn.bufnr(M.abs(rel))
  if buf ~= -1 and vim.api.nvim_buf_is_loaded(buf) then
    return table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n") .. "\n"
  end
  return read(M.abs(rel)) or ""
end

-- ===== the index =====

local summaries = {} -- rel -> { mtime, size, title, descriptions, date, closed }
local history = nil -- the last git history read: { at, last, commits, dirty }
local HISTORY_TTL = 60

local function page_files()
  local out = {}
  for name, type in vim.fs.dir(M.pages_dir(), { depth = math.huge, follow = true }) do
    if type == "file" and name:sub(-#filename.EXT) == filename.EXT then
      out[#out + 1] = name
    end
  end
  return out
end

local function repo_paths()
  local repo = git.repo_of(M.pages_dir())
  if not repo then
    return nil
  end
  local paths = { repo.path }
  local img = git.repo_of(M.img_dir())
  if img and img.root == repo.root then
    paths[#paths + 1] = img.path
  end
  return repo, paths
end

--- Read the git history again in the background (at most once a minute unless `force`),
--- calling `changed()` when it has.
function M.refresh_history(changed, force)
  local repo = git.repo_of(M.pages_dir())
  if not repo or (not force and history and os.time() - history.at < HISTORY_TTL) then
    return
  end
  git.history(repo, { repo.path }, function(h)
    h.at = os.time()
    history = h
    if changed then
      changed()
    end
  end)
end

--- Every page: { rel, title, descriptions, date, closed, private, store, created, updated, pin }.
--- Files are read only when they changed since the last call.
function M.pages()
  local m = meta.read(M.pages_dir())
  local repo = git.repo_of(M.pages_dir())
  local out = {}
  local seen = {}
  for _, rel in ipairs(page_files()) do
    seen[rel] = true
    local stat = vim.uv.fs_stat(M.abs(rel))
    if stat then
      local s = summaries[rel]
      if not s or s.mtime ~= stat.mtime.sec or s.size ~= stat.size then
        local text = read(M.abs(rel)) or ""
        local summary = parser.summary(text)
        local mk = marks.of(vim.split(text, "\n", { plain = true }))
        s = { mtime = stat.mtime.sec, size = stat.size, title = summary.title, descriptions = summary.descriptions, date = mk.date, closed = mk.closed }
        summaries[rel] = s
      end
      local parsed = filename.parse(filename.stem(rel))
      local created = s.mtime
      if parsed.date then
        local y, mo, d = parsed.date:match("(%d+)-(%d+)-(%d+)")
        created = os.time({ year = tonumber(y), month = tonumber(mo), day = tonumber(d), hour = 0 })
      end
      local updated = s.mtime
      if repo and history then
        local repo_path = repo.path == "." and rel or (repo.path .. "/" .. rel)
        local committed = history.last[repo_path]
        -- An uncommitted edit is dated by the file; anything else by git, or by the time
        -- recorded at migration while the migration is its only commit.
        if not (history.dirty[repo_path] and committed) then
          updated = meta.updated_time(m, rel, history.commits[repo_path] or 0, committed or s.mtime)
        end
      end
      out[#out + 1] = {
        rel = rel,
        title = s.title,
        descriptions = s.descriptions,
        date = s.date,
        closed = s.closed,
        private = filename.is_private(rel),
        store = filename.store_of(rel),
        created = created,
        updated = updated,
        pin = meta.pin_of(m, parser.to_title_lc(s.title)) or 0,
      }
    end
  end
  for rel in pairs(summaries) do
    if not seen[rel] then
      summaries[rel] = nil
    end
  end
  return out
end

--- The page titled `title` (spaces and _ alike, any case), or nil.
function M.find(title, pages)
  local lc = parser.to_title_lc(title)
  for _, p in ipairs(pages or M.pages()) do
    if parser.to_title_lc(p.title) == lc then
      return p
    end
  end
end

-- ===== search =====

local lowered = {} -- rel -> { mtime, size, text } (the text lowercased)

local function lower_text(page)
  local stat = vim.uv.fs_stat(M.abs(page.rel))
  local c = lowered[page.rel]
  if not c or not stat or c.mtime ~= stat.mtime.sec or c.size ~= stat.size then
    c = { mtime = stat and stat.mtime.sec, size = stat and stat.size, text = vim.fn.tolower(read(M.abs(page.rel)) or "") }
    lowered[page.rel] = c
  end
  return c.text
end

--- The pages holding every word of `query` and none of its "-word"s, pages whose title has
--- one of the words first, then the most recently updated; at most 100 (dev server `search`).
function M.search(query, pages)
  local words, excludes = {}, {}
  for term in vim.fn.tolower(query):gmatch("%S+") do
    if term:sub(1, 1) == "-" then
      if #term > 1 then
        excludes[#excludes + 1] = term:sub(2)
      end
    else
      words[#words + 1] = term
    end
  end
  if #words == 0 and #excludes == 0 then
    return {}
  end
  local found = {}
  for _, page in ipairs(pages) do
    local text = lower_text(page)
    local ok = true
    for _, w in ipairs(words) do
      ok = ok and text:find(w, 1, true) ~= nil
    end
    for _, w in ipairs(excludes) do
      ok = ok and text:find(w, 1, true) == nil
    end
    if ok then
      found[#found + 1] = page
    end
  end
  local function title_hit(p)
    local t = vim.fn.tolower(p.title)
    for _, w in ipairs(words) do
      if t:find(w, 1, true) then
        return 1
      end
    end
    return 0
  end
  table.sort(found, function(a, b)
    local ha, hb = title_hit(a), title_hit(b)
    if ha ~= hb then
      return ha > hb
    end
    return a.updated > b.updated
  end)
  return vim.list_slice(found, 1, 100)
end

-- ===== links between pages =====

-- The pages whose text might link to one of `titles`: a superset, by plain text, so that
-- only these need parsing. Spaces and _ are one, and case does not count, as in links.
local function might_link(pages, titles)
  local needles = {}
  for _, t in ipairs(titles) do
    needles[#needles + 1] = (vim.fn.tolower(t):gsub("_", " "))
  end
  local out = {}
  for _, page in ipairs(pages) do
    local hay = lower_text(page):gsub("_", " ")
    for _, n in ipairs(needles) do
      if hay:find(n, 1, true) then
        out[#out + 1] = page
        break
      end
    end
  end
  return out
end

local function links_of(page)
  return parser.links_of(M.text_of(page.rel))
end

--- The pages that link to `title`, other than the page `except` (a rel).
function M.referrers(title, except, pages)
  local lc = parser.to_title_lc(title)
  local out = {}
  for _, page in ipairs(might_link(pages or M.pages(), { title })) do
    if page.rel ~= except then
      for _, l in ipairs(links_of(page)) do
        if parser.to_title_lc(l) == lc then
          out[#out + 1] = page
          break
        end
      end
    end
  end
  return out
end

--- The related pages of `current` (stderr-blog's src/lib/cosense/links.mjs `relatedPages`):
--- `links` (pages it links to, then pages linking to it), `groups` (for each link name it
--- writes, the other pages writing it, a page once), `new_links` (names written nowhere else).
function M.related(current, pages)
  local current_lc = parser.to_title_lc(current.title)
  local current_links = links_of(current)
  local others, by_lc = {}, {}
  for _, p in ipairs(pages) do
    local lc = parser.to_title_lc(p.title)
    if lc ~= current_lc then
      others[#others + 1] = p
      by_lc[lc] = p
    end
  end
  local candidates = might_link(others, vim.list_extend({ current.title }, current_links))
  local links_by_rel = {}
  for _, p in ipairs(candidates) do
    local lcs = {}
    for _, l in ipairs(links_of(p)) do
      lcs[parser.to_title_lc(l)] = true
    end
    links_by_rel[p.rel] = lcs
  end
  local function writes(p, lc)
    return links_by_rel[p.rel] and links_by_rel[p.rel][lc]
  end
  local by_updated = function(a, b)
    return a.updated > b.updated
  end

  local link_to, link_from, direct = {}, {}, {}
  for _, l in ipairs(current_links) do
    local p = by_lc[parser.to_title_lc(l)]
    if p and not direct[p.rel] then
      direct[p.rel] = true
      link_to[#link_to + 1] = p
    end
  end
  for _, p in ipairs(candidates) do
    if not direct[p.rel] and writes(p, current_lc) then
      direct[p.rel] = true
      link_from[#link_from + 1] = p
    end
  end
  table.sort(link_to, by_updated)
  table.sort(link_from, by_updated)

  local shown, groups, new_links, done = {}, {}, {}, {}
  for _, link in ipairs(current_links) do
    local lc = parser.to_title_lc(link)
    if not done[lc] and lc ~= current_lc then
      done[lc] = true
      local sharing, fresh = {}, {}
      for _, p in ipairs(candidates) do
        if writes(p, lc) then
          sharing[#sharing + 1] = p
          local plc = parser.to_title_lc(p.title)
          if not shown[plc] then
            shown[plc] = true
            fresh[#fresh + 1] = p
          end
        end
      end
      if #fresh > 0 then
        table.sort(fresh, by_updated)
        groups[#groups + 1] = { link = link, pages = fresh }
      elseif not by_lc[lc] and #sharing == 0 then
        new_links[#new_links + 1] = link
      end
    end
  end
  return { links = vim.list_extend(link_to, link_from), groups = groups, new_links = new_links }
end

-- ===== images =====

local IMAGE_EXTS = { [".png"] = true, [".jpg"] = true, [".jpeg"] = true, [".gif"] = true, [".webp"] = true, [".svg"] = true, [".avif"] = true }

local function img_dirs()
  return { M.img_dir(), M.pages_dir() .. "/private/img", M.pages_dir() .. "/private/local/img" }
end

--- Where the images of the page `rel` go: published, private, or this machine only.
function M.img_dir_for(rel)
  if filename.store_of(rel) == "local" then
    return M.pages_dir() .. "/private/local/img"
  end
  return filename.is_private(rel) and (M.pages_dir() .. "/private/img") or M.img_dir()
end

--- The file behind `[/img/<name>]`, wherever it is kept, or nil.
function M.image_file(src)
  local name = src:match("^/img/(.+)$")
  if not name then
    return nil
  end
  for _, dir in ipairs(img_dirs()) do
    if vim.uv.fs_stat(dir .. "/" .. name) then
      return dir .. "/" .. name
    end
  end
end

--- Store the image file `from` (named `name`) for the page `rel`, and return the name it got:
--- unsafe characters made "-", "-1", "-2", ... when the name is taken in any image directory,
--- since they all share /img/<name> (dev server `saveImage`). nil, with a reason, for a non-image.
function M.store_image(from, name, rel)
  name = name:gsub("[^%w._%-]+", "-"):gsub("^[-.]+", "")
  local ext = (name:match("%.[^.]*$") or ""):lower()
  if not IMAGE_EXTS[ext] then
    return nil, "画像ではありません（png, jpg, gif, webp, svg, avif）"
  end
  local base = name:sub(1, #name - #ext)
  base = base ~= "" and base or "image"
  local dir = M.img_dir_for(rel)
  vim.fn.mkdir(dir, "p")
  local fname, i = base .. ext, 1
  local function taken(n)
    for _, d in ipairs(img_dirs()) do
      if vim.uv.fs_stat(d .. "/" .. n) then
        return true
      end
    end
  end
  while taken(fname) do
    fname = ("%s-%d%s"):format(base, i, ext)
    i = i + 1
  end
  assert(vim.uv.fs_copyfile(from, dir .. "/" .. fname))
  return fname
end

local function local_images(text)
  local out = {}
  for _, src in ipairs(parser.image_sources(text)) do
    local name = src:match("^/img/(.+)$")
    if name then
      out[#out + 1] = name
    end
  end
  return out
end

--- A published page may only embed published images: move any still private ones out.
function M.publish_images(text)
  for _, name in ipairs(local_images(text)) do
    local from, to = M.pages_dir() .. "/private/img/" .. name, M.img_dir() .. "/" .. name
    if vim.uv.fs_stat(from) and not vim.uv.fs_stat(to) then
      vim.fn.mkdir(M.img_dir(), "p")
      vim.uv.fs_rename(from, to)
    end
  end
end

-- A page went private: take its images out of the published ones, unless a published page still uses them.
local function unpublish_images(text, rel, pages)
  for _, name in ipairs(local_images(text)) do
    local from, to = M.img_dir() .. "/" .. name, M.pages_dir() .. "/private/img/" .. name
    if vim.uv.fs_stat(from) and not vim.uv.fs_stat(to) then
      local needle, used = "/img/" .. name, false
      for _, p in ipairs(pages) do
        if p.rel ~= rel and not p.private and (read(M.abs(p.rel)) or ""):find(needle, 1, true) then
          used = true
          break
        end
      end
      if not used then
        vim.fn.mkdir(vim.fs.dirname(to), "p")
        vim.uv.fs_rename(from, to)
      end
    end
  end
end

-- ===== operations =====

local function move(rel, target)
  vim.fn.mkdir(vim.fs.dirname(M.abs(target)), "p")
  assert(vim.uv.fs_rename(M.abs(rel), M.abs(target)))
  local buf = vim.fn.bufnr(M.abs(rel))
  if buf ~= -1 then
    vim.api.nvim_buf_set_name(buf, M.abs(target))
    if vim.api.nvim_buf_is_loaded(buf) then
      vim.api.nvim_buf_call(buf, function()
        vim.cmd("silent! noautocmd write!") -- the buffer now names the moved file; clears "not edited"
      end)
    end
  end
end

--- A new page's path: "<today> <title>.txt" in `store` (new pages start private, as in the browser editor).
function M.path_for_new(title, store)
  local name = filename.for_new(os.date("%Y-%m-%d"), title) or filename.for_new(os.date("%Y-%m-%d"), "Untitled")
  local folder = store == "local" and filename.LOCAL_DIR or filename.PRIVATE_DIR
  return filename.free(folder .. "/" .. name, nil, exists)
end

--- Make a page with `text`; returns its rel.
function M.create(text, store)
  local rel = M.path_for_new(parser.title_of(text), store)
  write_page(rel, text)
  return rel
end

--- After the page `rel` was saved with `text` whose title was `old_title`: the file follows a new
--- title (keeping its date), its pin follows it, a published page's images are published.
--- Returns the rel it has now.
function M.after_save(rel, old_title, text)
  local title = parser.title_of(text)
  local now = rel
  if old_title and parser.to_title_lc(old_title) ~= parser.to_title_lc(title) then
    local wanted = filename.for_title(rel, title)
    if wanted then
      now = filename.free(wanted, rel, exists)
      if now ~= rel then
        move(rel, now)
      end
    end
    if old_title then
      local m = meta.read(M.pages_dir())
      if meta.pin_of(m, parser.to_title_lc(old_title)) then
        meta.move_pin(m, parser.to_title_lc(old_title), parser.to_title_lc(title))
        meta.write(M.pages_dir(), m)
      end
    end
  end
  if not filename.is_private(now) then
    M.publish_images(text)
  end
  return now
end

--- Rewrite every link to `from` so it points at `to`, in every page; returns how many changed.
function M.replace_links(from, to, pages)
  local changed = 0
  for _, page in ipairs(might_link(pages or M.pages(), { from })) do
    local before = M.text_of(page.rel)
    local after = parser.replace_links(before, from, to)
    if after ~= before then
      write_page(page.rel, after)
      changed = changed + 1
    end
  end
  return changed
end

function M.delete(rel)
  local buf = vim.fn.bufnr(M.abs(rel))
  if buf ~= -1 then
    vim.api.nvim_buf_delete(buf, { force = true })
  end
  assert(vim.uv.fs_unlink(M.abs(rel)))
end

--- A copy of the page titled "<title>_2" (or the next free number), private, in the same store.
function M.duplicate(page, pages)
  local lines = vim.split(M.text_of(page.rel), "\n", { plain = true })
  local taken = {}
  for _, p in ipairs(pages) do
    taken[parser.to_title_lc(p.title)] = true
  end
  local i, title = 2, nil
  repeat
    title = ("%s_%d"):format(lines[1], i)
    i = i + 1
  until not taken[parser.to_title_lc(title)]
  lines[1] = title
  return M.create(table.concat(lines, "\n"), page.store), title
end

--- Append the body of `page` to `into` and delete `page`.
function M.merge(page, into)
  local source = vim.split(M.text_of(page.rel), "\n", { plain = true })
  table.remove(source, 1)
  write_page(into.rel, normalize(M.text_of(into.rel)) .. table.concat(source, "\n"))
  M.delete(page.rel)
end

--- Move a page in or out of private/; with `touch_created`, publishing also makes today its
--- created date. Returns the new rel, or nil and a reason.
function M.set_visibility(page, make_private, touch_created, pages)
  if page.store == "local" then
    return nil, "local のページではできない操作です"
  end
  if page.private == make_private then
    return page.rel
  end
  local name = page.rel:match("[^/]*$")
  if not make_private and touch_created then
    local dated = filename.with_date(name, os.date("%Y-%m-%d"))
    if not dated then
      return nil, "作成日を変えると URL が変わるため、公開を中止しました"
    end
    name = dated
  end
  local target = filename.free(make_private and (filename.PRIVATE_DIR .. "/" .. name) or name, nil, exists)
  move(page.rel, target)
  local text = read(M.abs(target)) or ""
  if make_private then
    unpublish_images(text, target, pages)
  else
    M.publish_images(text)
  end
  return target
end

function M.set_pin(page, pinned)
  if page.store == "local" then
    return nil, "local のページではできない操作です"
  end
  local m = meta.read(M.pages_dir())
  meta.set_pin(m, parser.to_title_lc(page.title), pinned)
  meta.write(M.pages_dir(), m)
  return true
end

--- Rewrite a page's mark lines through `fn(lines) -> lines` (marks.with_date / with_closed).
function M.edit_marks(page, fn)
  local text = M.text_of(page.rel)
  local lines = vim.split(text:gsub("\n$", ""), "\n", { plain = true })
  write_page(page.rel, table.concat(fn(lines), "\n") .. "\n")
end

-- ===== saving to git =====

local timer = nil
local SYNC_DELAY_MS = 20000

--- Commit and push the notes 20 s after the last call (a save, an operation), when they are in git.
function M.schedule_sync()
  local repo, paths = repo_paths()
  if not repo then
    return
  end
  if timer then
    timer:stop()
  else
    timer = vim.uv.new_timer()
  end
  timer:start(SYNC_DELAY_MS, 0, vim.schedule_wrap(function()
    git.sync(repo, paths, function(ok, committed, err)
      if committed then
        M.refresh_history(nil, true)
      end
      if not ok then
        vim.notify("notes: git の commit / push に失敗しました。次の保存で再試行します。" .. (err and ("\n" .. err) or ""), vim.log.levels.WARN)
      end
    end)
  end))
end

--- Receive other machines' commits (fast-forward only), at most once a minute.
local last_pull = 0
function M.pull(changed)
  local repo = git.repo_of(M.pages_dir())
  if not repo or os.time() - last_pull < 60 then
    return
  end
  last_pull = os.time()
  git.pull(repo, function()
    M.refresh_history(changed, true)
  end)
end

return M
