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

-- markdown のタグ（`#todo` のように `#` で始まる分類用のラベル）を補完する
-- ための cmp ソース。候補は「いま開いているバッファの中に実際に書かれている
-- タグ」だけで、ほかのファイルは走査しない。
--
-- タグと見なす条件は次の 2 つ。
--   * 行頭、または空白の直後にある `#` であること。
--     `C#` や `page#anchor` のように単語の途中に現れる `#` を除くため。
--   * `#` の直後に、空白でも `#` でもない文字が 1 文字以上続くこと。
--     markdown の見出しは `#` のあとに空白が入る（`# 見出し` `## 見出し`）
--     ので、この条件で見出しが候補に混ざらなくなる。
-- タグ本体に使える文字は、英数字・`_`・`/`（階層タグ用）・`-` と、日本語など
-- のマルチバイト文字（UTF-8 では 1 バイト目以降がすべて 0x80 以上になるので、
-- バイト値 \128-\255 の範囲として一括で許可する）。
local TAG_PATTERN = "#([%w_/\128-\255%-]+)"

-- ``` で囲まれたコードブロックの中は読み飛ばす。多くの言語で `#` は
-- コメント記号なので、拾うと候補がタグでないもので汚れるため。
local function collect_tags(bufnr)
	local tags = {}
	local in_fence = false
	for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
		if line:match("^%s*```") then
			in_fence = not in_fence
		elseif not in_fence then
			local init = 1
			while true do
				local first, last, tag = line:find(TAG_PATTERN, init)
				if not first then
					break
				end
				-- 行頭の場合は「空白が直前にある」のと同じ扱いにする。
				local preceding = first > 1 and line:sub(first - 1, first - 1) or " "
				if preceding:match("%s") then
					tags[tag] = true
				end
				init = last + 1
			end
		end
	end
	return tags
end

local markdown_tag_source = {}

function markdown_tag_source:is_available()
	return vim.bo.filetype == "markdown"
end

-- `#` を打った時点で候補ウィンドウが出るようにする。
function markdown_tag_source:get_trigger_characters()
	return { "#" }
end

-- cmp が「カーソル直前のどこからを入力中の語と見なすか」を決める正規表現
-- （Lua のパターンではなく vim の正規表現）。既定のパターンでは `#` が語の
-- 区切りとして扱われ、`#` を含む候補を絞り込めない。`#` から始まり空白以外が
-- 続く範囲を語とすることで、`#to` と打った時点で `#todo` に絞り込める。
-- 同時に、カーソル直前が `#` で始まる語でないときはこのソースが候補を出さない
-- ことも意味するので、通常の単語を打っているときの補完には影響しない。
function markdown_tag_source:get_keyword_pattern()
	return [[#\S*]]
end

function markdown_tag_source:complete(_, callback)
	local items = {}
	for tag in pairs(collect_tags(0)) do
		table.insert(items, {
			label = "#" .. tag,
			kind = cmp.lsp.CompletionItemKind.Keyword,
		})
	end
	callback({ items = items, isIncomplete = false })
end

cmp.register_source("markdown_tag", markdown_tag_source)

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
		-- 第 2 引数以降のグループは、前のグループが 1 件も候補を出さなかった
		-- ときだけ使われる。タグ補完を第 1 グループに置いているのは、`#tag` を
		-- 打っている最中に buffer や spell の候補が混ざらないようにするため。
		{ name = "markdown_tag" },
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
