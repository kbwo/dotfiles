local lspconfig = require('lspconfig')
local on_attach = require('plugins.config.lspconfig').on_attach
local capabilities = require('plugins.config.lspconfig').capabilities
local util = require "lspconfig"
require'lspconfig'.vimls.setup{}
require'lspconfig'.pyright.setup{}

-- local on_attach = function(client, bufnr)
--   local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
--   local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end
--   --Enable completion triggered by <c-x><c-o>
--   buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')
--   -- Mappings.
--   local opts = { noremap=true, silent=true }
--   -- See `:help vim.lsp.*` for documentation on any of the below functions
--   -- buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
--   -- buf_set_keymap('n', '<C-d>', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
--   -- buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
--   -- buf_set_keymap('n', 'ccn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
--   -- buf_set_keymap('n', 'cca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
--   -- buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
--   -- buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
--   -- buf_set_keymap('n', '<c-l>', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
--   -- buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
-- end

local eslint = {
  lintCommand = "eslint_d -f unix --stdin --stdin-filename ${INPUT}",
  lintStdin = true,
  lintFormats = {"%f:%l:%c: %m"},
  lintIgnoreExitCode = true,
  formatCommand = "eslint_d --fix-to-stdout --stdin --stdin-filename=${INPUT}",
  formatStdin = true
}

local function exists_package_json_field(field)
    if vim.fn.filereadable("package.json") ~= 0 then
        local package_json = vim.fn.json_decode(vim.fn.readfile("package.json"))
        return package_json[field] ~= nil
    end
end

local function exists_glob(glob)
    return vim.fn.glob(glob) ~= ""
end

local function eslint_config_exists()
  return exists_glob(".eslintrc*") or exists_package_json_field("eslintConfig")
end
lspconfig.go.setup {
  on_attach = on_attach
}
lspconfig.angular.setup {
  on_attach = on_attach
}
lspconfig.bash.setup {
  on_attach = on_attach
}
lspconfig.cpp.setup {
  on_attach = on_attach
}
lspconfig.css.setup {
  on_attach = on_attach
}
lspconfig.dockerfile.setup {
  on_attach = on_attach
}

lspconfig.graphql.setup {
  on_attach = on_attach
}

lspconfig.html.setup {
  on_attach = on_attach
}

lspconfig.json.setup {
  on_attach = on_attach
}

lspconfig.kotlin.setup {
  on_attach = on_attach
}

lspconfig.lua.setup {
  on_attach = on_attach
}

lspconfig.php.setup {
  on_attach = on_attach
}

lspconfig.python.setup {
  on_attach = on_attach
}

lspconfig.rust.setup {
  on_attach = on_attach
}

lspconfig.vim.setup {
  on_attach = on_attach
}

lspconfig.vue.setup {
  on_attach = on_attach
}

lspconfig.yaml.setup {
  on_attach = on_attach
}

lspconfig.deno.setup {
  on_attach = on_attach
}

lspconfig.tsserver.setup {
  on_attach = on_attach,
  filetypes = { "typescript", "typescriptreact", "typescript.tsx" }
}

lspconfig.rust_analyzer.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "rust" },
  root_dir = util.root_pattern("Cargo.toml"),
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        allFeatures = true
      }
    }
  }
})

lspconfig.efm.setup {
  on_attach = on_attach,
  root_dir = function()
    if not eslint_config_exists() then
      return nil
    end
    return vim.fn.getcwd()
  end,
  settings = {
    languages = {
      javascript = {eslint},
      javascriptreact = {eslint},
      ["javascript.jsx"] = {eslint},
      typescript = {eslint},
      ["typescript.tsx"] = {eslint},
      typescriptreact = {eslint}
    }
  },
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescript.tsx",
    "typescriptreact"
  },
}

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, { virtual_text = false }
  )
