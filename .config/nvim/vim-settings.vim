filetype plugin indent on

inoremap <c-u> <Nop>
nmap <Leader>l :lcd %:h<CR>
let mapleader="\<Space>"

map K gt
map J gT

nnoremap <Leader>j <c-d>
nnoremap <Leader>k <c-u>

nnoremap R :join<CR>
nnoremap <Leader>t :tabnew<CR>

nnoremap j gj
nnoremap k gk
nnoremap <Down> gj
nnoremap <Up> gk

nnoremap + <C-a>
nnoremap - <C-x>

nnoremap <c-t> <c-o>

" base
set shell=/bin/zsh
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8
set ambiwidth=single
set bomb
set binary
set ttyfast
set backspace=indent,eol,start
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set autoindent
set splitright
set splitbelow
set hidden
set hlsearch
set incsearch
set ignorecase
set smartcase
set nobackup
set noswapfile
set fileformats=unix,dos,mac
set foldlevel=99
set cursorline
syntax on


let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
set ruler
set number
set scrolloff=3
set laststatus=2
set modeline
set modelines=10
set title
set titleold="Terminal"
set titlestring=%F
set statusline=%F%m%r%h%w%=(%{&ff}/%Y)\ (line\ %l\/%L,\ col\ %c)\
set autoread
set noerrorbells visualbell t_vb=
set mouse=a
set whichwrap=b,s,h,l,<,>,[,]
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.pyc,*.db,*.sqlite
if has('nvim')
  set clipboard+=unnamedplus
  set guicursor=a:blinkon0
else
  set guicursor=i:blinkwait700-blinkon400-blinkoff250
  set clipboard+=unnamed,autoselect
endif

" auto opening quickfix window using vim grep
autocmd QuickFixCmdPost *grep* cwindow

" don't comment out when go to next line
autocmd FileType * setlocal formatoptions-=ro

set completeopt=menuone,noinsert,noselect,preview
set shortmess+=c
