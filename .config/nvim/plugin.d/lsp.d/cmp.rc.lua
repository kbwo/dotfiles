local cmp = require("cmp")

-- autolist を <Tab> / <S-Tab> に相乗りさせる。
--
-- markdown バッファでキーを横取りせず cmp 側から呼ぶ形にしているのは、
-- ここでバッファローカルに <Tab> を張ると、その場合だけ cmp の候補選択が
-- 効かなくなるため。下の select_next / select_prev は元の割り当てそのもので、
-- 候補ウィンドウが出ていないときは fallback（= cmp が横取りする前の <Tab> /
-- <S-Tab> の動作）を呼ぶ。autolist が処理しない限り、その経路を通る。
local select_next = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select })
local select_prev = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select })

-- autolist に渡すのは、候補ウィンドウが出ておらず、かつカーソルが
-- リスト項目の前置き（字下げ・マーカー・チェックボックス）にあるときだけ。
-- 項目の内容を打っている最中やリスト以外の行では偽を返すので、<Tab> は
-- これまでどおりの動作になる。markdown 以外の filetype でも偽を返す。
local function autolist_shift(direction)
	if cmp.visible() then
		return false
	end
	local autolist = require("autolist")
	if not autolist.at_item_prefix() then
		return false
	end
	if direction > 0 then
		return autolist.indent()
	end
	return autolist.dedent()
end

cmp.setup({
	enabled = function()
		return not vim.g.skkeleton_enabled
	end,
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
		["<Tab>"] = cmp.mapping(function(fallback)
			if not autolist_shift(1) then
				select_next(fallback)
			end
		end, { "i" }),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if not autolist_shift(-1) then
				select_prev(fallback)
			end
		end, { "i" }),
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
		{ name = "emoji" },                  -- display function signatures with current parameter emphasized
		{ name = "buffer" },                 -- source current buffer
		-- { name = "dictionary",              keyword_length = 2 },
		{ name = "vim-dadbod-completion" },  -- source for math calculation
		{
			name = "spell",
			option = {
				keep_all_entries = false,
				enable_in_context = function()
					return true
				end,
				preselect_correct_word = true,
			},
		},
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

vim.opt.spell = true
vim.opt.spelllang = { "en_us" }
