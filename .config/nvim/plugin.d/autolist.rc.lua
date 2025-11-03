require("list").setup()

-- Set up keymaps for markdown/text files
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "markdown", "text" },
	callback = function()
		local list = require("list")
		-- Toggle checkbox with Enter in normal mode
		vim.keymap.set("n", "<cr>", list.toggle_checkbox, { buffer = true })
		vim.keymap.set('n', '<A-l>', function()
			list.cycle_sibling_list_format()
		end, { buffer = true })
		vim.keymap.set('n', '<A-L>', function()
			list.cycle_all_list_format()
		end, { buffer = true })
	end,
})


