local nvim_lsp = require('lspconfig')
require'lspconfig'.vimls.setup{}
require'lspconfig'.pyright.setup{}
nvim_lsp.flow.setup {
  on_attach = on_attach
}
nvim_lsp.tsserver.setup {
  on_attach = on_attach,
  filetypes = { "typescript", "typescriptreact", "typescript.tsx" }
}

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, { virtual_text = false }
)
