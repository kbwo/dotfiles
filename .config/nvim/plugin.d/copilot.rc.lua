vim.lsp.config("copilot", {
  cmd = {
    'mise', 'exec', 'node@22', '--', 'copilot-language-server', '--stdio'
  },
  filetypes = function(bufnr)
    -- Disable for markdown files
    if vim.bo[bufnr].filetype == "markdown" then
      return false
    end
    return true
  end
})
require("sidekick").setup({})
vim.keymap.set("n", "<A-y>", require("sidekick").nes_jump_or_apply, { desc = "Accept Copilot NES suggestion", expr = true })
vim.keymap.set("i", "<A-y>", require("sidekick").nes_jump_or_apply, { desc = "Accept Copilot NES suggestion", expr = true })
vim.keymap.set("n", "<A-;>", function()
  require("sidekick.nes").clear()
end, { desc = "Clear Copilot suggestion or fallback" })
