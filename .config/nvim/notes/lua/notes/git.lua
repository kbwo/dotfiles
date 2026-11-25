-- git, for notes kept in a git repository (as stderr-blog's are): when each page
-- was last committed, and committing and pushing what was saved, the way
-- stderr-blog's dev server does (src/lib/cosense-dev-plugin.mjs `commitTick`,
-- src/lib/dev-git-sync.mjs `pullTick` / `pushTick`).
--
-- Every git command runs in the background, one after another through one
-- queue: two at once would fight over .git/index.lock, and none may make the
-- editor wait. Without a repository, everything here is a no-op and dates come
-- from the files.

local M = {}

local queue, running = {}, false

-- Run `cmd` in `cwd`, from inside a job of the queue; returns the vim.system result.
local function run(cmd, cwd)
  local co = coroutine.running()
  vim.system(cmd, { cwd = cwd, text = true }, function(result)
    vim.schedule(function()
      coroutine.resume(co, result)
    end)
  end)
  return coroutine.yield()
end
M.run = run

local function next_job()
  if running or #queue == 0 then
    return
  end
  running = true
  local job = table.remove(queue, 1)
  coroutine.wrap(function()
    local ok, err = pcall(job)
    if not ok then
      vim.notify("notes: " .. tostring(err), vim.log.levels.WARN)
    end
    running = false
    next_job()
  end)()
end

--- Queue `fn` (which may call M.run) after every git job queued before it.
function M.enqueue(fn)
  queue[#queue + 1] = fn
  next_job()
end

-- ===== the repository =====

local roots = {}

--- The repository holding `dir` and the path of `dir` inside it, or nil. Asked once per directory.
function M.repo_of(dir)
  if roots[dir] == nil then
    local real = vim.uv.fs_realpath(dir)
    local top = real and vim.system({ "git", "-C", real, "rev-parse", "--show-toplevel" }, { text = true }):wait()
    if top and top.code == 0 then
      local root = vim.trim(top.stdout)
      roots[dir] = { root = root, path = real == root and "." or real:sub(#root + 2) }
    else
      roots[dir] = false
    end
  end
  return roots[dir] or nil
end

-- ===== when pages were committed =====

--- For each file under the directories `paths` of `repo` (paths relative to the repository):
--- `last` (unix seconds of its last commit) and `commits` (how many touched it), and `dirty`
--- (files with uncommitted changes). Calls `done(history)` on the main loop.
function M.history(repo, paths, done)
  M.enqueue(function()
    local log = run(vim.list_extend({ "git", "log", "-z", "--format=@%ct", "--name-only", "--" }, paths), repo.root)
    local status = run(vim.list_extend({ "git", "status", "-z", "--porcelain", "-uall", "--" }, paths), repo.root)
    local last, commits, dirty = {}, {}, {}
    if log.code == 0 then
      local t = 0
      for field in log.stdout:gmatch("[^%z]+") do
        local name = field:gsub("^\n+", "")
        if name:sub(1, 1) == "@" then
          t = tonumber(name:sub(2))
        elseif name ~= "" then
          last[name] = last[name] or t
          commits[name] = (commits[name] or 0) + 1
        end
      end
    end
    if status.code == 0 then
      local fields = vim.split(status.stdout, "\0", { plain = true })
      local i = 1
      while i <= #fields do
        local entry = fields[i]
        if #entry > 3 then
          dirty[entry:sub(4)] = true
          -- a rename's entry is followed by its old path
          if entry:sub(1, 1) == "R" or entry:sub(2, 2) == "R" then
            i = i + 1
          end
        end
        i = i + 1
      end
    end
    done({ last = last, commits = commits, dirty = dirty })
  end)
end

-- ===== sending and receiving =====

local function on_branch(root)
  return run({ "git", "symbolic-ref", "-q", "HEAD" }, root).code == 0
end

-- local / remote / merge-base after a fetch, or nil (detached, offline, no upstream).
local function fetch_and_compare(root)
  if not on_branch(root) or run({ "git", "fetch" }, root).code ~= 0 then
    return nil
  end
  local function rev(args)
    local r = run(vim.list_extend({ "git" }, args), root)
    return r.code == 0 and vim.trim(r.stdout) or nil
  end
  local at = { ["local"] = rev({ "rev-parse", "@" }), remote = rev({ "rev-parse", "@{u}" }), base = rev({ "merge-base", "@", "@{u}" }) }
  return (at["local"] and at.remote and at.base) and at or nil
end

--- Receive: fast-forward when only the remote has moved (dev-git-sync.mjs `pullTick`).
--- `changed()` is called when files changed.
function M.pull(repo, changed)
  M.enqueue(function()
    local at = fetch_and_compare(repo.root)
    if not at or at.remote == at["local"] or at.remote == at.base or at["local"] ~= at.base then
      return
    end
    if run({ "git", "merge", "--ff-only", "@{u}" }, repo.root).code == 0 then
      changed()
    end
  end)
end

-- Send: when local has commits the remote lacks, merge the remote's first (a bare push
-- would be rejected), aborting a merge that conflicts, then push (dev-git-sync.mjs `pushTick`).
local function push(root)
  local at = fetch_and_compare(root)
  if not at then
    return false
  end
  if at["local"] == at.remote or at["local"] == at.base then
    return true
  end
  if at.remote ~= at.base and run({ "git", "merge", "--no-edit", "@{u}" }, root).code ~= 0 then
    run({ "git", "merge", "--abort" }, root)
    return false
  end
  return run({ "git", "push" }, root).code == 0
end

--- Commit everything under `paths` and push it (cosense-dev-plugin.mjs `commitTick`, then `pushTick`).
--- `done(ok, committed)` is called when it has finished.
function M.sync(repo, paths, done)
  M.enqueue(function()
    if not on_branch(repo.root) then
      return done(true, false) -- detached: not ours to commit to
    end
    run(vim.list_extend({ "git", "add", "-A", "--" }, paths), repo.root)
    local commit = run(vim.list_extend({ "git", "commit", "-m", "update pages", "--" }, paths), repo.root)
    local out = (commit.stdout or "") .. (commit.stderr or "")
    local committed = commit.code == 0
    if not committed and not out:lower():find("nothing") and not out:find("no changes added") then
      return done(false, false, vim.trim(out))
    end
    done(push(repo.root), committed)
  end)
end

return M
