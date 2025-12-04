vim.o.winminwidth = 12
require("windows").setup({
	autowidth = { --           |windows.autowidth|
		enable = true,
		winwidth = 20, --            |windows.winwidth|
		filetype = { --        |windows.autowidth.filetype|
			help = 2,
		},
	},
})
