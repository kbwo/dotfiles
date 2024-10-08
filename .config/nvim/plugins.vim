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

Plug 'neoclide/coc.nvim', {'branch': 'master', 'do': 'npm ci'}

" ddu
Plug 'kbwo/ddu-source-coc'
Plug 'Shougo/ddu.vim'
Plug 'Shougo/ddu-ui-ff'
Plug 'Shougo/ddu-source-file_rec'
Plug 'Shougo/ddu-filter-matcher_substring'
Plug 'Shougo/ddu-kind-file'
Plug 'shun/ddu-source-rg'
Plug 'yuki-yano/ddu-filter-fzf'
Plug 'shun/ddu-source-buffer'
Plug 'matsui54/ddu-source-file_external'
" Plug 'uga-rosa/ddu-source-lsp'
Plug 'kamecha/ddu-source-window'

Plug 'stevearc/conform.nvim'
Plug 'mfussenegger/nvim-dap'
Plug 'jake-stewart/multicursor.nvim'

if executable("yarn")
  Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }
else
  Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
endif

call plug#end()

function! s:load_configurations(directory) abort
  for path in glob(a:directory . '/*.vim', 1, 1, 1)
    execute printf('source %s', fnameescape(path))
  endfor
  if(has('nvim'))
    for path in glob(a:directory . '/*.lua', 1, 1, 1)
      execute printf('source %s', fnameescape(path))
    endfor
  end
endfunction

call s:load_configurations('~/dotfiles/.config/nvim/plugin.d')
" call s:load_configurations('~/dotfiles/.config/nvim/lsp.d')

