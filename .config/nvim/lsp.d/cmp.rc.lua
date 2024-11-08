local cmp = require("cmp")
local compare = require("cmp.config.compare")

cmp.setup({
	preselect = cmp.PreselectMode.None,
	-- Enable LSP snippets
	mapping = {
		["<C-p>"] = cmp.mapping.select_prev_item(),
		["<C-n>"] = cmp.mapping.select_next_item(),
		-- Add tab support
		["<S-Tab>"] = cmp.mapping.select_prev_item(),
		["<Tab>"] = cmp.mapping.select_next_item(),
		["<C-S-f>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.close(),
		["<C-y>"] = cmp.mapping.confirm({
			behavior = cmp.ConfirmBehavior.Insert,
			select = false,
		}),
	},
	-- Installed sources:
	sources = {
		{ name = "yank" },
		{ name = "path" }, -- file paths
		{ name = "nvim_lsp" }, -- from language server
		{ name = "nvim_lsp_signature_help" }, -- display function signatures with current parameter emphasized
		{ name = "nvim_lsp_document_symbol" }, -- display function signatures with current parameter emphasized
		{ name = "emoji" }, -- display function signatures with current parameter emphasized
		{ name = "html-css" },
		{ name = "crates", keyword_length = 2 },
		{ name = "nvim_lua", keyword_length = 2 }, -- complete neovim's Lua runtime API such vim.lsp.*
		{ name = "buffer" }, -- source current buffer
		{ name = "dictionary", keyword_length = 2 },
		{ name = "calc" }, -- source for math calculation
		{ name = "vim-dadbod-completion" }, -- source for math calculation
		{ name = "chrisgrieser/cmp_yanky" },
	},
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
	formatting = {
		fields = { "menu", "abbr", "kind" },
		format = function(entry, item)
			local menu_icon = {
				nvim_lsp = "λ",
				buffer = "Ω",
				path = "🖫",
			}
			item.menu = menu_icon[entry.source.name]
			return item
		end,
	},
})

require("cmp_dictionary").setup({
	paths = { "~/.config/nvim/dict/american_english.txt" },
	exact_length = 2,
})
