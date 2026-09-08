let g:gin_branch_disable_default_mappings = 1
let g:gin_status_disable_default_mappings = 1
let g:gin_log_disable_default_mappings = 1
let g:gin_proxy_editor_opener = "vsplit"

" gin.vim の各コマンドは ++worktree=<path> で対象の worktree を明示できる
" (無指定時は現在のバッファのファイル→無ければ cwd から自動検出する)。
" worktree-tab.rc.vim でこのタブに worktree が割り当てられていれば、
" 以下のマッピングはすべてそちらを明示的に指定する。<expr> マッピングに
" しているのは、割り当ては都度変わり得るためキー実行時に毎回評価したいから。
function! GinWorktreeOpt() abort
  let dir = WorktreeTabDir()
  return dir ==# '' ? '' : ' ++worktree=' . fnameescape(dir)
endfunction

nnoremap <expr> gns<Space> ':GinStatus' . GinWorktreeOpt() . "\<CR>"
nnoremap <expr> gnss ':GinStatus' . GinWorktreeOpt() . ' ++opener=split' . "\<CR>"
nnoremap <expr> gnsv ':GinStatus' . GinWorktreeOpt() . ' ++opener=vsplit' . "\<CR>"
nnoremap <expr> gnst ':GinStatus' . GinWorktreeOpt() . ' ++opener=tabedit' . "\<CR>"
nnoremap <expr> gnb<Space> ':GinBranch' . GinWorktreeOpt() . "\<CR>"
nnoremap <expr> gnbs ':GinBranch' . GinWorktreeOpt() . ' ++opener=split' . "\<CR>"
nnoremap <expr> gnbv ':GinBranch' . GinWorktreeOpt() . ' ++opener=vsplit' . "\<CR>"
nnoremap <expr> gnbt ':GinBranch' . GinWorktreeOpt() . ' ++opener=tabedit' . "\<CR>"

nnoremap <expr> gnd<Space> ':GinDiff' . GinWorktreeOpt() . "\<CR>"
nnoremap <expr> gnds ':GinDiff' . GinWorktreeOpt() . ' ++opener=split' . "\<CR>"
nnoremap <expr> gndv ':GinDiff' . GinWorktreeOpt() . ' ++opener=vsplit' . "\<CR>"
nnoremap <expr> gndt ':GinDiff' . GinWorktreeOpt() . ' ++opener=tabedit' . "\<CR>"

nnoremap <expr> gnc ':Gin' . GinWorktreeOpt() . ' commit' . "\<CR>"
nnoremap <expr> gnh ':Gin' . GinWorktreeOpt() . ' checkout -b'
nnoremap <expr> gnps ':Gin' . GinWorktreeOpt() . ' push'
nnoremap <expr> gnpl ':Gin' . GinWorktreeOpt() . ' pull' . "\<CR>"
nnoremap <expr> gnam ':Gin' . GinWorktreeOpt() . ' commit --amend' . "\<CR>"

nnoremap <expr> gnl<Space> ':GinLog' . GinWorktreeOpt() . ' --graph -n 1000' . "\<CR>"
nnoremap <expr> gnlp ':GinLog' . GinWorktreeOpt() . ' -p -n 100' . "\<CR>"
nnoremap <expr> gnls ':GinLog' . GinWorktreeOpt() . ' --graph -n 1000 ++opener=split' . "\<CR>"
nnoremap <expr> gnlv ':GinLog' . GinWorktreeOpt() . ' --graph -n 1000 ++opener=vsplit' . "\<CR>"
nnoremap <expr> gnlt ':GinLog' . GinWorktreeOpt() . ' --graph -n 1000 ++opener=tabedit' . "\<CR>"

nnoremap <expr> gnw ':GinBrowse' . GinWorktreeOpt() . ' --permalink' . "\<CR>"

let g:gin_log_persistent_args = [
      \ '++emojify',
      \  '--pretty=%C(yellow)%h%C(reset)%C(auto)%d%C(reset) %s %b %C(cyan)@%cd%C(reset) %C(magenta)[%ar]%C(reset)',
      \  '--date=iso-local'
      \]

function! CurrentFileLog() abort
  execute 'GinLog --graph -p ++opener=vsplit -- ' . expand('%:p')
endfunction

nmap gncl :call CurrentFileLog()<CR>

augroup GinLogMappings
  autocmd!
  autocmd FileType gin-log map <buffer><nowait> a<Space> <Plug>(gin-action-choice)
  autocmd FileType gin-log map <buffer><nowait> . <Plug>(gin-action-repeat)
  autocmd FileType gin-log map <buffer><nowait> g? <Plug>(gin-action-help:all)
  autocmd FileType gin-log map <buffer><nowait>dd<Space> <Plug>(gin-action-show)zv
  autocmd FileType gin-log map <buffer><nowait>ddv <Plug>(gin-action-show:vsplit)
  autocmd FileType gin-log map <buffer><nowait>dds <Plug>(gin-action-show:split)
  autocmd FileType gin-log map <buffer><nowait>ddt <Plug>(gin-action-show:tabedit)
  autocmd FileType gin-log map <buffer><nowait>ddf :call ShowHunkDiffCommitFloat()<CR>
  autocmd FileType gin-log nmap <buffer><nowait>yc <Plug>(gin-action-yank:commit)
  autocmd FileType gin-log nmap <buffer><nowait>ir <Plug>(gin-action-fixup:instant-fixup)
  autocmd FileType gin-log nmap <buffer><nowait>if <Plug>(gin-action-fixup:instant-reword)
  autocmd FileType gin-log nmap <buffer><nowait>ia <Plug>(gin-action-fixup:instant-amend)
  autocmd FileType gin-log nmap <buffer><nowait>cb :GinLog --first-parent<CR>
augroup END

augroup GinStatusMappings
  autocmd!
  autocmd FileType gin-status map <buffer><nowait> . <Plug>(gin-action-repeat)
  autocmd FileType gin-status map <buffer><nowait> <Return> <Plug>(gin-action-edit)zv
  autocmd FileType gin-status map <buffer><nowait> dd<Space> <Plug>(gin-action-diff:smart)
  autocmd FileType gin-status map <buffer><nowait> dds <Plug>(gin-action-diff:smart:split)
  autocmd FileType gin-status map <buffer><nowait> ddv <Plug>(gin-action-diff:smart:vsplit)
  autocmd FileType gin-status map <buffer><nowait> ddt <Plug>(gin-action-diff:smart:tabedit)
  autocmd FileType gin-status map <buffer><nowait> ddf :call ShowHunkDiffFloat()<CR>
  autocmd FileType gin-status map <buffer><nowait> pp <Plug>(gin-action-patch)
  autocmd FileType gin-status map <buffer><nowait> rr :!git reset<CR>
  autocmd FileType gin-status map <buffer><nowait> !! <Plug>(gin-action-chaperon)
  autocmd FileType gin-status map <buffer><nowait> < <Plug>(gin-action-stage)
  autocmd FileType gin-status map <buffer><nowait> > <Plug>(gin-action-unstage)
  autocmd FileType gin-status map <buffer><nowait> == <Plug>(gin-action-stash)
  autocmd FileType gin-status map <buffer><nowait> g? <Plug>(gin-action-help:all)
  autocmd FileType gin-status map <buffer><nowait> <Leader>vv <Plug>(gin-action-edit:local:vsplit)
  autocmd FileType gin-status map <buffer><nowait> <Leader>ss <Plug>(gin-action-edit:local:split)
  autocmd FileType gin-status map <buffer><nowait> <Leader>tt <Plug>(gin-action-edit:local:tabedit)
  autocmd FileType gin-status nmap <buffer><nowait>yy <Plug>(gin-action-yank:path)
augroup END

augroup GinBranchMappings
  autocmd!
  autocmd FileType gin-branch map <buffer><nowait> a<Space> <Plug>(gin-action-choice)
  autocmd FileType gin-branch map <buffer><nowait> . <Plug>(gin-action-repeat)
  autocmd FileType gin-branch nmap <buffer><nowait> <Return> <Plug>(gin-action-switch)
  autocmd FileType gin-branch nmap <buffer><nowait> yy <Plug>(gin-action-yank:branch)
  autocmd FileType gin-branch map <buffer><nowait> g? <Plug>(gin-action-help:all)
  autocmd FileType gin-branch map <buffer><nowait> dl <Plug>(gin-action-delete:force)
augroup END

function! DeleteAllGinBuffers() abort
  let l:buffers_to_delete = []
  for bufnr in range(1, bufnr('$'))
    if bufexists(bufnr)
      let filetype = getbufvar(bufnr, '&filetype')
      if filetype == 'gin-log' || filetype == 'gin-diff' || filetype == 'gin'
        call add(l:buffers_to_delete, bufnr)
      endif
    endif
  endfor
  
  for bufnr in l:buffers_to_delete
    execute 'silent! bdelete! ' . bufnr
  endfor
endfunction

nmap gndd :silent call DeleteAllGinBuffers()<CR>

" Common function to create floating window for hunk diff
function! OpenHunkFloatingWindow(cmd) abort
  " Get screen dimensions
  let width = float2nr(&columns * 0.85)
  let height = float2nr(&lines * 0.8)
  
  " Calculate position (centered)
  let col = float2nr((&columns - width) / 2)
  let row = float2nr((&lines - height) / 2)
  
  " Create floating window configuration
  let opts = {
        \ 'relative': 'editor',
        \ 'width': width,
        \ 'height': height,
        \ 'col': col,
        \ 'row': row,
        \ 'style': 'minimal',
        \ 'border': 'rounded'
        \ }
  
  " Create a buffer for the terminal
  let buf = nvim_create_buf(v:false, v:true)
  let win = nvim_open_win(buf, v:true, opts)
  
  " Run the command in the terminal
  call termopen(a:cmd)
endfunction

function! ShowHunkDiffFloat() range abort
  " Get git repository root
  let git_root = trim(system('git rev-parse --show-toplevel'))

  " Check if in visual mode
  if a:firstline != a:lastline
    " Visual line mode - get all selected lines
    let filepaths = []
    for lnum in range(a:firstline, a:lastline)
      let line = getline(lnum)
      " Extract from the 4th character to the end and trim whitespace
      let filepath = trim(line[3:])
      if !empty(filepath)
        " Prepend git root to the filepath
        let full_filepath = git_root . '/' . filepath
        call add(filepaths, full_filepath)
      endif
    endfor

    " Build command with all file paths
    if len(filepaths) > 0
      let cmd = 'hunk diff HEAD -- ' . join(map(copy(filepaths), 'shellescape(v:val)'), ' ')
      call OpenHunkFloatingWindow(cmd)
    endif
  else
    " Single line mode - original behavior
    let line = getline('.')
    " Extract from the 4th character to the end and trim whitespace
    let filepath = trim(line[3:])

    " Prepend git root to the filepath
    let full_filepath = git_root . '/' . filepath

    " Run hunk diff in the terminal
    let cmd = 'hunk diff HEAD -- ' . shellescape(full_filepath)
    call OpenHunkFloatingWindow(cmd)
  endif
endfunction

function! ShowHunkDiffCommitFloat() abort
  " Get the current line
  let line = getline('.')
  " Find the first 7-character continuous string (commit hash)
  let commit = matchstr(line, '\x\{7}')

  if empty(commit)
    echo "No commit hash found on this line"
    return
  endif

  " Run hunk show in the terminal
  let cmd = 'hunk show ' . shellescape(commit)
  call OpenHunkFloatingWindow(cmd)
endfunction

