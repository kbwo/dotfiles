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
local mason_lspconfig = require("mason-lspconfig")
local nvim_lsp = require('lspconfig')
local update_capabilities = function(capabilities)
  local completionItem = capabilities.textDocument.completion.completionItem

  completionItem.snippetSupport = true
  completionItem.preselectSupport = true
  completionItem.insertReplaceSupport = true
  completionItem.labelDetailsSupport = true
  completionItem.deprecatedSupport = true
  completionItem.commitCharactersSupport = true
  completionItem.tagSupport = { valueSet = { 1 } }
  completionItem.resolveSupport =
    { properties = { 'documentation', 'detail', 'additionalTextEdits' } }

  return capabilities
end

mason_lspconfig.setup({
  automatic_installation = true,
	ensure_installed = {
		'clangd',
		'cssls',
		'cssmodules_ls',
		'denols',
		'docker_compose_language_service',
		'dockerls',
		'eslint',
		'gopls',
		'graphql',
		'html',
		'intelephense',
		'jsonls',
		'prismals',
		'rust_analyzer',
		'tsserver',
		'vimls',
		'volar',
		'zls'
	}
})

local function on_attach(client, buffer)
  -- This callback is called when the LSP is atttached/enabled for this buffer
  -- we could set keymaps related to LSP, etc here.
end

local rt_opts = {
  tools = {
    runnables = {
      use_telescope = true,
    },
    inlay_hints = {
      auto = true,
      show_parameter_hints = false,
      parameter_hints_prefix = "",
      other_hints_prefix = "",
    },
  },

  -- all the opts to send to nvim-lspconfig
  -- these override the defaults set by rust-tools.nvim
  -- see https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#rust_analyzer
  server = {
    -- on_attach is a callback called when the language server attachs to the buffer
    on_attach = on_attach,
    settings = {
      -- to enable rust-analyzer settings visit:
      -- https://github.com/rust-analyzer/rust-analyzer/blob/master/docs/user/generated_config.adoc
      ["rust-analyzer"] = {
        -- enable clippy on save
        checkOnSave = {
          command = "clippy",
        },
        check = {
          command = "clippy",
        },
        procMacro = {
          enable = true
        },
        diagnostics = {
          disabled = {
            "unresolved-proc-macro"
          }
        }
      },
    },
  },
}

-- mason_lspconfig.setup_handlers({
-- 	-- The first entry (without a key) will be the default handler
-- 	-- and will be called for each installed server that doesn't have
-- 	-- a dedicated handler.
--   function(server_name)
--     local node_root_dir = nvim_lsp.util.root_pattern("package.json")
--     local is_node_repo = node_root_dir(vim.api.nvim_buf_get_name(0)) ~= nil
--
--     local opts = {}
--
--     if server_name == "tsserver" then
--       if not is_node_repo then
--         return
--       end
--
--       opts.root_dir = node_root_dir
--     elseif server_name == "eslint" then
--       if not is_node_repo then
--         return
--       end
--
--       opts.root_dir = node_root_dir
--     elseif server_name == "denols" then
--       if is_node_repo then
--         return
--       end
--
--       opts.root_dir = nvim_lsp.util.root_pattern("deno.json", "deno.jsonc", "deps.ts", "import_map.json")
--       opts.init_options = {
--         lint = true,
--         unstable = true,
--         suggest = {
--           imports = {
--             hosts = {
--               ["https://deno.land"] = true,
--               ["https://cdn.nest.land"] = true,
--               ["https://crux.land"] = true
--             }
--           }
--         }
--       }
--     end
--
--     nvim_lsp[server_name].setup(opts)
--   end,
-- 	-- Next, you can provide a dedicated handler for specific servers.
-- 	-- For example, a handler override for the `rust_analyzer`:
-- })
mason_lspconfig.setup_handlers({
  function(server_name)
    local node_root_dir = nvim_lsp.util.root_pattern('package.json')
    local is_node_repo = node_root_dir(vim.api.nvim_buf_get_name(0)) ~= nil

    local opts = {}

    opts.capabilities = update_capabilities(vim.lsp.protocol.make_client_capabilities())
    -- vim.api.nvim_echo({{'server_name'}, {server_name, 'warningmsg'}}, true, {})

    if server_name == 'vtsls' or server_name == 'tsserver' then
      if not is_node_repo then
        return
      end
      opts.settings = {
        documentFormatting = false,
        javascript = { suggest = { completeFunctionCalls = true } },
        typescript = { suggest = { completeFunctionCalls = true } },
      }
    elseif server_name == 'denols' then
      if is_node_repo then
        return
      end

      opts.root_dir =
        nvim_lsp.util.root_pattern('deno.json', 'deno.jsonc', 'deps.ts', 'import_map.json')
      opts.init_options = {
        lint = true,
        unstable = true,
        suggest = {
          imports = {
            hosts = {
              ['https://deno.land'] = true,
              ['https://cdn.nest.land'] = true,
              ['https://crux.land'] = true,
            },
          },
        },
      }
    elseif server_name == 'lua_ls' then
      -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#lua_ls
      local library = vim.api.nvim_get_runtime_file('', true)

      opts.settings = {
        Lua = {
          runtime = {
            version = 'LuaJIT',
            path = { 'lua/?.lua', 'lua/?/init.lua' },
          },
          completion = { callSnippet = 'Both' },
          diagnostics = { globals = { 'vim' } },
          workspace = { library = library },
          telemetry = { enable = false },
        },
      }
    end

    opts.on_attach = function(_, bufnr)
      local bufopts = { silent = true, buffer = bufnr }
      vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
      vim.keymap.set('n', 'gtD', vim.lsp.buf.type_definition, bufopts)
      vim.keymap.set('n', 'grf', vim.lsp.buf.references, bufopts)
      -- vim.keymap.set('n', '<space>p', vim.lsp.buf.format or vim.lsp.buf.formatting, bufopts)
    end

    nvim_lsp[server_name].setup(opts)
  end,
	["rust_analyzer"] = function ()
			require("rust-tools").setup (rt_opts)
	end,
})

