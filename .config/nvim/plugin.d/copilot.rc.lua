require('copilot-lsp').setup({
  nes = {
    move_count_threshold = 5, -- Clear after 3 cursor movements
  }
})
vim.g.copilot_nes_debounce = 10
vim.lsp.enable("copilot_ls")
vim.lsp.config("copilot_ls", {
  cmd = {
    'mise', 'exec', 'node@22', '--', 'copilot-language-server', '--stdio'
  }
})

local copilot_ls_disabled_filetypes = {
  markdown = true,
  text = true,
  txt = true,
  log = true,
}

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    if not args.data or not args.data.client_id then
      return
    end

    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client or client.name ~= "copilot_ls" then
      return
    end

    local bufnr = args.buf
    local filetype = vim.bo[bufnr].filetype
    if copilot_ls_disabled_filetypes[filetype] then
      -- Detach Copilot from noisy buffers such as logs and documentation
      vim.schedule(function()
        pcall(vim.lsp.buf_detach_client, bufnr, client.id)
      end)
    end
  end,
})
local function handle_copilot_nes()
  local bufnr = vim.api.nvim_get_current_buf()
  local state = vim.b[bufnr].nes_state
  if state then
    -- Try to jump to the start of the suggestion edit.
    -- If already at the start, then apply the pending suggestion and jump to the end of the edit.
    local _ = require("copilot-lsp.nes").walk_cursor_start_edit()
        or (
          require("copilot-lsp.nes").apply_pending_nes()
          and require("copilot-lsp.nes").walk_cursor_end_edit()
        )
    return nil
  else
    -- Resolving the terminal's inability to distinguish between `TAB` and `<C-i>` in normal mode
    return "<C-i>"
  end
end

vim.keymap.set("n", "<A-y>", handle_copilot_nes, { desc = "Accept Copilot NES suggestion", expr = true })
vim.keymap.set("i", "<A-y>", handle_copilot_nes, { desc = "Accept Copilot NES suggestion", expr = true })
vim.keymap.set("n", "<A-;>", function()
  require('copilot-lsp.nes').clear()
end, { desc = "Clear Copilot suggestion or fallback" })
