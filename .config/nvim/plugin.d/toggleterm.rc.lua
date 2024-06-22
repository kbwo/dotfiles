require("toggleterm").setup{}

vim.api.nvim_set_keymap('n', '<Leader>gt', ':ToggleTerm<CR>', { noremap = true, silent = true })
