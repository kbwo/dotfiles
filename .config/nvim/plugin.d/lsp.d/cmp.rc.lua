local cmp = require("cmp")

cmp.setup({
	snippet = {
		expand = function(args)
			vim.fn["vsnip#anonymous"](args.body)
		end,
	},
	preselect = cmp.PreselectMode.None,
	performance = {
		debounce = 30,
		throttle = 0,
	},
	-- Enable LSP snippets
	mapping = cmp.mapping.preset.insert({
		["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
		["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
		["<Tab>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
		["<S-Tab>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-y>"] = cmp.mapping.confirm({
			select = true,
		}),
	}),
	-- Installed sources:
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
	}, {
		{ name = "path" },
		{ name = "nvim_lsp_signature_help" }, -- display function signatures with current parameter emphasized
		{ name = "nvim_lsp_document_symbol" }, -- display function signatures with current parameter emphasized
		{ name = "emoji" }, -- display function signatures with current parameter emphasized
		{ name = "buffer" }, -- source current buffer
		-- { name = "dictionary",              keyword_length = 2 },
		{ name = "vim-dadbod-completion" }, -- source for math calculation
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

-- require("cmp_dictionary").setup({
--   paths = { "~/.config/nvim/dict/american_english.txt" },
--   exact_length = 2,
-- })
