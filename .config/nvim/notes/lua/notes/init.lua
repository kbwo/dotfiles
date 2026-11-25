-- Notes in Cosense notation, kept as txt files under ~/notes (see notes/store.lua
-- for the layout): a card list of them, search, and the operations stderr-blog's
-- browser editor has, while a page itself is edited as any file is.

local M = {}

function M.setup()
  local store = require("notes.store")
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

  -- Pages are attached however they were opened: through ~/notes/pages or the directory it links to.
  local patterns = { store.pages_dir() .. "/*.txt" }
  local real = vim.uv.fs_realpath(store.pages_dir())
  if real and real ~= store.pages_dir() then
    patterns[#patterns + 1] = real .. "/*.txt"
  end
  vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
    group = vim.api.nvim_create_augroup("notes_pages", { clear = true }),
    pattern = patterns,
    callback = function(ev)
      require("notes.page").attach(ev.buf)
    end,
  })
end

return M
