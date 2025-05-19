require("debugprint").setup({
	keymaps = {
		normal = {
			plain_below = "gp",
			plain_above = "gP",
			variable_below = "gf",
			variable_above = "gF",
			variable_below_alwaysprompt = nil,
			variable_above_alwaysprompt = nil,
			textobj_below = "go",
			textobj_above = "gO",
			toggle_comment_debug_prints = nil,
			delete_debug_prints = nil,
		},
		visual = {
			variable_below = "gf",
			variable_above = "gF",
		},
	},
})

vim.api.nvim_set_keymap("n", "<leader>gd", ":DeleteDebugPrints<CR>", { noremap = true, silent = true })
