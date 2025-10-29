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
		enable = false,
	},
})
