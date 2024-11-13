local config = {
  -- base
  { "nvim-lua/plenary.nvim", lazy = true },
  { "vim-denops/denops.vim" },

  -- syntax highlight
  { "kchmck/vim-coffee-script" },

  -- UI
  { "nvim-lualine/lualine.nvim" },
  { "rebelot/kanagawa.nvim" },
  { "lukas-reineke/indent-blankline.nvim" },
  { "NvChad/nvim-colorizer.lua" },
  { "j-hui/fidget.nvim", tag = "legacy" },
  { "simeji/winresizer" },
  { "tpope/vim-dadbod" },
  { "kristijanhusak/vim-dadbod-ui" },
  { "kristijanhusak/vim-dadbod-completion" },

  -- Editor Utility
  { "tpope/vim-surround" },
  { "mattn/emmet-vim" },
  { "Raimondi/delimitMate" },
  { "windwp/nvim-ts-autotag" },
  { "machakann/vim-sandwich" },
  { "numToStr/Comment.nvim" },
  { "JoosepAlviste/nvim-ts-context-commentstring" },

  -- Git
  { "lewis6991/gitsigns.nvim" },
  { "lambdalisue/gin.vim" },
  { "sindrets/diffview.nvim" },

  -- Navigation
  { "phaazon/hop.nvim" },
  { "Bakudankun/BackAndForward.vim" },

  -- LSP関連
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim" },
  { "WhoIsSethDaniel/mason-tool-installer.nvim" },
  { "mrcjkb/rustaceanvim" },
  { "pmizio/typescript-tools.nvim" },

  -- LSP UI
  { "MunifTanjim/nui.nvim" },
  { "aznhe21/actions-preview.nvim" },
  { "lewis6991/hover.nvim" },
  { "folke/trouble.nvim" },
  { "stevearc/aerial.nvim" },

  -- Completion
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-nvim-lsp-signature-help" },
  { "hrsh7th/cmp-nvim-lsp-document-symbol" },
  { "hrsh7th/cmp-emoji" },
  { "hrsh7th/cmp-path" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-calc" },
  { "uga-rosa/cmp-dictionary" },
  { "SergioRibera/cmp-dotenv" },
  { "ray-x/cmp-treesitter" },

  -- その他のツール
  { "Exafunction/codeium.vim", branch = "main" },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  { "andrewferrier/debugprint.nvim" },
  { "akinsho/toggleterm.nvim" },
  { "jedrzejboczar/possession.nvim" },
  { "chenasraf/text-transform.nvim" },
  { "mfussenegger/nvim-dap" },
  { "jake-stewart/multicursor.nvim" },
  { "stevearc/conform.nvim" },
  { "gbprod/yanky.nvim" },
  { "lambdalisue/fern.vim" },
  { "tyru/eskk.vim" },
  { "tyru/open-browser.vim" },
  { "glidenote/memolist.vim" },
  { "EgZvor/vim-fluffy" },

  -- ddu
  { "Shougo/ddu.vim" },
  { "Shougo/ddu-ui-ff" },
  { "Shougo/ddu-source-file_rec" },
  { "Shougo/ddu-filter-matcher_substring" },
  { "Shougo/ddu-kind-file" },
  { "shun/ddu-source-rg" },
  { "yuki-yano/ddu-filter-fzf" },
  { "shun/ddu-source-buffer" },
  { "matsui54/ddu-source-file_external" },
  { "uga-rosa/ddu-source-lsp" },
  { "kamecha/ddu-source-window" },

  -- Markdown Preview
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && yarn install",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = { "markdown" },
  },
}

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- プラグインの設定を読み込む
require("lazy").setup(config)
