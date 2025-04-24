local colors = {
	fg = "#ffffff",
	fg2 = "#353535",
	fg3 = "#a8a8a8",
	bg = "#525252",
	bg3 = "#353535",
	white = "#ffffff",
	black = "#000000",
	yellow = "#ffec50",
	orange = "#ffaf00",
	red = "#ff6510",
	magenta = "#e0898d",
	cyan = "#7bbfff",
	blue = "#235bc8",
	darkblue = "#3672a4",
	green = "#78ff94",
	darkbrown = "#542d24",
}

local custom_theme = {
	normal = {
		a = { fg = colors.fg2, bg = colors.cyan, gui = "bold" },
		b = { fg = colors.fg, bg = colors.darkblue },
		c = { fg = colors.fg, bg = colors.bg },
	},
	insert = { a = { fg = colors.fg2, bg = colors.yellow, gui = "bold" } },
	visual = { a = { fg = colors.fg2, bg = colors.magenta, gui = "bold" } },
	replace = { a = { fg = colors.fg2, bg = colors.green, gui = "bold" } },
	command = { a = { fg = colors.fg2, bg = colors.red, gui = "bold" } },
	terminal = { a = { fg = colors.fg2, bg = colors.orange, gui = "bold" } },
	inactive = {
		a = { fg = colors.fg, bg = colors.bg3, gui = "bold" },
		b = { fg = colors.fg3, bg = colors.bg3 },
		c = { fg = colors.fg3, bg = colors.bg3 },
	},
}
local function filename_with_parent()
	-- Get the full path of the current file
	local filepath = vim.fn.expand("%:p")

	-- Get the filename
	local filename = vim.fn.expand("%:t")

	-- Get the parent directory's name
	local parent_dir = vim.fn.fnamemodify(filepath, ":h:t")

	-- Handle cases where the file is in the root directory
	if parent_dir == "" then
		return filename
	else
		return parent_dir .. "/" .. filename
	end
end

require("lualine").setup({
	options = {
		icons_enabled = false,
		theme = custom_theme,
		component_separators = { left = "", right = "" },
		section_separators = { left = "", right = "" },
		disabled_filetypes = {
			statusline = {},
			winbar = {},
		},
		ignore_focus = {},
		always_divide_middle = true,
		globalstatus = false,
		refresh = {
			statusline = 1000,
			tabline = 1000,
			winbar = 1000,
		},
	},
	sections = {
		lualine_a = {
			{
				"filename",
				file_status = true, -- Displays file status (readonly status, modified status)
				newfile_status = false, -- Display new file status (new file means no write after created)
				path = 1, -- 0: Just the filename
				-- 1: Relative path
				-- 2: Absolute path
				-- 3: Absolute path, with tilde as the home directory
				-- 4: Filename and parent dir, with tilde as the home directory

				shorting_target = 40, -- Shortens path to leave 40 spaces in the window
				-- for other components. (terrible name, any suggestions?)
				symbols = {
					modified = "[+]", -- Text to show when the file is modified.
					readonly = "[-]", -- Text to show when the file is non-modifiable or readonly.
					unnamed = "[No Name]", -- Text to show for unnamed buffers.
					newfile = "[New]", -- Text to show for newly created file before first write
				},
			},
		},
		lualine_b = { "branch", "diff", "diagnostics" },
		-- lualine_c = {'filename'},
		lualine_c = { "g:coc_status", "b:coc_current_function" },
		lualine_x = { "encoding", "fileformat", "filetype" },
		lualine_y = { "progress" },
		lualine_z = { "location" },
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = {
			{
				"filename",
				file_status = true, -- Displays file status (readonly status, modified status)
				newfile_status = false, -- Display new file status (new file means no write after created)
				path = 1, -- 0: Just the filename
				-- 1: Relative path
				-- 2: Absolute path
				-- 3: Absolute path, with tilde as the home directory
				-- 4: Filename and parent dir, with tilde as the home directory

				shorting_target = 40, -- Shortens path to leave 40 spaces in the window
				-- for other components. (terrible name, any suggestions?)
				symbols = {
					modified = "[+]", -- Text to show when the file is modified.
					readonly = "[-]", -- Text to show when the file is non-modifiable or readonly.
					unnamed = "[No Name]", -- Text to show for unnamed buffers.
					newfile = "[New]", -- Text to show for newly created file before first write
				},
			},
		},
		lualine_x = { "location" },
		lualine_y = {},
		lualine_z = {},
	},
	tabline = {},
	winbar = {},
	inactive_winbar = {},
	extensions = {},
})

vim.api.nvim_create_augroup("LualineTermColor", { clear = true })

-- Terminal バッファに入った／フォーカスされたとき
vim.api.nvim_create_autocmd({ "TermOpen", "TermEnter", "WinEnter", "BufEnter" }, {
	group = "LualineTermColor",
	callback = function()
		if vim.bo.buftype == "terminal" then
			-- ステータスライン本体を赤背景に
			vim.api.nvim_set_hl(0, "LualineNormal", { bg = "#ff0000", fg = "#ffffff" })
			-- 区切り線も同色に
			vim.api.nvim_set_hl(0, "LualineComponentSeparator", { fg = "#ff0000" })
		end
	end,
})

-- Terminal 以外のバッファに戻ったとき
vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave" }, {
	group = "LualineTermColor",
	callback = function()
		-- lualine を再描画して元のテーマ色に戻す
		require("lualine").refresh()
	end,
})
