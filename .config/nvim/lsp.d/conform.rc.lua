local rustfmt = require("conform.formatters.rustfmt")
rustfmt.args = function()
	return { "--edition", "2021", "--emit", "stdout" }
end

local is_available = function(name)
	return require("conform").get_formatter_info(name, bufnr).available
end

local prettier_or_lsp = function(bufnr)
	if is_available("prettierd") or is_available("prettier") then
		return { "prettierd", "prettier" }
	else
		return { "lsp" }
	end
end

local stylua_or_lsp = function(bufnr)
	if is_available("stylua") then
		return { "stylua" }
	else
		return { "lsp" }
	end
end

local cs_fixer_or_lsp = function(bufnr)
	if is_available("php_cs_fixer") then
		return { "php_cs_fixer" }
	else
		return { "lsp" }
	end
end

require("conform").setup({
	formatters_by_ft = {
		javascript = prettier_or_lsp,
		typescriptreact = prettier_or_lsp,
		typescript = prettier_or_lsp,
		typescript = prettier_or_lsp,
		json = prettier_or_lsp,
		css = prettier_or_lsp,
		html = prettier_or_lsp,
		lua = stylua_or_lsp,
		rust = { "rustfmt" },
	},
	format_on_save = {
		-- I recommend these options. See :help conform.format for details.
		lsp_fallback = true,
		timeout_ms = 500,
	},
})

vim.api.nvim_create_user_command("Format", function(args)
	local range = nil
	if args.count ~= -1 then
		local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
		range = {
			start = { args.line1, 0 },
			["end"] = { args.line2, end_line:len() },
		}
	end
	require("conform").format({ async = true, lsp_fallback = true, range = range })
end, { range = true })
