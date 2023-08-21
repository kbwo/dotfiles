-- About server: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md

-- https://github.com/j-hui/fidget.nvim/issues/129
require("fidget").setup {
  window = {
    blend = 0
  }
}

require("mason").setup()
local lspconfig = require('lspconfig')

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

local on_attach = function(client, bufnr)
      require('navigator.lspclient.mapping').setup({ client = client, bufnr = bufnr }) -- setup navigator keymaps here,
      require("navigator.dochighlight").documentHighlight(bufnr)
      require('navigator.codeAction').code_action_prompt(bufnr)
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

mason_lspconfig.setup_handlers({
  function(server_name)
    local node_root_dir = nvim_lsp.util.root_pattern('package.json')
    function HasPackageJson()
      local current_directory = vim.fn.getcwd()
      local package_json_path = current_directory .. '/package.json'
      return vim.fn.filereadable(package_json_path) == 1
    end

    local is_node_repo = node_root_dir(vim.api.nvim_buf_get_name(0)) ~= nil or HasPackageJson()

    local opts = {}

    opts.capabilities = update_capabilities(vim.lsp.protocol.make_client_capabilities())
    -- vim.api.nvim_echo({{'server_name'}, {server_name, 'warningmsg'}}, true, {})

    if server_name == 'vtsls' or server_name == 'tsserver' or server_name == "eslint" then
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
    end

    opts.on_attach = on_attach

    nvim_lsp[server_name].setup(opts)
  end,
  ["rust_analyzer"] = function()
    require("rust-tools").setup(rt_opts)
  end,
})

lspconfig.coffeesense.setup({
  on_attach = on_attach,
  capabilities = update_capabilities(vim.lsp.protocol.make_client_capabilities()),
})
