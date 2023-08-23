local key_maps = {
  {
    key = 'csd',
    func = vim.lsp.buf.hover,
    desc = 'hover'
  },
  -- {
  --   key = 'gr',
  --   func = require('navigator.reference').async_ref,
  --   desc = 'async_ref'
  -- },
  {
    key = 'csn',
    func = require('navigator.symbols').document_symbols,
    desc = 'document_symbols',
  },
  {
    key = 'cca',
    mode = 'n',
    func = require('navigator.codeAction').code_action,
    desc = 'code_action',
  },
  -- { key = '<Leader>re', func = 'rename()' },
  { key = 'ccn', func = require('navigator.rename').rename, desc = 'rename' },
  {
    key = '<Leader>ia',
    func = require('navigator.diagnostics').show_diagnostics,
    desc = 'show_diagnostics',
  },
  {
    key = '<Leader>iw',
    func = require('navigator.diagnostics').show_buf_diagnostics,
    desc = 'show_buf_diagnostics',
  },
  {
    key = '<c-l>',
    func = vim.diagnostic.goto_next,
    desc = 'next diagnostics',
  },
  {
    key = '<c-h>',
    func = vim.diagnostic.goto_prev,
    desc = 'prev diagnostics',
  },
  -- { key = '<Space>ff', func = vim.lsp.buf.format, mode = 'n', desc = 'format' },
  -- { key = '<Space>ff', func = vim.lsp.buf.range_formatting, mode = 'v', desc = 'range format' },
  -- {
  --   key = '<Space>gm',
  --   func = require('navigator.formatting').range_format,
  --   mode = 'n',
  --   desc = 'range format operator e.g gmip',
  -- },
}

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

require 'navigator'.setup({
  default_mapping = false,
  icons = {
    icons = false,
  },
  mason = true,
  keymaps = key_maps,
  lsp = {
    disable_lsp = { "tsserver", "denols", "rust_analyzer" },
    display_diagnostic_qf = false,
    diagnostic_virtual_text = false,
    cssls = {
      on_attach = function(client, bufnr)
        print("Disabling document format")
        client.resolved_capabilities.document_formatting = false
      end,
      capabilities = capabilities,
    },
    kotlin_language_server = {
      on_attach = function(client, bufnr)
        print("Disabling document format")
        client.resolved_capabilities.document_formatting = false
      end,
      capabilities = capabilities,
    },
    intelephense = {
      on_attach = function(client, bufnr)
        print("Disabling document format")
        client.resolved_capabilities.document_formatting = false
      end,
    },
    format_on_save = {
      disable = { 'css', 'php' },
    },
    disable_format_cap = { "cssls", "intelephense", "kotlin_language_server" }
  },
})

require('guihua.maps').setup({
  maps = {
    jump_to_preview = 'cj',
  }
})
