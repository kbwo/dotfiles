-- https://github.com/nvim-treesitter/nvim-treesitter
require 'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  ensure_installed = {
    "http",
    "markdown",
    "markdown_inline",
    "rust",
    "json",
    "diff"
  },
  indent = {
    enable = false
  }
}
require('ts_context_commentstring').setup {
  enable = true,
  enable_autocmd = false,
}
