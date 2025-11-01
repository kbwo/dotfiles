local mason_lspconfig = require("mason-lspconfig")

local capabilities = vim.tbl_deep_extend("force", require("cmp_nvim_lsp").default_capabilities(), {
	workspace = {
		didChangeWatchedFiles = {
			dynamicRegistration = true,
		},
	},
})

-- vim.lsp.config("*", {
-- 	capabilities = capabilities,
-- 	settings = {
-- 		documentFormatting = false,
-- 		javascript = { suggest = { completeFunctionCalls = true } },
-- 		typescript = { suggest = { completeFunctionCalls = true } },
-- 	},
-- })

-- copilot-language-server
vim.lsp.config("copilot_ls", {
	cmd = {
		'mise', 'exec', 'node@22', '--', 'copilot-language-server', '--stdio'
	}
})

require("mason").setup({
	ui = {
		keymaps = {
			---@since 1.0.0
			-- Keymap to expand a package
			toggle_package_expand = "<CR>",
			---@since 1.0.0
			-- Keymap to install the package under the current cursor position
			install_package = "i",
			---@since 1.0.0
			-- Keymap to reinstall/update the package under the current cursor position
			update_package = "u",
			---@since 1.0.0
			-- Keymap to check for new version for the package under the current cursor position
			check_package_version = "c",
			---@since 1.0.0
			-- Keymap to update all installed packages
			update_all_packages = "U",
			---@since 1.0.0
			-- Keymap to check which installed packages are outdated
			check_outdated_packages = "C",
			---@since 1.0.0
			-- Keymap to uninstall a package
			uninstall_package = "X",
			---@since 1.0.0
			-- Keymap to cancel a package installation
			cancel_installation = "<C-c>",
			---@since 1.0.0
			-- Keymap to apply language filter
			apply_language_filter = "<C-u>",
			---@since 1.1.0
			-- Keymap to toggle viewing package installation log
			toggle_package_install_log = "<CR>",
			---@since 1.8.0
			-- Keymap to toggle the help view
			toggle_help = "g?",
		},
	},
})
mason_lspconfig.setup({
	automatic_enable = true,
	automatic_installation = true,
	ensure_installed = {
		"clangd",
		"cssls",
		"cssmodules_ls",
		"denols",
		"docker_compose_language_service",
		"dockerls",
		"eslint",
		"gopls",
		"graphql",
		"html",
		"jsonls",
		"prismals",
		-- "ts_ls",
		"vimls",
		"zls",
	},
})

vim.lsp.enable(mason_lspconfig.get_installed_servers())
vim.lsp.enable("jsonls")
vim.lsp.enable("jsonlint")

require("testing-ls").setup({})

vim.lsp.handlers["window/showMessage"] = function(_, result, ctx)
	local client = vim.lsp.get_client_by_id(ctx.client_id)
	-- require("notify")("LSP (" .. client.name .. "): " .. result.message)
	local logLeel = vim.log.levels.INFO
	if result.type == vim.lsp.protocol.MessageType.Error then
		logLeel = vim.log.levels.ERROR
	end
	if result.type == vim.lsp.protocol.MessageType.Warning then
		logLeel = vim.log.levels.WARN
	end
	require("fidget").notify("LSP (" .. client.name .. "): " .. result.message, logLeel)
end

-- vim.lsp.set_log_level("debug")

-- rust-analyzer interupts neovim while typing · Issue  https://github.com/rust-lang/rust-analyzer/issues/18434
-- LSP: rust_analyzer: -32802: server cancelled the request · Issue  https://github.com/neovim/neovim/issues/30985
for _, method in ipairs({ "textDocument/diagnostic", "workspace/diagnostic" }) do
	local default_diagnostic_handler = vim.lsp.handlers[method]
	vim.lsp.handlers[method] = function(err, result, context, config)
		if err ~= nil and err.code == -32802 then
			return
		end
		return default_diagnostic_handler(err, result, context, config)
	end
end

vim.lsp.inlay_hint.enable(true)

vim.g.rustaceanvim = {
	-- Plugin configuration
	tools = {
	},
	-- LSP configuration
	server = {
		on_attach = function(client, bufnr)
			-- you can also put keymaps in here
		end,
		default_settings = {
			-- rust-analyzer language server configuration
			["rust-analyzer"] = {
				cargo = {
					features = "all",
					buildScripts = {
						enable = true,
					},
				},
				-- enable clippy on save
				checkOnSave = {
					command = "clippy",
				},
				check = {
					command = "clippy",
				},
				diagnostics = {
					disabled = {
						"unresolved-proc-macro",
						"inactive-code",
					},
				},
			},
		},
	},
	-- DAP configuration
	dap = {
	},
}
