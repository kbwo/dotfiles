require("toggleterm").setup{}
local terminal_id = 1

function open_new_terminal()
  require("toggleterm.terminal").Terminal:new({ id = terminal_id }):toggle()
  terminal_id = terminal_id + 1
end

vim.api.nvim_set_keymap('n', '<Leader>gt', ':ToggleTerm<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<Leader>gn", "<cmd>lua open_new_terminal()<CR>", { noremap = true, silent = true })
