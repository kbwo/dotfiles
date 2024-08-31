set rtp +=~/.vim

if has('vim_starting')
  set nocompatible
endif

filetype plugin indent on

inoremap <c-u> <Nop>
let mapleader="\<Space>"

map K gt
map J gT
nmap j gj
nmap k gk
nmap Q :confirm qa<CR>
nmap <Leader>j <c-d>
nmap <Leader>k <c-u>
nmap R :join<CR>
nmap <Down> gj
nmap <Up> gk
nmap + <C-a>
nmap - <C-x>
nmap <c-t> :tabnew<CR>
nmap <Leader>l :lcd %:h<CR>
nmap <Leader>h :noh<CR>
tnoremap <C-\> <C-\><C-n>
command Sov so ~/.config/nvim/init.vim
command Cdv vsp ~/dotfiles/.config/nvim/init.vim

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
autocmd FileType php setlocal tabstop=4 softtabstop=4 shiftwidth=4
autocmd FileType markdown setlocal expandtab
autocmd FileType markdown setlocal tabstop=2
autocmd FileType markdown setlocal shiftwidth=2
autocmd FileType markdown setlocal softtabstop=2
augroup TrimCmd
  autocmd!
  " Exclude .vim files from the autocmd
  autocmd BufWritePre * if &filetype != 'vim' | :%s/\s\+$//e | endif
augroup END

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
set nonumber
set scrolloff=3
set laststatus=2
set modeline
set modelines=10
set title
set titleold="Terminal"
set titlestring=%F
set autoread
set noerrorbells visualbell t_vb=
set mouse=a
set whichwrap=b,s,h,l,<,>,[,]
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.pyc,*.db,*.sqlite
set clipboard+=unnamedplus
nnoremap gno o<Esc>
nnoremap gnO O<Esc>
if has('nvim')
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

augroup highlight_yank
    autocmd!
    au TextYankPost * silent! lua vim.highlight.on_yank({higroup="IncSearch", timeout=700})
augroup END

" avoid error by navigator.lua (error log is same as https://github.com/ray-x/navigator.lua/issues/170)
" vim.api.nvim_buf_set_option(bufnr, 'filetype', lang)
" In navigator.lua,
" ```
"     api.nvim_create_autocmd({ 'FileType', 'BufEnter' }, {
"       group = cmd_group,
"       pattern = '*',
"       callback = function()
"         require('navigator.lspclient.clients').on_filetype()
"       end,
"     })
" ```
autocmd FileType diff call nvim_buf_set_option(bufnr('%'), 'filetype', 'diff')
autocmd BufEnter *:$ call nvim_buf_set_option(bufnr('%'), 'filetype', 'diff')

function! s:GotoFirstFloat() abort
  for w in range(1, winnr('$'))
    let c = nvim_win_get_config(win_getid(w))
    if c.focusable && !empty(c.relative)
      execute w . 'wincmd w'
    endif
  endfor
endfunction
noremap <silent><c-w>w :<c-u>call <sid>GotoFirstFloat()<CR>

" https://www.rasukarusan.com/entry/2021/09/19/125635
function! s:show_ex_result(cmd)
  redir => message
  silent execute a:cmd
  redir END
  if empty(message)
    echoerr "no output"
  else
    tabnew
    setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted nomodified
    silent put=message
    normal gg
  endif
endfunction
command! -nargs=+ -complete=command ShowExResult call s:show_ex_result(<q-args>)
