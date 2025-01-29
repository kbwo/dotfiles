local mason_lspconfig = require("mason-lspconfig")
local lspconfig = require("lspconfig")

local capabilities = require("cmp_nvim_lsp").default_capabilities()
-- local capabilities = require("ddc_source_lsp").make_client_capabilities()
capabilities = vim.tbl_deep_extend("force", capabilities, {
	workspace = {
		didChangeWatchedFiles = {
			dynamicRegistration = true,
		},
	},
})

-- About server: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md

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
		"ts_ls",
		"vimls",
		"zls",
	},
})

function IsNodeRepo()
	local node_root_dir = lspconfig.util.root_pattern("package.json")
	function HasPackageJson()
		local current_directory = vim.fn.getcwd()
		local package_json_path = current_directory .. "/package.json"
		return vim.fn.filereadable(package_json_path) == 1
	end

	local is_node_repo = node_root_dir(vim.api.nvim_buf_get_name(0)) ~= nil or HasPackageJson()
	return is_node_repo
end

mason_lspconfig.setup_handlers({
	function(server_name)
		local opts = {}

		if server_name == "vtsls" or server_name == "ts_ls" or server_name == "eslint" then
			-- if not is_node_repo then
			--   return
			-- end
			opts.settings = {
				documentFormatting = false,
				javascript = { suggest = { completeFunctionCalls = true } },
				typescript = { suggest = { completeFunctionCalls = true } },
			}
		elseif server_name == "yamlls" then
			opts.settings = {
				yaml = {
					schemas = {
						["https://raw.githubusercontent.com/instrumenta/kubernetes-json-schema/master/v1.18.0-standalone-strict/all.json"] =
						"/*.k8s.yaml",
					},
				},
			}
		elseif server_name == "denols" then
			if IsNodeRepo() then
				return
			end

			opts.root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc", "deps.ts", "import_map.json")
			opts.init_options = {
				lint = true,
				unstable = true,
				suggest = {
					imports = {
						hosts = {
							["https://deno.land"] = true,
							["https://cdn.nest.land"] = true,
							["https://crux.land"] = true,
						},
					},
				},
			}
		end

		if server_name == "svelte" then
			opts.on_attach = function(client, bufnr)
				vim.api.nvim_create_autocmd("BufWritePost", {
					pattern = { "*.js", "*.ts" },
					callback = function(ctx)
						client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.match })
					end,
				})
			end
		end

		lspconfig[server_name].setup(opts)
	end,
	["lua_ls"] = function()
		lspconfig.lua_ls.setup({
			settings = {
				Lua = {
					diagnostics = {
						-- Recognize the `vim` global
						globals = { "vim" },
					},
					workspace = {
						-- Make language server aware of runtime files
						library = {
							[vim.fn.expand("$VIMRUNTIME/lua")] = true,
							[vim.fn.stdpath("config") .. "/lua"] = true,
						},
					},
				},
			},
		})
	end,
	["basedpyright"] = function()
		lspconfig.basedpyright.setup({
			capabilities = capabilities,
			settings = {
				basedpyright = {
					analysis = {
						diagnosticSeverityOverrides = {
							reportMissingTypeStubs = "none",
						},
					},
				},
			},
		})
	end,
	["rust_analyzer"] = function() end,
	["ts_ls"] = function()
		if not IsNodeRepo() then
			return
		end
	end,
	["yamlls"] = function()
		-- AWS CloudFormation
		lspconfig.yamlls.setup({
			capabilities = capabilities,
			settings = {
				yaml = {
					schemas = {
						["https://cfn-schema.y13i.com/schema?region=eu-west-2&version=20.0.0"] = "cloudformation/*",
						["http://json.schemastore.org/github-workflow"] = ".github/workflows/*",
					},
					format = { enable = false },
					completion = true,
					hover = true,
					customTags = {
						"!And scalar",
						"!And mapping",
						"!And sequence",
						"!Condition scalar",
						"!Condition mapping",
						"!Condition sequence",
						"!Base64 scalar",
						"!Base64 mapping",
						"!Base64 sequence",
						"!If scalar",
						"!If mapping",
						"!If sequence",
						"!Not scalar",
						"!Not mapping",
						"!Not sequence",
						"!Equals scalar",
						"!Equals mapping",
						"!Equals sequence",
						"!Or scalar",
						"!Or mapping",
						"!Or sequence",
						"!FindInMap scalar",
						"!FindInMap mappping",
						"!FindInMap sequence",
						"!Base64 scalar",
						"!Base64 mapping",
						"!Base64 sequence",
						"!Cidr scalar",
						"!Cidr mapping",
						"!Cidr sequence",
						"!Ref scalar",
						"!Ref mapping",
						"!Ref sequence",
						"!Sub scalar",
						"!Sub mapping",
						"!Sub sequence",
						"!GetAtt scalar",
						"!GetAtt mapping",
						"!GetAtt sequence",
						"!GetAZs scalar",
						"!GetAZs mapping",
						"!GetAZs sequence",
						"!ImportValue scalar",
						"!ImportValue mapping",
						"!ImportValue sequence",
						"!Select scalar",
						"!Select mapping",
						"!Select sequence",
						"!Split scalar",
						"!Split mapping",
						"!Split sequence",
						"!Join scalar",
						"!Join mapping",
						"!Join sequence",
					},
				},
			},
		})
	end,
})

vim.g.rustaceanvim = {
	tools = {
		runnables = {
			use_telescope = true,
		},
	},

	-- all the opts to send to nvim-lspconfig
	-- these override the defaults set by rust-tools.nvim
	-- see https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#rust_analyzer
	server = {
		cmd = function()
			local mason_registry = require("mason-registry")
			if mason_registry.is_installed("rust-analyzer") then
				-- This may need to be tweaked depending on the operating system.
				local ra = mason_registry.get_package("rust-analyzer")
				local ra_filename = ra:get_receipt():get().links.bin["rust-analyzer"]
				return { ("%s/%s"):format(ra:get_install_path(), ra_filename or "rust-analyzer") }
			else
				-- global installation
				return { "rust-analyzer" }
			end
		end,
		settings = {
			-- to enable rust-analyzer settings visit:
			-- https://github.com/rust-analyzer/rust-analyzer/blob/master/docs/user/generated_config.adoc
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
}
vim.diagnostic.config({ virtual_text = false })

require("typescript-tools").setup({})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
	callback = function()
		vim.api.nvim_buf_set_keymap(0, "n", "cco", ":TSToolsAddMissingImports<CR>", { noremap = true, silent = true })

		vim.api.nvim_buf_set_keymap(0, "n", "ccr", ":TSToolsRemoveUnusedImports<CR>", { noremap = true, silent = true })
	end,
})
local configs = require("lspconfig.configs")
local util = require("lspconfig/util")

require("testing-ls").setup({})
lspconfig.diagnosticls.setup({})

-- A better way to separate lsp running between denols and tsserver. · Issue  https://github.com/pmizio/typescript-tools.nvim/issues/248
require("typescript-tools").setup({
	root_dir = function(path)
		local marker = require("climbdir.marker")
		return require("climbdir").climb(
			path,
			marker.one_of(
				marker.has_readable_file("package.json"),
				marker.has_directory("node_modules"),
				marker.all_of(marker.has_directory(".git"), function(path)
					local result = marker.one_of(
						marker.has_readable_file("deno.json"),
						marker.has_readable_file("deno.jsonc"),
						marker.has_readable_file("import_map.json"),
						marker.has_directory("denops")
					)(path)
					return not result
				end)
			),
			{
				halt = marker.one_of(
					marker.has_readable_file("deno.json"),
					marker.has_readable_file("deno.jsonc"),
					marker.has_readable_file("import_map.json"),
					marker.has_directory("denops")
				),
			}
		)
	end,
	single_file_support = false,
})

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
