require'hop'.setup()
vim.api.nvim_set_keymap('n', '<Leader>f', "<cmd>lua require'hop'.hint_words()<cr>", {})
