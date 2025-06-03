let g:fern#disable_default_mappings = 1
let g:fern#default_hidden = 1

let g:previous_buffers = {}

function! SavePreviousBuffer()
  let current_winnr = win_getid()
  let current_file = expand('%:p')
  let g:previous_buffers[current_winnr] = current_file
endfunction

function! ReturnToPreviousBuffer()
  let current_winnr = win_getid()
  if has_key(g:previous_buffers, current_winnr)
    if g:previous_buffers[current_winnr] != ''
      execute 'edit ' . g:previous_buffers[current_winnr]
    else
      enew
      setlocal buftype=nofile
      setlocal bufhidden=wipe
      setlocal noswapfile
      setlocal nobuflisted
      setlocal nomodified
    endif
    call remove(g:previous_buffers, current_winnr)
  else
    execute 'Back'
  endif
endfunction

" ~/.vim/fern-toggle.vim
function! s:git_fern() abort
  call SavePreviousBuffer()
  let git_root = FindNearestGitRoot()
  execute 'Fern ' . git_root . ' -reveal=% -stay'
endfunction


nnoremap <silent> <C-n> :call <SID>git_fern()<CR>
nmap <silent> <c-w>c :call SavePreviousBuffer()<CR>:Fern %:h -reveal=% -stay<CR>


function! FernInit() abort
  nmap <silent><buffer> <c-n> :Fern .<CR>
  nmap <silent><buffer> <Leader>ss <Plug>(fern-action-open:split)
  nmap <silent><buffer> <Leader>vv <Plug>(fern-action-open:vsplit)
  nmap <silent><buffer> <Leader>tt <Plug>(fern-action-open:tabedit)
  nmap <silent><buffer> D <Plug>(fern-action-new-dir)
  nmap <silent><buffer> ! <Plug>(fern-action-hidden:toggle)
  nmap <silent><buffer> m <Plug>(fern-action-mark:toggle)gj
  nmap <silent><buffer> c <Plug>(fern-action-clipboard-copy)
  nmap <silent><buffer> <Leader>m <Plug>(fern-action-clipboard-move)
  nmap <silent><buffer> p <Plug>(fern-action-clipboard-paste)
  nmap <silent><buffer> M <Plug>(fern-action-new-file)
  nmap <silent><buffer> <cr> <Plug>(fern-action-open-or-enter)
  nmap <buffer><expr>
	      \ <Plug>(fern-my-open-or-expand-or-collapse)
	      \ fern#smart#leaf(
	      \   "<Plug>(fern-action-open)",
	      \   "<Plug>(fern-action-expand)",
	      \   "<Plug>(fern-action-collapse)",
	      \ )
  nmap <silent><buffer> o <Plug>(fern-my-open-or-expand-or-collapse)
  nmap <silent><buffer> <C-l> <Plug>(fern-action-reload)
  nmap <silent><buffer> rr <Plug>(fern-action-rename)
  nmap <silent><buffer> yy <Plug>(fern-action-yank)
  nmap <silent><buffer> dl <Plug>(fern-action-remove)
  nmap <silent><buffer> cd <Plug>(fern-action-tcd)
  nmap <silent><buffer> < <Plug>(fern-action-leave)
  nmap <silent><buffer> > <Plug>(fern-action-open-or-enter)
  nmap <silent><buffer> x :call ReturnToPreviousBuffer()<CR>
  nmap <silent><buffer> B :Back<CR>
  nmap <silent><buffer> R <Plug>(fern-action-redraw)
  nmap <silent><buffer> g? <Plug>(fern-action-help)
endfunction

augroup FernEvents
  autocmd!
  autocmd FileType fern call FernInit()
augroup END
