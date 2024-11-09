" plugin
call plug#begin(expand('~/.vim/plugged'))
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-lualine/lualine.nvim'
Plug 'tpope/vim-surround'
Plug 'mattn/emmet-vim'
Plug 'JoosepAlviste/nvim-ts-context-commentstring'
Plug 'numToStr/Comment.nvim'
Plug 'Raimondi/delimitMate'
Plug 'tpope/vim-dadbod'
Plug 'kristijanhusak/vim-dadbod-ui'
Plug 'glidenote/memolist.vim'
Plug 'tyru/eskk.vim'
Plug 'tyru/open-browser.vim'
Plug 'simeji/winresizer'
Plug 'windwp/nvim-ts-autotag'
Plug 'vim-denops/denops.vim'
Plug 'lambdalisue/gin.vim'
Plug 'machakann/vim-sandwich'
Plug 'kchmck/vim-coffee-script'
Plug 'lambdalisue/fern.vim'
Plug 'Bakudankun/BackAndForward.vim'
Plug 'nvim-lua/plenary.nvim'
" Plug 'zbirenbaum/copilot.lua'
" Plug 'CopilotC-Nvim/CopilotChat.nvim', { 'branch': 'canary' }
Plug 'Exafunction/codeium.vim', { 'branch': 'main' }
Plug 'mhinz/vim-signify'
Plug 'NvChad/nvim-colorizer.lua'
Plug 'rebelot/kanagawa.nvim'
Plug 'phaazon/hop.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'andrewferrier/debugprint.nvim'
Plug 'sindrets/diffview.nvim'
Plug 'akinsho/toggleterm.nvim'
Plug 'jedrzejboczar/possession.nvim'
Plug 'chenasraf/text-transform.nvim'

" Plug 'neoclide/coc.nvim', {'branch': 'master', 'do': 'npm ci'}

" ddu
" Plug 'kbwo/ddu-source-coc'
Plug 'Shougo/ddu.vim'
Plug 'Shougo/ddu-ui-ff'
Plug 'Shougo/ddu-source-file_rec'
Plug 'Shougo/ddu-filter-matcher_substring'
Plug 'Shougo/ddu-kind-file'
Plug 'shun/ddu-source-rg'
Plug 'yuki-yano/ddu-filter-fzf'
Plug 'shun/ddu-source-buffer'
Plug 'matsui54/ddu-source-file_external'
Plug 'uga-rosa/ddu-source-lsp'
Plug 'kamecha/ddu-source-window'

Plug 'mfussenegger/nvim-dap'
Plug 'jake-stewart/multicursor.nvim'

" formatter
Plug 'stevearc/conform.nvim'

" neovim lsp
Plug 'neovim/nvim-lspconfig'
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'WhoIsSethDaniel/mason-tool-installer.nvim'
Plug 'neovim/nvim-lspconfig'
" Plug 'simrat39/rust-tools.nvim'
Plug 'j-hui/fidget.nvim', { 'tag': 'legacy' }

Plug 'MunifTanjim/nui.nvim'
" code action
Plug 'aznhe21/actions-preview.nvim'
" hover
Plug 'lewis6991/hover.nvim'
" diagnostics
Plug 'folke/trouble.nvim'

Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-nvim-lsp-signature-help'
Plug 'hrsh7th/cmp-nvim-lsp-document-symbol'
Plug 'hrsh7th/cmp-emoji'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-calc'
Plug 'uga-rosa/cmp-dictionary'
Plug 'kristijanhusak/vim-dadbod-completion'
Plug 'gbprod/yanky.nvim'
Plug 'chrisgrieser/cmp_yanky'
" Plug 'kbwo/cmp-yank'

Plug 'stevearc/aerial.nvim'

" language specific improvement
Plug 'mrcjkb/rustaceanvim'
Plug 'pmizio/typescript-tools.nvim'

Plug 'EgZvor/vim-fluffy'

if executable("yarn")
  Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }
else
  Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
endif

call plug#end()

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

