require("actions-preview").setup({
	keymap = {
		close = { "<Esc>", "<C-c>" },
	},
	backend = { "nui" },
})

vim.keymap.set({ "n" }, "cca", require("actions-preview").code_actions)

require("hover").setup({
	init = function()
		require("hover.providers.lsp")
	end,
	preview_opts = {
		border = "single",
	},
	preview_window = false,
	title = true,
	mouse_providers = {
		"LSP",
	},
	mouse_delay = 1000,
})
vim.keymap.set("n", "csd", require("hover").hover, { desc = "hover.nvim" })
vim.keymap.set("n", "<c-l>", vim.diagnostic.goto_next)
vim.keymap.set("n", "<c-h>", vim.diagnostic.goto_prev)

-- https://www.reddit.com/r/neovim/comments/nsfv7h/comment/h0nbh3a/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
local function dorename(win)
	local new_name = vim.trim(vim.fn.getline("."))
	vim.api.nvim_win_close(win, true)
	vim.lsp.buf.rename(new_name)
end

local function rename()
	local opts = {
		relative = "cursor",
		row = 0,
		col = 0,
		width = 30,
		height = 1,
		style = "minimal",
		border = "single",
	}
	local cword = vim.fn.expand("<cword>")
	local buf = vim.api.nvim_create_buf(false, true)
	local win = vim.api.nvim_open_win(buf, true, opts)
	local fmt = "<ESC><cmd>lua Rename.dorename(%d)<CR>"

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { cword })
	vim.api.nvim_buf_set_keymap(buf, "i", "<CR>", string.format(fmt, win), { silent = true })
	vim.api.nvim_buf_set_keymap(buf, "n", "<CR>", "i<CR>", { silent = true })
	vim.api.nvim_buf_set_keymap(buf, "n", "<ESC>", "<cmd>quit<CR>", { silent = true })
end

_G.Rename = {
	rename = rename,
	dorename = dorename,
}

vim.keymap.set("n", "ccn", "<cmd>lua Rename.rename()<CR>, {silent = true}")

-- require("trouble").setup({
-- 	focus = true,
-- 	win = {
-- 		size = {
-- 			height = 25,
-- 		},
-- 	},
-- 	modes = {
-- 		split_diag = {
-- 			mode = "diagnostics",
-- 			preview = {
-- 				type = "split",
-- 				relative = "win",
-- 				position = "right",
-- 				size = 0.3,
-- 			},
-- 		},
-- 		diagnostics = {
-- 			groups = {
-- 				{ "filename", format = "{basename:Title} {count}" },
-- 			},
-- 		},
-- 	},
-- 	icons = {},
-- 	keys = {
-- 		["<Leader>ss"] = "jump_split",
-- 		["<Leader>vv"] = "jump_vsplit",
-- 	},
-- })
--
-- vim.keymap.set("n", "<leader>id", "<cmd>Trouble split_diag toggle<CR>, {silent = true}")

require("fidget").setup({
	notification = {
		window = {
			winblend = 0,
		},
	},
})
