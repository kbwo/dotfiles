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
    elseif server_name == 'yamlls' then
      opts.settings = {
        yaml = {
          schemas = {
            ["https://raw.githubusercontent.com/instrumenta/kubernetes-json-schema/master/v1.18.0-standalone-strict/all.json"] = "/*.k8s.yaml",
          }
        }
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

-- alternatively you can override the default configs
require("flutter-tools").setup({
  ui = {
    -- the border type to use for all floating windows, the same options/formats
    -- used for ":h nvim_open_win" e.g. "single" | "shadow" | {<table-of-eight-chars>}
    border = "rounded",
    -- This determines whether notifications are show with `vim.notify` or with the plugin's custom UI
    -- please note that this option is eventually going to be deprecated and users will need to
    -- depend on plugins like `nvim-notify` instead.
    notification_style = 'native' -- | 'plugin'
  },
  decorations = {
    statusline = {
      -- set to true to be able use the 'flutter_tools_decorations.app_version' in your statusline
      -- this will show the current version of the flutter app from the pubspec.yaml file
      app_version = false,
      -- set to true to be able use the 'flutter_tools_decorations.device' in your statusline
      -- this will show the currently running device if an application was started with a specific
      -- device
      device = false,
      -- set to true to be able use the 'flutter_tools_decorations.project_config' in your statusline
      -- this will show the currently selected project configuration
      project_config = false,
    }
  },
  -- debugger = { -- integrate with nvim dap + install dart code debugger
  --   enabled = false,
  --   run_via_dap = false, -- use dap instead of a plenary job to run flutter apps
  --   -- if empty dap will not stop on any exceptions, otherwise it will stop on those specified
  --   -- see |:help dap.set_exception_breakpoints()| for more info
  --   exception_breakpoints = {},
  --   register_configurations = function(paths)
  --     require("dap").configurations.dart = {
  --       -- <put here config that you would find in .vscode/launch.json>
  --     }
  --   end,
  -- },
  -- flutter_path = "<full/path/if/needed>",     -- <-- this takes priority over the lookup
  -- flutter_lookup_cmd = nil,                   -- example "dirname $(which flutter)" or "asdf where flutter"
  root_patterns = { ".git", "pubspec.yaml" }, -- patterns to find the root of your flutter project
  fvm = false,                                -- takes priority over path, uses <workspace>/.fvm/flutter_sdk if enabled
  widget_guides = {
    enabled = false,
  },
  closing_tags = {
    highlight = "ErrorMsg", -- highlight for the closing tag
    prefix = ">",           -- character to use for close tag e.g. > Widget
    enabled = true          -- set to false to disable
  },
  dev_log = {
    enabled = true,
    notify_errors = false, -- if there is an error whilst running then notify the user
    open_cmd = "tabedit",  -- command to use to open the log buffer
  },
  dev_tools = {
    autostart = false,         -- autostart devtools server if not detected
    auto_open_browser = false, -- Automatically opens devtools in the browser
  },
  outline = {
    open_cmd = "30vnew", -- command to use to open the outline buffer
    auto_open = false    -- if true this will open the outline automatically when it is first populated
  },
  lsp = {
    color = { -- show the derived colours for dart variables
      enabled = false, -- whether or not to highlight color variables at all, only supported on flutter >= 2.10
      background = false, -- highlight the background
      background_color = nil, -- required, when background is transparent (i.e. background_color = { r = 19, g = 17, b = 24},)
      foreground = false, -- highlight the foreground
      virtual_text = true, -- show the highlight using virtual text
      virtual_text_str = "■", -- the virtual text character to highlight
    },
    on_attach = on_attach,
    capabilities = update_capabilities(vim.lsp.protocol.make_client_capabilities()), -- e.g. lsp_status capabilities
    -- see the link below for details on each option:
    -- https://github.com/dart-lang/sdk/blob/master/pkg/analysis_server/tool/lsp_spec/README.md#client-workspace-configuration
    settings = {
      showTodos = true,
      completeFunctionCalls = true,
      analysisExcludedFolders = { "<path-to-flutter-sdk-packages>" },
      renameFilesWithClasses = "prompt", -- "always"
      enableSnippets = true,
      updateImportsOnRename = true,      -- Whether to update imports and other directives when files are renamed. Required for `FlutterRename` command.
    }
  }
})
