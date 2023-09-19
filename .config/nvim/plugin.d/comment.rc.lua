require('Comment').setup({
  create_mappings = false,
  pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
})

vim.keymap.set('n', '<C-_><C-_>', '<Plug>(comment_toggle_linewise_current)', { remap = true })
vim.keymap.set('n', '<C-/><C-/>', '<Plug>(comment_toggle_linewise_current)', { remap = true })
vim.keymap.set('v', '<C-_><C-_>', '<Plug>(comment_toggle_linewise_visual)', { remap = true })
vim.keymap.set('v', '<C-/><C-/>', '<Plug>(comment_toggle_linewise_visual)', { remap = true })
