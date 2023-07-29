require("mason").setup()
require("mason-lspconfig").setup()
require("mason-tool-installer").setup({
				ensure_installed = {
					-- lua
					"lua-language-server",
					"stylua",
					-- typescript
					"typescript-language-server",
					"prettier",
					-- shell
					"bash-language-server",
					"beautysh",
				},
				auto_update = false,
				run_on_start = true,
			})
