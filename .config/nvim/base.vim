set rtp +=~/.vim
set rtp+=~/go/projects/github.com/kbwo/ddu-source-ainavi

if has('vim_starting')
  set nocompatible
endif

filetype plugin indent on

let mapleader="\<Space>"

function! CloseAllTermBuffers()
    for bufnr in range(1, bufnr('$'))
        if (bufexists(bufnr) && (bufname(bufnr) =~ '^term://'))
            let wins = win_findbuf(bufnr)
            silent! execute 'bdelete!' bufnr
            if !empty(wins)
                let close_wins = wins[:]
                for winid in close_wins
                    call win_gotoid(winid)
                    execute 'quit!'
                endfor
            endif
        endif
    endfor
endfunction

inoremap <c-u> <Nop>
map K gt
map J gT
nmap j gj
nmap k gk
nmap <Leader>j :-tabmove<CR>
nmap <Leader>k :+tabmove<CR>
nmap Q :call CloseAllTermBuffers()<CR>:confirm qa<CR>
nmap R :join<CR>
nmap <Down> gj
nmap <Up> gk
nmap + <C-a>
nmap - <C-x>
imap <S-Tab> <C-o><<
nmap <Leader>x :q<CR>
nmap <Leader>zx :tabc<CR>
nnoremap <silent><c-w>t :let b = bufnr('%')<CR>:close<CR>:tabnew<CR>:execute 'buffer' b<CR>

" tabnew and preserve cursor position
nmap <Leader>t<Space> :tab split<CR>
nmap <Leader>tn :NoFile<CR>
nmap <Leader>l :lcd %:h<CR>
nmap <Leader>h :noh<CR>
nmap <Leader>e<Space> :e!<CR>
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
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
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
set number
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
set diffopt=iwhiteall
set showtabline=2
set previewheight=25
set pumheight=30
set matchpairs+=<:>
set matchpairs+=（:）
set matchpairs+=「:」
set matchpairs+=【:】

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

function s:open_nofile()
    tabnew
    setlocal buftype=nofile bufhidden=wipe noswapfile
endfunction

command! NoFile call s:open_nofile()

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

function! GetTabLabel(tabnr)
  " Get the last accessed window number in the specified tab
  let winnr = tabpagewinnr(a:tabnr)
  " Get buffer number of that window
  let buflist = tabpagebuflist(a:tabnr)
  let bufnr = buflist[winnr - 1]  " winnrは1-basedなので-1する
  let bufname = bufname(bufnr)
  
  let filetype = getbufvar(bufnr, '&filetype', '')
  if filetype =~# '^gin'
    return filetype
  endif

  " Default label if buffer doesn't exist
  if bufname ==# '' || buflisted(bufnr) == 0
    return filetype !=# '' ? filetype : 'No Name'
  endif
  
  " Get parent directory name and file name from full path
  let parent_dir = fnamemodify(bufname, ':p:h:t') " Parent directory name
  let file_name = fnamemodify(bufname, ':t')      " File name
  return parent_dir . '/' . file_name
endfunction

" Function to build custom tabline
function! FileWithParent()
  let s = ''

  " Loop through all tabs
  for tabnr in range(1, tabpagenr('$'))
    " Change highlight based on whether it's the active tab
    if tabnr == tabpagenr()
      let s .= '%#TabLineSel#'        " Highlight for active tab
    else
      let s .= '%#TabLine#'           " Highlight for inactive tab
    endif

    " Make tab clickable
    let s .= '%' . tabnr . 'T'

    " Add tab label
    let s .= ' ' . GetTabLabel(tabnr) . ' '

    " Separator between tabs
    let s .= '%#TabLine# | '

  endfor

  " Remove the last separator
  let s = substitute(s, ' | $', '', '')

  " Fill remaining space with TabLineFill
  let s .= '%#TabLineFill#'

  return s
endfunction

" Set custom tabline
set tabline=%!FileWithParent()

autocmd BufRead,BufNewFile *.mdx set filetype=markdown

function! YankRelativePath()
  let l:relpath = fnamemodify(expand('%'), ':.')
  if empty(l:relpath)
    echo 'No file to yank'
  else
    let @+ = l:relpath
    echo 'Copied relative path'
  endif
endfunction

function! YankGitHubURL(target_branch)
  let l:git_root = system('git rev-parse --show-toplevel')
  let l:git_root = substitute(l:git_root, '\n$', '', '')
  let l:absolute_path = expand('%:p')
  let l:relpath = substitute(l:absolute_path, l:git_root . '/', '', '')
  if empty(l:relpath)
    echo 'No file to yank'
    return
  endif
  let l:git_origin = system('git config --get remote.origin.url')
  if empty(l:git_origin)
    echo 'Not in a git repository'
    return
  endif

  let l:branch = ''
  if a:target_branch == 'current'
    let l:current_branch = system('git rev-parse --abbrev-ref HEAD')
    let l:current_branch = substitute(l:current_branch, '\n', '', '')
    let l:branch = l:current_branch
  elseif a:target_branch == 'current_commit'
    let l:current_branch_commit = system('git rev-parse HEAD')
    let l:current_branch_commit = matchstr(l:current_branch_commit, '^\x\{40\}')
    let l:branch = l:current_branch_commit
  elseif a:target_branch == 'default_commit'
    let l:default_branch = system('git symbolic-ref refs/remotes/origin/HEAD | sed "s@^refs/remotes/origin/@@g"')
    let l:default_branch_commit = system('git rev-parse ' . l:default_branch)
    let l:default_branch_commit = substitute(l:default_branch_commit, '\n', '', '')
    let l:branch = l:default_branch_commit
  else
    let l:default_branch = system('git symbolic-ref refs/remotes/origin/HEAD | sed "s@^refs/remotes/origin/@@g"')
    let l:default_branch = substitute(l:default_branch, '\n', '', '')
    let l:branch = l:default_branch
  endif
  let l:http_url = l:git_origin
  " if http url does not contain https
  if l:http_url !~ 'https'
    let l:http_url = substitute(l:http_url, 'git@', 'https://', '')
    let l:http_url = substitute(l:http_url, '\.git', '', '')
    let l:http_url = substitute(l:http_url, 'github.com:', 'github.com/', '')
  endif
  let l:http_url = substitute(l:http_url, '\n', '', '')
  let l:relpath = substitute(l:relpath, '^./', '', '')
  let l:line = line('.')
  let l:github_url = l:http_url . '/blob/' . l:branch . '/' . l:relpath
  let l:github_url = l:github_url . '#L' . l:line
  let @+ = l:github_url
  echo 'Copied GitHub URL'
endfunction

function! TargetBranchCompletion(A, L, P)
  let l:candidates = ['default_commit', 'current_commit', 'default', 'current']
  return filter(l:candidates, 'v:val =~ "^" . a:A')
endfunction

command! YankRelativePath call YankRelativePath()
command! -nargs=1 -complete=customlist,TargetBranchCompletion YankGitHubURL call YankGitHubURL(<f-args>)

nmap <Leader>w :noa w<CR>


function! s:OpenByCursor()
  let l:path = expand('%:p')
  let l:line = line('.')
  silent! exe '!cursor --g '.l:path.':'.l:line
endfunction
command! -range OpenByCursor call s:OpenByCursor()

autocmd CursorMoved, CursorHold * checktime

autocmd BufNewFile,BufRead *.mdc set filetype=markdown

" 自動コミット・プッシュを行うディレクトリのリスト
let g:auto_git_dirs = ['~/obs-kbwo']

" 自動コミット・プッシュの間隔（ミリ秒）
let g:auto_git_interval = 300000  " 5分

" タイマーIDを保持するグローバル変数
let g:auto_git_timer_id = -1

function! s:AutoGitCommitPush()
    " 設定されたディレクトリのいずれかにマッチするか確認
    for dir in g:auto_git_dirs
        let l:expanded_dir = expand(dir)
        " ディレクトリが存在するか確認
        if isdirectory(l:expanded_dir)
            " 最初にpullを実行
            call system('git -C ' . l:expanded_dir . ' pull')
            
            " ファイルが変更されているか確認
            let l:git_status = system('git -C ' . l:expanded_dir . ' status --porcelain')
            if !empty(l:git_status)
                " 変更があれば、コミットとプッシュを実行
                let l:timestamp = strftime('%Y-%m-%d %H:%M:%S')
                call system('git -C ' . l:expanded_dir . ' add .')
                call system('git -C ' . l:expanded_dir . ' commit -m "Auto commit: ' . l:timestamp . '"')
                call system('git -C ' . l:expanded_dir . ' push')
                echo "Auto pulled, committed and pushed changes in " . l:expanded_dir
            else
                echo "Pulled from " . l:expanded_dir . " (no local changes)"
            endif
        endif
    endfor
endfunction

" タイマーの設定
function! s:StartAutoGitTimer()
    " カレントディレクトリを取得
    let l:current_dir = getcwd()
    
    " 既存のタイマーがあれば停止
    if g:auto_git_timer_id != -1
        call timer_stop(g:auto_git_timer_id)
        let g:auto_git_timer_id = -1
    endif
    
    " 最初のcommit/pushを実行
    call s:AutoGitCommitPush()
    
    for dir in g:auto_git_dirs
        let l:expanded_dir = expand(dir)
        if l:current_dir =~ '^' . l:expanded_dir
            let g:auto_git_timer_id = timer_start(g:auto_git_interval, {-> execute('call s:AutoGitCommitPush()')}, {'repeat': -1})
            echo "Started auto git timer for " . l:expanded_dir
            break
        endif
    endfor
endfunction

" Vim起動時にタイマーを開始
augroup AutoGitCommitPush
    autocmd!
    autocmd VimEnter * call s:StartAutoGitTimer()
augroup END
