vim.keymap.set("n", "<leader>is", "<cmd>AerialToggle<CR>", { desc = "Toggle Outline" })
require("aerial").setup({
	layout = {
		min_width = 55,
	},
	placement = "edge",
	backends = { "treesitter", "lsp", "markdown", "asciidoc", "man" },
})

-- vim.keymap.set("n", "<leader>is", "<cmd>Outline<CR>", { desc = "Toggle Outline" })
-- require("outline").setup({
-- 	symbols = {
-- 		-- icon_fetcher = function(k, buf)
-- 		-- 	return ""
-- 		--4end,
-- 		icons = {
-- 			File = { icon = "F", hl = "Identifier" },
-- 			Module = { icon = "M", hl = "Include" },
-- 			Namespace = { icon = "N", hl = "Include" },
-- 			Package = { icon = "P", hl = "Include" },
-- 			Class = { icon = "C", hl = "Type" },
-- 			Method = { icon = "m", hl = "Function" },
-- 			Property = { icon = "p", hl = "Identifier" },
-- 			Field = { icon = "f", hl = "Identifier" },
-- 			Constructor = { icon = "c", hl = "Special" },
-- 			Enum = { icon = "E", hl = "Type" },
-- 			Interface = { icon = "I", hl = "Type" },
-- 			Function = { icon = "fn", hl = "Function" },
-- 			Variable = { icon = "v", hl = "Constant" },
-- 			Constant = { icon = "K", hl = "Constant" },
-- 			String = { icon = "s", hl = "String" },
-- 			Number = { icon = "#", hl = "Number" },
-- 			Boolean = { icon = "B", hl = "Boolean" },
-- 			Array = { icon = "[]", hl = "Constant" },
-- 			Object = { icon = "O", hl = "Type" },
-- 			Key = { icon = "k", hl = "Type" },
-- 			Null = { icon = "0", hl = "Type" },
-- 			EnumMember = { icon = "e", hl = "Identifier" },
-- 			Struct = { icon = "S", hl = "Structure" },
-- 			Event = { icon = "Ev", hl = "Type" },
-- 			Operator = { icon = "op", hl = "Identifier" },
-- 			TypeParameter = { icon = "T", hl = "Identifier" },
-- 			Component = { icon = "Co", hl = "Function" },
-- 			Fragment = { icon = "Fr", hl = "Constant" },
-- 			TypeAlias = { icon = "Ta", hl = "Type" },
-- 			Parameter = { icon = "Pa", hl = "Identifier" },
-- 			StaticMethod = { icon = "Sm", hl = "Function" },
-- 			Macro = { icon = "Ma", hl = "Function" },
-- 		},
-- 	},
-- 	symbol_folding = {
-- 		-- Depth past which nodes will be folded by default. Set to false to unfold all on open.
-- 		autofold_depth = 4,
-- 		-- When to auto unfold nodes
-- 		auto_unfold = {
-- 			-- Auto unfold currently hovered symbol
-- 			hovered = true,
-- 			-- Auto fold when the root level only has this many nodes.
-- 			-- Set true for 1 node, false for 0.
-- 			only = true,
-- 		},
-- 		markers = { ">>", "<<" },
-- 	},
-- })
