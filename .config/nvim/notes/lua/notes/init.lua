-- Notes in Cosense notation, kept as txt files under ~/notes (see notes/store.lua
-- for the layout): a card list of them, search, and the operations stderr-blog's
-- browser editor has, while a page itself is edited as any file is.

local M = {}

function M.setup()
  local store = require("notes.store")
  local theme = require("notes.theme")
  theme.setup()
  -- lotus while a local note or the local list is in front. Windows of other kinds (ddu,
  -- help, a terminal) leave the colors as they are, so that picking from a local list does not flash.
  vim.api.nvim_create_autocmd("BufEnter", {
    group = vim.api.nvim_create_augroup("notes_theme_switch", { clear = true }),
    callback = function(ev)
      if vim.bo[ev.buf].filetype == "notes-list" then
        theme.set_local(require("notes.list").shows_local(ev.buf))
      elseif vim.bo[ev.buf].buftype == "" then
        theme.set_local(require("notes.page").is_local(ev.buf))
      end
    end,
  })
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

return M
