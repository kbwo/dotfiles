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
        endif
    endfor
endfunction

function! CloseTabsAfterCurrent()
    let current_tab = tabpagenr()
    let total_tabs = tabpagenr('$')
    
    for i in range(current_tab + 1, total_tabs)
        execute 'tabclose ' . (current_tab + 1)
    endfor
endfunction

inoremap <silent> <c-u> <Nop>
inoremap <silent> <c-w> <Esc>:w<CR>
map <silent> K gt
map <silent> J gT
nmap <silent> <Leader>1 :tabfirst<CR>
nmap <silent> <Leader>2 :tabnext 2<CR>
nmap <silent> <Leader>3 :tabnext 3<CR>
nmap <silent> <Leader>4 :tabnext 4<CR>
nmap <silent> <Leader>5 :tabnext 5<CR>
nmap <silent> <Leader>6 :tabnext 6<CR>
nmap <silent> <Leader>7 :tabnext 7<CR>
nmap <silent> <Leader>8 :tabnext 8<CR>
nmap <silent> <Leader>9 :tablast<CR>
nmap <silent> <Leader>tm1 :tabmove 0<CR>
nmap <silent> <Leader>tm2 :tabmove 1<CR>
nmap <silent> <Leader>tm3 :tabmove 2<CR>
nmap <silent> <Leader>tm4 :tabmove 3<CR>
nmap <silent> <Leader>tm5 :tabmove 4<CR>
nmap <silent> <Leader>tm6 :tabmove 5<CR>
nmap <silent> <Leader>tm7 :tabmove 6<CR>
nmap <silent> <Leader>tm8 :tabmove 7<CR>
nmap <silent> <Leader>tm9 :tabmove $<CR>
nmap <silent> <Leader>te :call CloseTabsAfterCurrent()<CR>
nmap <silent> <Leader>tq :call CloseTabsAfterCurrent()<CR>
nmap <silent> j gj
vmap <silent> j gj
nmap <silent> k gk
vmap <silent> k gk
nmap <silent> R :join<CR>
nmap <silent> <M-r> :join!<CR>
" nmap <silent> <Leader>j :-tabmove<CR>
" nmap <silent> <Leader>k :+tabmove<CR>
nmap <silent> Q :call CloseAllTermBuffers()<CR>:execute 'cd' getenv("PWD")<CR>:confirm qa<CR>
nmap <silent> R :join<CR>
nmap <silent> <Down> gj
nmap <silent> <Up> gk
nmap <silent> + <C-a>
nmap <silent> - <C-x>
imap <silent> <S-Tab> <C-o><<
nmap <silent> <Leader>x :q<CR>
nmap <silent> <Leader>zx :tabc<CR>
nmap <silent><c-w>t :let b = bufnr('%')<CR>:close<CR>:tabnew<CR>:execute 'buffer' b<CR>
imap <silent> <C-\> <Esc>

" tabnew and preserve cursor position
nmap <silent> <Leader>t<Space> :tab split<CR>
nmap <silent> <Leader>tn :NoFile<CR>
nmap <silent> <Leader>l :cd %:h<CR>
nmap <silent> <Leader>h :noh<CR>
nmap <silent> <Leader>e<Space> :e!<CR>
nmap <silent> <Leader>ya :%y<CR>
tnoremap <silent> <C-\> <C-\><C-n>
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
autocmd TermOpen * setlocal number
set scrolloff=3
set laststatus=2
set modeline
set modelines=10
set title
set titleold="Terminal"
set titlestring=%F
set autoread
set updatetime=100
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
set endofline
set fixendofline

" Yank relative path with line number
function! YankRelativePathWithLine()
  let l:relpath = fnamemodify(expand('%'), ':.')
  if empty(l:relpath)
    echo 'No file to yank'
  else
    let l:line = line('.')
    let l:text = l:relpath . '#L' . l:line
    let @+ = l:text
    echo 'Copied: ' . l:text
  endif
endfunction
nmap <Leader>yr :YankRelativePath<CR>
nmap <Leader>yl :call YankRelativePathWithLine()<CR>

" Append yanked text to clipboard with whitespace
function! GetExistingClipboard()
  return getreg('+')
endfunction

function! AppendYankRelativePath()
  let l:relpath = fnamemodify(expand('%'), ':.')
  if empty(l:relpath)
    echo 'No file to yank'
  else
    let l:existing = GetExistingClipboard()
    let @+ = l:existing . "\n" . l:relpath
    echo 'Appended: ' . l:relpath
  endif
endfunction

function! AppendYankRelativePathWithLine()
  let l:relpath = fnamemodify(expand('%'), ':.')
  if empty(l:relpath)
    echo 'No file to yank'
  else
    let l:line = line('.')
    let l:text = l:relpath . '#L' . l:line
    let l:existing = GetExistingClipboard()
    let @+ = l:existing . "\n" . l:text
    echo 'Appended: ' . l:text
  endif
endfunction

nmap <Leader>yyr :call AppendYankRelativePath()<CR>
nmap <Leader>yyl :call AppendYankRelativePathWithLine()<CR>

" Visual mode version - yank relative path with line range
function! YankRelativePathWithLineRange() range
  let l:relpath = fnamemodify(expand('%'), ':.')
  if empty(l:relpath)
    echo 'No file to yank'
  else
    let l:from_line = a:firstline
    let l:to_line = a:lastline
    let l:text = l:relpath . '#L' . l:from_line . '-' . l:to_line
    let @+ = l:text
    echo 'Copied: ' . l:text
  endif
endfunction
vmap <Leader>yl :call YankRelativePathWithLineRange()<CR>

nmap gno o<Esc>
nmap gnO O<Esc>
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
    return a:tabnr . ':' . filetype
  endif

  " Default label if buffer doesn't exist
  if bufname ==# '' || buflisted(bufnr) == 0
    return a:tabnr . ':' . (filetype !=# '' ? filetype : 'No Name')
  endif
  
  " Get parent directory name and file name from full path
  let parent_dir = fnamemodify(bufname, ':p:h:t') " Parent directory name
  let file_name = fnamemodify(bufname, ':t')      " File name
  return a:tabnr . ':' . parent_dir . '/' . file_name
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

autocmd BufNewFile,BufRead *.mdc set filetype=markdown

" 自動コミット・プッシュを行うディレクトリのリスト
let g:auto_git_dirs = ['~/obs-kbwo']

" シェルスクリプトを起動する関数
function! s:StartAutoGit() abort
    if !exists('g:auto_git_job')
        " 現在のディレクトリが対象ディレクトリリストに含まれているか確認
        let l:current_dir = expand('%:p:h')
        let l:is_target_dir = 0
        
        for dir in g:auto_git_dirs
            let l:expanded_dir = expand(dir)
            if l:current_dir =~# '^' . l:expanded_dir
                let l:is_target_dir = 1
                break
            endif
        endfor
        
        if !l:is_target_dir
            return
        endif
        
        " ディレクトリリストをスペース区切りで結合
        let l:dir_list = join(map(g:auto_git_dirs, 'expand(v:val)'), ' ')
        " 最初のディレクトリにauto_git.shがあると仮定
        let l:script_dir = expand(g:auto_git_dirs[0])
        let l:script_path = l:script_dir . '/auto_git.sh'
        
        if !filereadable(l:script_path)
            echom "Error: auto_git.sh not found in " . l:script_dir
            return
        endif
        
        let l:cmd = 'bash ' . l:script_path . ' ' . l:dir_list
        
        " Neovimのjobstartで非同期実行
        let g:auto_git_job = jobstart(l:cmd, {
            \ 'on_stdout': function('s:HandleOutput'),
            \ 'on_stderr': function('s:HandleError'),
            \ 'on_exit': function('s:HandleExit'),
            \ })
        echom "Started auto git script for directories: " . l:dir_list
    endif
endfunction

" 出力ハンドラ
function! s:HandleOutput(job_id, data, event) abort
    if !empty(a:data[0])
        echom join(a:data, "\n")
    endif
endfunction

" エラーハンドラ
function! s:HandleError(job_id, data, event) abort
    if !empty(a:data[0])
        echom 'Error: ' . join(a:data, "\n")
    endif
endfunction

" 終了ハンドラ
function! s:HandleExit(job_id, data, event) abort
    echom "Auto git job finished with code: " . a:data
    unlet g:auto_git_job
endfunction

" Neovim起動時に実行
augroup AutoGitCommitPush
    autocmd!
    autocmd VimEnter * call s:StartAutoGit()
augroup END

nmap <silent><Leader>ml<Space> :Fern ~/memo -reveal=~/memo/private<CR>
nmap <silent><Leader>mls :Fern ~/memo -reveal=~/memo/private -opener=split<CR>
nmap <silent><Leader>mlv :Fern ~/memo -reveal=~/memo/private -opener=vsplit<CR>
nmap <silent><Leader>mlt :Fern ~/memo -reveal=~/memo/private -opener=tabedit<CR>
function! GetWeeklyMemoPath()
  let today = localtime()
  let day_of_week = strftime('%w', today)
  " Convert Sunday (0) to 7 for easier calculation
  let day_of_week = day_of_week == 0 ? 7 : day_of_week
  " Calculate days to Monday (1) and Sunday (7)
  let days_to_monday = 1 - day_of_week
  let days_to_sunday = 7 - day_of_week
  let monday = today + (days_to_monday * 86400)
  let sunday = today + (days_to_sunday * 86400)
  return '~/memo/' . strftime('%Y-%m-%d', monday) . '--' . strftime('%Y-%m-%d', sunday) . '.md'
endfunction

nmap <silent><leader>md<Space> :execute 'edit ' . GetWeeklyMemoPath()<CR>
nmap <silent><leader>mds :execute 'split ' . GetWeeklyMemoPath()<CR>
nmap <silent><leader>mdv :execute 'vsplit ' . GetWeeklyMemoPath()<CR>
nmap <silent><leader>mdt :execute 'tabnew ' . GetWeeklyMemoPath()<CR>
function! ToggleMemoFloat()
  lua << EOF
    local win_config = vim.api.nvim_win_get_config(0)
    -- Get weekly memo path using the Vim function
    local memo_path = vim.fn.expand(vim.fn.GetWeeklyMemoPath())
    
    if win_config.relative ~= "" then
      -- Current window is a floating window
      local current_buf = vim.api.nvim_win_get_buf(0)
      local current_buf_name = vim.api.nvim_buf_get_name(current_buf)
      
      if current_buf_name == memo_path then
        -- Same as memo_path, close the floating window
        vim.api.nvim_win_close(0, false)
      else
        -- Different from memo_path, just edit memo_path
        vim.cmd("edit " .. memo_path)
      end
    else
      -- Check if a floating window with this file already exists
      local existing_win = nil
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local cfg = vim.api.nvim_win_get_config(win)
        if cfg.relative ~= "" then
          local buf = vim.api.nvim_win_get_buf(win)
          local buf_name = vim.api.nvim_buf_get_name(buf)
          if buf_name == memo_path then
            existing_win = win
            break
          end
        end
      end
      
      if existing_win then
        -- Focus the existing floating window
        vim.api.nvim_set_current_win(existing_win)
      else
        -- Check if buffer already exists
        local buf = vim.fn.bufnr(memo_path)
        local is_new_buffer = false
        if buf == -1 then
          buf = vim.api.nvim_create_buf(false, true)
          is_new_buffer = true
        end
        
        local h = math.floor(vim.o.lines * 0.8)
        local w = 150
        vim.api.nvim_open_win(
          buf,
          true,
          {
            relative = 'editor',
            width = w,
            height = h,
            col = math.floor((vim.o.columns - w) / 2),
            row = math.floor((vim.o.lines - h) / 2),
            style = 'minimal',
            border = 'rounded'
          }
        )
        -- Force edit without saving changes, ignore errors
        vim.cmd("silent! edit " .. memo_path)
        vim.wo.number = true
        if is_new_buffer then
          vim.cmd("normal! G")
        end
      end
    end
EOF
endfunction

nmap <silent><leader>mdf :call ToggleMemoFloat()<CR>
nmap <silent><leader>mf :call ToggleMemoFloat()<CR>

" 各種イベントでファイルの変更をチェック
autocmd FocusGained,BufEnter,CursorHold,CursorHoldI *
  \ if mode() !~ '\v(c|r.?|!|t)' && getcmdwintype() == '' && expand('%:e') !~# '\v^(log|txt)$' | checktime | endif
