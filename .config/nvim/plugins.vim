packadd vim-jetpack

call jetpack#begin(expand('~/.vim/jetpack'))
Jetpack 'tani/vim-jetpack', {'opt': 1} "bootstrap

Jetpack 'nvim-lua/plenary.nvim'
Jetpack 'nvim-lualine/lualine.nvim'
Jetpack 'tpope/vim-surround'
Jetpack 'mattn/emmet-vim'
Jetpack 'JoosepAlviste/nvim-ts-context-commentstring'
Jetpack 'numToStr/Comment.nvim'
Jetpack 'Raimondi/delimitMate'
Jetpack 'tpope/vim-dadbod'
Jetpack 'kristijanhusak/vim-dadbod-ui'
Jetpack 'glidenote/memolist.vim'
Jetpack 'tyru/eskk.vim'
Jetpack 'tyru/open-browser.vim'
Jetpack 'simeji/winresizer'
Jetpack 'windwp/nvim-ts-autotag'
Jetpack 'vim-denops/denops.vim'
Jetpack 'lambdalisue/gin.vim'
Jetpack 'machakann/vim-sandwich'
Jetpack 'kchmck/vim-coffee-script'
Jetpack 'lambdalisue/fern.vim'
Jetpack 'Bakudankun/BackAndForward.vim'
Jetpack 'nvim-lua/plenary.nvim'
" Jetpack 'zbirenbaum/copilot.lua'
" Jetpack 'CopilotC-Nvim/CopilotChat.nvim', { 'branch': 'canary' }
Jetpack 'Exafunction/codeium.vim', { 'branch': 'main' }
Jetpack 'lewis6991/gitsigns.nvim'
Jetpack 'NvChad/nvim-colorizer.lua'
Jetpack 'rebelot/kanagawa.nvim'
Jetpack 'phaazon/hop.nvim'
Jetpack 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Jetpack 'lukas-reineke/indent-blankline.nvim'
Jetpack 'andrewferrier/debugprint.nvim'
Jetpack 'sindrets/diffview.nvim'
Jetpack 'akinsho/toggleterm.nvim'
Jetpack 'jedrzejboczar/possession.nvim'
Jetpack 'chenasraf/text-transform.nvim'

" Jetpack 'neoclide/coc.nvim', {'branch': 'master', 'do': 'npm ci'}

" ddu
" Jetpack 'kbwo/ddu-source-coc'
Jetpack 'Shougo/ddu.vim'
Jetpack 'Shougo/ddu-ui-ff'
Jetpack 'Shougo/ddu-source-file_rec'
Jetpack 'Shougo/ddu-filter-matcher_substring'
Jetpack 'Shougo/ddu-kind-file'
Jetpack 'shun/ddu-source-rg'
Jetpack 'yuki-yano/ddu-filter-fzf'
Jetpack 'shun/ddu-source-buffer'
Jetpack 'matsui54/ddu-source-file_external'
Jetpack 'kbwo/ddu-source-lsp', { 'branch': 'fix/method-support' }
Jetpack 'kamecha/ddu-source-window'

Jetpack 'mfussenegger/nvim-dap'
Jetpack 'jake-stewart/multicursor.nvim'

" formatter
Jetpack 'stevearc/conform.nvim'
Jetpack 'Darazaki/indent-o-matic'

" neovim lsp
Jetpack 'neovim/nvim-lspconfig'
Jetpack 'williamboman/mason.nvim'
Jetpack 'williamboman/mason-lspconfig.nvim'
Jetpack 'WhoIsSethDaniel/mason-tool-installer.nvim'
Jetpack 'neovim/nvim-lspconfig'
Jetpack 'kyoh86/climbdir.nvim'
" language specific improvement
Jetpack 'mrcjkb/rustaceanvim'
Jetpack 'pmizio/typescript-tools.nvim'

" neovim lsp ui
" dependency
Jetpack 'MunifTanjim/nui.nvim'
" notification
Jetpack 'j-hui/fidget.nvim'
Jetpack 'rcarriga/nvim-notify'
" code action
Jetpack 'aznhe21/actions-preview.nvim'
" hover
Jetpack 'lewis6991/hover.nvim'
" diagnostics
Jetpack 'folke/trouble.nvim'
" outline
Jetpack 'stevearc/aerial.nvim'

Jetpack 'hrsh7th/nvim-cmp'
Jetpack 'hrsh7th/vim-vsnip'
Jetpack 'hrsh7th/cmp-vsnip'
Jetpack 'hrsh7th/vim-vsnip-integ'
Jetpack 'hrsh7th/cmp-nvim-lsp'
Jetpack 'hrsh7th/cmp-nvim-lsp-signature-help'
Jetpack 'hrsh7th/cmp-nvim-lsp-document-symbol'
Jetpack 'hrsh7th/cmp-emoji'
Jetpack 'hrsh7th/cmp-path'
Jetpack 'hrsh7th/cmp-buffer'
Jetpack 'hrsh7th/cmp-calc'
Jetpack 'uga-rosa/cmp-dictionary'
Jetpack 'kristijanhusak/vim-dadbod-completion'
Jetpack 'gbprod/yanky.nvim'
Jetpack 'chrisgrieser/cmp_yanky'
Jetpack 'SergioRibera/cmp-dotenv'
Jetpack 'ray-x/cmp-treesitter'
" Jetpack 'kbwo/cmp-yank'

Jetpack 'EgZvor/vim-fluffy'

Jetpack 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}

call jetpack#end()

function! LoadConfigurations(directory) abort
  for path in glob(a:directory . '/*.vim', 1, 1, 1)
    execute printf('source %s', fnameescape(path))
  endfor
  if(has('nvim'))
    for path in glob(a:directory . '/*.lua', 1, 1, 1)
      execute printf('source %s', fnameescape(path))
    endfor
  end
endfunction

call LoadConfigurations('~/dotfiles/.config/nvim/plugin.d')

