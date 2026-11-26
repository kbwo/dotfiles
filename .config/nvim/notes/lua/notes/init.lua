-- Notes in Cosense notation, kept as txt files under ~/notes (see notes/store.lua
-- for the layout): a card list of them, search, and the operations stderr-blog's
-- browser editor has, while a page itself is edited as any file is.

local M = {}

function M.setup()
  local store = require("notes.store")
  require("notes.theme").setup() -- the colours, local's windows' included
  vim.api.nvim_create_user_command("Notes", function()
    require("notes.list").open()
  end, { desc = "メモの一覧" })
  vim.api.nvim_create_user_command("NotesNew", function(opts)
    if not store.ensure_root() then
      return
    end
    local title = opts.args ~= "" and opts.args or vim.trim(vim.fn.input("新しいページのタイトル: "))
    if title ~= "" then
      require("notes.page").open_title(title, "remote", true)
    end
  end, { nargs = "?", desc = "新しいメモ" })
  vim.api.nvim_create_user_command("NotesPasteUrl", function()
    require("notes.page").paste_url()
  end, { desc = "クリップボードの URL を、そのページのタイトル付きで貼る" })
  vim.keymap.set("n", "<Leader>nl", "<Cmd>Notes<CR>", { desc = "メモの一覧" })

  require("notes.edit").setup()
  require("notes.complete").setup()

  -- Pages are attached however they were opened: through ~/notes/pages or the directory it links to.
  local dirs = { store.pages_dir() }
  local real = vim.uv.fs_realpath(store.pages_dir())
  if real and real ~= store.pages_dir() then
    dirs[#dirs + 1] = real
  end
  local patterns, filetypes = {}, {}
  for _, dir in ipairs(dirs) do
    patterns[#patterns + 1] = dir .. "/*.txt"
    -- Above the *.txt extension, which would make it text.
    -- vim.filetype anchors the pattern to the whole path itself.
    filetypes[vim.pesc(dir) .. "/.*%.txt"] = { "notes", { priority = math.huge } }
  end
  vim.filetype.add({ pattern = filetypes })
  vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
    group = vim.api.nvim_create_augroup("notes_pages", { clear = true }),
    pattern = patterns,
    callback = function(ev)
      require("notes.page").attach(ev.buf)
    end,
  })
end

--- Open the pages again so that code reloaded by :Sov decorates them. A page's buffer is
--- wiped first, because `:edit` alone would keep the old code's buffer-local autocmds
--- and keymaps beside the new ones. Pages with unsaved changes are left as they are.
function M.reopen_pages()
  local skipped = {}
  local from = vim.api.nvim_get_current_win()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == "notes" then
      local name = vim.api.nvim_buf_get_name(buf)
      if vim.bo[buf].modified then
        skipped[#skipped + 1] = vim.fn.fnamemodify(name, ":t")
      else
        local wins, cursors = vim.fn.win_findbuf(buf), {}
        -- Windows showing the page hold a scratch buffer meanwhile, so wiping it does not close them.
        local tmp = vim.api.nvim_create_buf(false, true)
        for _, win in ipairs(wins) do
          cursors[win] = vim.api.nvim_win_get_cursor(win)
          vim.api.nvim_win_call(win, function()
            vim.cmd("noautocmd buffer " .. tmp) -- a step of the reopening, not a buffer to react to
          end)
        end
        vim.api.nvim_buf_delete(buf, {})
        if #wins == 0 then
          vim.bo[vim.fn.bufadd(name)].buflisted = true -- loaded, and so attached, when next entered
        else
          -- The page is opened from its window made current, not through nvim_win_call: BufWinEnter
          -- autocmds look the current window up in the current tab's layout (windows.nvim does),
          -- and nvim_win_call on a window in another tab leaves them a layout without it.
          vim.api.nvim_set_current_win(wins[1])
          vim.cmd.edit(vim.fn.fnameescape(name))
          local new = vim.api.nvim_get_current_buf()
          for _, win in ipairs(wins) do
            vim.api.nvim_set_current_win(win)
            vim.cmd.buffer(new)
            pcall(vim.api.nvim_win_set_cursor, win, cursors[win])
          end
        end
        vim.api.nvim_buf_delete(tmp, { force = true })
      end
    end
  end
  if vim.api.nvim_win_is_valid(from) then
    vim.api.nvim_set_current_win(from)
  end
  if #skipped > 0 then
    vim.notify("保存していないので開き直しませんでした: " .. table.concat(skipped, ", "), vim.log.levels.WARN)
  end
end

return M
