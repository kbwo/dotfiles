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
" Jetpack 'tyru/eskk.vim'
Jetpack 'sontungexpt/url-open'
Jetpack 'simeji/winresizer'
Jetpack 'windwp/nvim-ts-autotag'
Jetpack 'vim-denops/denops.vim'
Jetpack 'kbwo/vim-gin', { 'branch': 'fix/wworktree'}
" Jetpack 'lambdalisue/gin.vim'
Jetpack 'machakann/vim-sandwich'
Jetpack 'lambdalisue/fern.vim'
Jetpack 'lambdalisue/vim-fern-hijack'
Jetpack 'Bakudankun/BackAndForward.vim'
Jetpack 'nvim-lua/plenary.nvim'
Jetpack 'Exafunction/codeium.vim', { 'branch': 'main' }
Jetpack 'echasnovski/mini.diff'
Jetpack 'NvChad/nvim-colorizer.lua'
Jetpack 'rebelot/kanagawa.nvim'
Jetpack 'smoka7/hop.nvim'
Jetpack 'yorickpeterse/nvim-window'
Jetpack 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Jetpack 'shellRaining/hlchunk.nvim'
Jetpack 'andrewferrier/debugprint.nvim'
Jetpack 'akinsho/toggleterm.nvim'
Jetpack 'jedrzejboczar/possession.nvim'
Jetpack 'chenasraf/text-transform.nvim'

" Jetpack 'neoclide/coc.nvim', {'branch': 'master', 'do': 'npm ci'}
"
Jetpack 'kbwo/vim-shareedit'

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
Jetpack 'nekowasabi/ddu-source-git-worktree'

Jetpack 'jake-stewart/multicursor.nvim'

" formatter
Jetpack 'stevearc/conform.nvim'
Jetpack 'kbwo/indent-o-matic'

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
Jetpack 'kbwo/testing-ls.nvim'
Jetpack 'copilotlsp-nvim/copilot-lsp'

" neovim lsp ui
" dependency
Jetpack 'MunifTanjim/nui.nvim'
" notification
Jetpack 'j-hui/fidget.nvim'
" Jetpack 'rcarriga/nvim-notify'
" code action
Jetpack 'aznhe21/actions-preview.nvim'
Jetpack 'Sebastian-Nielsen/better-type-hover'
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
Jetpack 'f3fora/cmp-spell'
" dictionary 使っている状態でバッファが増えると何故かterminalがめちゃくちゃ重くなる
" Jetpack 'uga-rosa/cmp-dictionary'
Jetpack 'kristijanhusak/vim-dadbod-completion'
Jetpack 'ray-x/cmp-treesitter'

" Jetpack 'copilotlsp-nvim/copilot-lsp'

" Jetpack 'Shougo/ddc.vim'
" Jetpack 'Shougo/ddc-ui-native'
" Jetpack 'Shougo/ddc-source-around'
" Jetpack 'Shougo/ddc-filter-matcher_head'
" Jetpack 'Shougo/ddc-filter-sorter_rank'
" Jetpack 'Shougo/ddc-source-lsp'
" Jetpack 'LumaKernel/ddc-source-file'
" Jetpack 'tani/ddc-fuzzy'
" Jetpack 'matsui54/denops-popup-preview.vim'
" Jetpack 'matsui54/ddc-source-buffer'
" Jetpack 'gamoutatsumi/ddc-emoji'
" Jetpack 'Shougo/ddc-source-input'
" Jetpack 'matsui54/ddc-source-dictionary'
" Jetpack 'kristijanhusak/vim-dadbod-completion'

Jetpack 'EgZvor/vim-fluffy'

Jetpack 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}

Jetpack 'monaqa/dial.nvim'
Jetpack 'petertriho/nvim-scrollbar'
Jetpack 'gaoDean/autolist.nvim'
Jetpack 'kbwo/org-list.nvim'

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


autocmd BufEnter term:// startinsert
