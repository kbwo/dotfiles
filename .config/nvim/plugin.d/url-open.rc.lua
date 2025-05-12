-- default values
require("url-open").setup({
	-- default will open url with default browser of your system or you can choose your browser like this
	-- open_app = "micorsoft-edge-stable",
	-- google-chrome, firefox, micorsoft-edge-stable, opera, brave, vivaldi
	open_app = "default",
	-- If true, only open the URL when the cursor is in the middle of the URL.
	-- If false, open the next URL found from the cursor position,
	-- which means you can open a URL even when the cursor is in front of the URL or in the middle of the URL.
	open_only_when_cursor_on_url = false,
	highlight_url = {
		all_urls = {
			enabled = true,
			fg = "#21d5ff", -- "text" or "#rrggbb"
			-- fg = "text", -- text will set underline same color with text
			bg = nil, -- nil or "#rrggbb"
			underline = true,
		},
		cursor_move = {
			enabled = false,
			fg = "#199eff", -- "text" or "#rrggbb"
			-- fg = "text", -- text will set underline same color with text
			bg = nil, -- nil or "#rrggbb"
			underline = true,
		},
	},
	deep_pattern = true,
	-- a list of patterns to open url under cursor
	extra_patterns = {
		-- {
		-- 	  pattern = '["]([^%s]*)["]:%s*"[^"]*%d[%d%.]*"',
		-- 	  prefix = "https://www.npmjs.com/package/",
		-- 	  suffix = "",
		-- 	  file_patterns = { "package%.json" },
		-- 	  excluded_file_patterns = nil,
		-- 	  extra_condition = function(pattern_found)
		-- 	    return not vim.tbl_contains({ "version", "proxy" }, pattern_found)
		-- 	  end,
		-- },
		-- so the url will be https://www.npmjs.com/package/[pattern_found]

		-- {
		-- 	  pattern = '["]([^%s]*)["]:%s*"[^"]*%d[%d%.]*"',
		-- 	  prefix = "https://www.npmjs.com/package/",
		-- 	  suffix = "/issues",
		-- 	  file_patterns = { "package%.json" },
		-- 	  excluded_file_patterns = nil,
		-- 	  extra_condition = function(pattern_found)
		-- 	    return not vim.tbl_contains({ "version", "proxy" }, pattern_found)
		-- 	  end,
		-- },
		--
		-- so the url will be https://www.npmjs.com/package/[pattern_found]/issues
	},
})
vim.keymap.set("n", "<Leader>o", "<esc>:URLOpenUnderCursor<cr>")
