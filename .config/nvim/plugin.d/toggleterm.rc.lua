require("toggleterm").setup({
	size = 25,
	close_on_exit = true,
	auto_scroll = true,
})
local terminal_id = 1

function open_new_terminal()
	require("toggleterm.terminal").Terminal:new({ id = terminal_id, close_on_exit = true, auto_scroll = true }):toggle()
	terminal_id = terminal_id + 1
end

function toggle_or_new_terminal()
	if terminal_id == 1 then
		open_new_terminal()
	else
		vim.cmd("ToggleTerm")
	end
end

vim.api.nvim_set_keymap("n", "<Leader>gt", "<cmd>lua toggle_or_new_terminal()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<c-t>", "<cmd>lua toggle_or_new_terminal()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<Leader>gn", "<cmd>lua open_new_terminal()<CR>", { noremap = true, silent = true })
