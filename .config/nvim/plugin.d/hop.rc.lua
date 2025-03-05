require("hop").setup()
vim.api.nvim_set_keymap("n", "<Leader>f", "<cmd>lua require'hop'.hint_words()<cr>", {})
-- vim.api.nvim_set_keymap("n", "<Leader>f", "<cmd>HopAnywhere<cr>", {})
vim.api.nvim_set_keymap("v", "<Leader>f", "<cmd>lua require'hop'.hint_words({extend_visual = true})<cr>", {})
