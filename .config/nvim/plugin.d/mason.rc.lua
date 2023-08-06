require("mason").setup()
-- require("mason-lspconfig").setup()
-- require("mason-tool-installer").setup({
-- 				ensure_installed = {
-- 					-- lua
-- 					"lua-language-server",
-- 					"stylua",
-- 					-- typescript
-- 					"typescript-language-server",
-- 					"prettier",
-- 					-- shell
-- 					"bash-language-server",
-- 					"beautysh",
-- 				},
-- 				auto_update = false,
-- 				run_on_start = true,
-- 			})
require("mason-lspconfig").setup({
  ensure_installed = {
    "tsserver",
    "volar",
    "tailwindcss",
    "cssls",
    "yamlls",
    "prismals",
    "emmet_ls",
    "lua_ls",
    "pyright",
    "denols",
    "rust_analyzer",
    "gopls",
    -- "jdtls",
    "eslint",
    "jsonls",
    -- "marksman",
    "html",
  },
  automatic_installation = true,
})

