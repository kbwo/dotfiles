require("hlchunk").setup({
	chunk = {
		enable = true,
		chars = {
			horizontal_line = "─",
			vertical_line = "│",
			left_top = "╭",
			left_bottom = "╰",
			right_arrow = ">",
		},
		notify = true,
		priority = 0,
		style = "#806d9c",
	},
	indent = {
		enable = true,
		notify = false,
		use_treesitter = false,
		chars = { "〡" },
		-- ┃│╏┊︴╷╵╎〡︱
		ahead_lines = 5,
		delay = 100,
	},
})
