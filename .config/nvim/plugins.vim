" plugin
call plug#begin(expand('~/.vim/plugged'))
" for debug
Plug 'thinca/vim-quickrun', {'on' : 'QuickRun'}
" Plug 'joonty/vdebug'
Plug 'Shougo/vimproc.vim', {'do' : 'make'}
" Plug 'vim-airline/vim-airline'
" Plug 'vim-airline/vim-airline-themes'
Plug 'itchyny/lightline.vim'

Plug 'tpope/vim-surround'
Plug 'ervandew/supertab'
Plug 'mattn/emmet-vim'
Plug 'raimon49/requirements.txt.vim', {'for': 'requirements'}
Plug 'SirVer/ultisnips'
Plug 'tomtom/tcomment_vim'
Plug 'maxmellon/vim-jsx-pretty'
Plug 'Shougo/vimproc.vim', {'do' : 'make'}
Plug 'editorconfig/editorconfig-vim'
Plug 'mg979/vim-visual-multi', {'branch': 'master'}

Plug 'ghifarit53/tokyonight-vim'
Plug 'thosakwe/vim-flutter'
Plug 'godlygeek/tabular'
Plug 'previm/previm'
Plug  'Raimondi/delimitMate'
Plug 'jparise/vim-graphql'
Plug 'tpope/vim-dadbod'
Plug 'kristijanhusak/vim-dadbod-ui'
Plug 'junegunn/gv.vim'
Plug 'glidenote/memolist.vim'
Plug 'tyru/eskk.vim'
Plug 'Yggdroot/indentLine'
Plug 'tyru/open-browser.vim'
Plug 'ivanov/vim-ipython'
Plug 'Shougo/denite.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'hrsh7th/vim-gitto'
Plug 'hrsh7th/vim-denite-gitto'
Plug 'liuchengxu/vim-clap', { 'do': ':Clap install-binary'}
Plug 'posva/vim-vue'
Plug 'leafOfTree/vim-vue-plugin'
Plug 'simeji/winresizer'
Plug 'dart-lang/dart-vim-plugin'
Plug 'junegunn/vader.vim'
Plug 'AndrewRadev/tagalong.vim'
Plug 'vim-denops/denops.vim'
Plug 'elzr/vim-json'
Plug 'sheerun/vim-polyglot'
Plug 'lambdalisue/gina.vim'
Plug 'pantharshit00/vim-prisma'
Plug 'lambdalisue/edita.vim'
Plug 'puremourning/vimspector'
Plug 'neoclide/coc.nvim', {'branch': 'release', 'do': { -> coc#util#install()}}
Plug 'neoclide/coc-denite'
Plug 'turbio/bracey.vim'
Plug 'Shougo/defx.nvim', { 'do': ':UpdateRemotePlugins' }
if has('nvim')
  Plug 'phaazon/hop.nvim'
  " ===== nvim-lsp ==========
  " Plug 'neovim/nvim-lspconfig'
  " Plug 'kabouzeid/nvim-lspinstall'
  " Plug 'hrsh7th/nvim-compe'
  " Plug 'glepnir/lspsaga.nvim'
  " Plug 'mhartington/formatter.nvim'
  " Plug 'dense-analysis/ale'
  " Plug 'nathunsmitty/nvim-ale-diagnostic'
  " ===== nvim-lsp ==========
else
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif

call plug#end()
