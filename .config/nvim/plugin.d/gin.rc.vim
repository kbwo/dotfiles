let g:gin_branch_disable_default_mappings = 1
let g:gin_status_disable_default_mappings = 1
let g:gin_log_disable_default_mappings = 1

nmap gns<Space> :GinStatus<CR>
nmap gnss :GinStatus ++opener=split<CR>
nmap gnsv :GinStatus ++opener=vsplit<CR>
nmap gnst :GinStatus ++opener=tabedit<CR>
nmap gnc :Gin commit<CR>
let g:gin_proxy_editor_opener = "vsplit"
nmap gnb<Space> :GinBranch<CR>
nmap gnbs :GinBranch ++opener=split<CR>
nmap gnbv :GinBranch ++opener=vsplit<CR>
nmap gnbt :GinBranch ++opener=tabedit<CR>
nmap gnh :Gin checkout -b
nmap gnps :Gin push
nmap gnpl :Gin pull<CR>
nmap gnam :Gin commit --amend<CR>

nmap gnl<Space> :GinLog --graph -n 1000<CR>
nmap gnlp :GinLog -p -n 100<CR>
nmap gnls :GinLog --graph -n 1000 ++opener=split<CR>
nmap gnlv :GinLog --graph -n 1000 ++opener=vsplit<CR>
nmap gnlt :GinLog --graph -n 1000 ++opener=tabedit<CR>
nmap gnw :GinBrowse --permalink<CR>

let g:gin_log_persistent_args = [
      \ '++emojify',
      \  '--pretty=%C(yellow)%h%C(reset)%C(auto)%d%C(reset) %s %b %C(cyan)@%an%C(reset) %C(magenta)[%ar]%C(reset)'
      \]
let s:has_delta = executable("delta") == 1
" disable delta as <CR> won't work
let s:processor = v:null
if s:has_delta
  let s:processor = "delta --no-gitconfig --color-only"
  let g:gin_diff_persistent_args = ["++processor=" . s:processor]
endif


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
  autocmd FileType gin-log map <buffer><nowait>ddf :call ShowDeltaDiffCommitFloat()<CR>
  autocmd FileType gin-log nmap <buffer><nowait>yc <Plug>(gin-action-yank:commit)
  autocmd FileType gin-log nmap <buffer><nowait>ir <Plug>(gin-action-fixup:instant-fixup)
  autocmd FileType gin-log nmap <buffer><nowait>if <Plug>(gin-action-fixup:instant-reword)
  autocmd FileType gin-log nmap <buffer><nowait>ia <Plug>(gin-action-fixup:instant-amend)
augroup END

augroup GinStatusMappings
  autocmd!
  autocmd FileType gin-status map <buffer><nowait> . <Plug>(gin-action-repeat)
  autocmd FileType gin-status map <buffer><nowait> <Return> <Plug>(gin-action-edit)zv
  autocmd FileType gin-status map <buffer><nowait> dd<Space> <Plug>(gin-action-diff:smart)
  autocmd FileType gin-status map <buffer><nowait> dds <Plug>(gin-action-diff:smart:split)
  autocmd FileType gin-status map <buffer><nowait> ddv <Plug>(gin-action-diff:smart:vsplit)
  autocmd FileType gin-status map <buffer><nowait> ddt <Plug>(gin-action-diff:smart:tabedit)
  autocmd FileType gin-status map <buffer><nowait> ddf :call ShowDeltaDiffFloat()<CR>
  autocmd FileType gin-status map <buffer><nowait> pp <Plug>(gin-action-patch)
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

" Common function to create floating window for delta diff
function! OpenDeltaFloatingWindow(cmd) abort
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

function! ShowDeltaDiffFloat() abort
  " Get the current line and extract the file path
  let line = getline('.')
  " Extract from the 4th character to the end and trim whitespace
  let filepath = trim(line[3:])
  
  " Run git diff with delta in the terminal
  let cmd = 'git add -N '. shellescape(filepath) . ' && git diff ' . shellescape(filepath) . ' | delta --side-by-side --paging=never'
  call OpenDeltaFloatingWindow(cmd)
endfunction

function! ShowDeltaDiffCommitFloat() abort
  " Get the current line
  let line = getline('.')
  " Find the first 7-character continuous string (commit hash)
  let commit = matchstr(line, '\x\{7}')
  
  if empty(commit)
    echo "No commit hash found on this line"
    return
  endif
  
  " Run git show with delta in the terminal
  let cmd = 'git show ' . shellescape(commit) . ' | delta --side-by-side --paging=never'
  call OpenDeltaFloatingWindow(cmd)
endfunction

