local ft = require("Comment.ft")
local api = require("Comment.api")

vim.g.skip_ts_context_commentstring_module = true

require("ts_context_commentstring").setup({})

require("Comment").setup({
	create_mappings = false,
	pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
	toggler = {
		line = "<Leader>cc",
	},
	opleader = {
		line = "<Leader>cc",
	},
})

ft({ "mysql", "postgresql" }, ft.get("sql"))
