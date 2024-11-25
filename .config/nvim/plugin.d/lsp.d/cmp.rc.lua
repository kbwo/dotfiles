local cmp = require("cmp")

cmp.setup({
	performance = {
		debounce = 30,
		throttle = 0,
	},
	snippet = {
		expand = function(args)
			vim.fn["vsnip#anonymous"](args.body)
		end,
	},
	preselect = cmp.PreselectMode.None,
	-- Enable LSP snippets
	mapping = cmp.mapping.preset.insert({
		["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
		["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
		["<Tab>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
		["<S-Tab>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-y>"] = cmp.mapping.confirm({
			select = false,
			behavior = cmp.ConfirmBehavior.Replace,
		}),
	}),
	-- Installed sources:
	sources = cmp.config.sources({
		{ name = 'nvim_lsp' },
		{ name = 'vsnip' },
	}, {
		{ name = "yank" },
		{ name = "path" },                   -- file paths
		{ name = "nvim_lsp_signature_help" }, -- display function signatures with current parameter emphasized
		{ name = "nvim_lsp_document_symbol" }, -- display function signatures with current parameter emphasized
		{ name = "emoji" },                  -- display function signatures with current parameter emphasized
		{ name = "html-css" },
		{ name = "crates",                  keyword_length = 2 },
		{ name = "nvim_lua",                keyword_length = 2 }, -- complete neovim's Lua runtime API such vim.lsp.*
		{ name = "dotenv" },                                    -- source current buffer
		{ name = "buffer" },                                    -- source current buffer
		{ name = "chrisgrieser/cmp_yanky" },
		{ name = "dictionary",              keyword_length = 2 },
		{ name = "calc" },                -- source for math calculation
		{ name = "vim-dadbod-completion" }, -- source for math calculation
		{ name = "treesitter" },          -- source for math calculation
	}),
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
				path = "Π",
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
