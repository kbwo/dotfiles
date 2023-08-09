-- local lsp = require('lsp-zero').preset({})

-- lsp.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  -- lsp.default_keymaps({buffer = bufnr})
-- end)

-- (Optional) Configure lua language server for neovim
-- require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())

-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#configurations
-- lsp.ensure_installed({
--   'clangd',
--   'cssls',
--   'cssmodules_ls',
--   'denols',
--   'docker_compose_language_service',
--   'dockerls',
--   'eslint',
--   'gopls',
--   'graphql',
--   'html',
--   'intelephense',
--   'jsonls',
--   'prismals',
--   'rust_analyzer',
--   'tsserver',
--   'vimls',
--   'volar',
--   'zls'
-- })
--
-- lsp.setup()

require("fidget").setup { }




-- local function on_attach(client, buffer)
--   -- This callback is called when the LSP is atttached/enabled for this buffer
--   -- we could set keymaps related to LSP, etc here.
-- end
-- local opts = {
--   tools = {
--     runnables = {
--       use_telescope = true,
--     },
--     inlay_hints = {
--       auto = true,
--       show_parameter_hints = false,
--       parameter_hints_prefix = "",
--       other_hints_prefix = "",
--     },
--   },
--
--   -- all the opts to send to nvim-lspconfig
--   -- these override the defaults set by rust-tools.nvim
--   -- see https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#rust_analyzer
--   server = {
--     -- on_attach is a callback called when the language server attachs to the buffer
--     on_attach = on_attach,
--     settings = {
--       -- to enable rust-analyzer settings visit:
--       -- https://github.com/rust-analyzer/rust-analyzer/blob/master/docs/user/generated_config.adoc
--       ["rust-analyzer"] = {
--         -- enable clippy on save
--         checkOnSave = {
--           command = "clippy",
--         },
--         check = {
--           command = "clippy",
--         },
--         procMacro = {
--           enable = true
--         },
--         diagnostics = {
--           disabled = {
--             "unresolved-proc-macro"
--           }
--         }
--       },
--     },
--   },
-- }
--
-- require("rust-tools").setup(opts)
