local lspconfig = require('lspconfig')
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

local function eslint_config_exists()
  local eslintrc = vim.fn.glob(".eslintrc*", 0, 1)

  if not vim.tbl_isempty(eslintrc) then
    return true
  end

  if vim.fn.filereadable("package.json") then
    if vim.fn.json_decode(vim.fn.readfile("package.json"))["eslintConfig"] then
      return true
    end
  end

  return false
end

 
lspconfig.tsserver.setup {
  on_attach = function(client)
    if client.config.flags then
      client.config.flags.allow_incremental_sync = true
    end
    client.resolved_capabilities.document_formatting = false
    set_lsp_config(client)
  end
}
 
lspconfig.efm.setup {
  on_attach = function(client)
    client.resolved_capabilities.document_formatting = true
    client.resolved_capabilities.goto_definition = false
    set_lsp_config(client)
  end,
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
