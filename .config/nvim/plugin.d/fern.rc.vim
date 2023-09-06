nmap <silent> <c-n> :Fern . -reveal=% -stay<CR>
nmap <silent> <c-w>c :Fern %:h -reveal=% -stay<CR>
function! FernInit() abort
  nmap <silent><buffer> <c-n> :Fern .<CR>
  nmap <silent><buffer> <Leader>ss <Plug>(fern-action-open:split)
  nmap <silent><buffer> <Leader>vv <Plug>(fern-action-open:vsplit)
  nmap <silent><buffer> <Leader>tt <Plug>(fern-action-open:tabedit)
  nmap <silent><buffer> D <Plug>(fern-action-new-dir)
  nmap <silent><buffer> ! <Plug>(fern-action-hidden:toggle)
  nmap <silent><buffer> m <Plug>(fern-action-mark:toggle)
  nmap <silent><buffer> c <Plug>(fern-action-clipboard-copy)
  nmap <silent><buffer> <Leader>m <Plug>(fern-action-clipboard-move)
  nmap <silent><buffer> p <Plug>(fern-action-clipboard-paste)
  nmap <silent><buffer> M <Plug>(fern-action-new-file)
  nmap <silent><buffer> F <Plug>(fern-action-open-or-enter)
  nmap <silent><buffer> <cr> <Plug>(fern-action-open-or-enter)
  nmap <buffer><expr>
	      \ <Plug>(fern-my-open-or-expand-or-collapse)
	      \ fern#smart#leaf(
	      \   "<Plug>(fern-action-open)",
	      \   "<Plug>(fern-action-expand)",
	      \   "<Plug>(fern-action-collapse)",
	      \ )
  nmap <silent><buffer> o <Plug>(fern-my-open-or-expand-or-collapse)
  " nmap <buffer> s <Plug>(fern-action-open:select)
  nmap <silent><buffer> <C-l> <Plug>(fern-action-reload)
  nmap <silent><buffer> rr <Plug>(fern-action-rename)
  " nmap <buffer> i <Plug>(fern-action-reveal)
  " nmap <buffer> dl <Plug>(fern-action-trash)
  nmap <silent><buffer> yy <Plug>(fern-action-yank)
  " nmap <buffer> gr <Plug>(fern-action-grep)
  nmap <silent><buffer> dl <Plug>(fern-action-remove)
  " nmap <buffer> B <Plug>(fern-action-save-as-bookmark)
  nmap <silent><buffer> cd <Plug>(fern-action-tcd)
  nmap <silent><buffer> B <Plug>(fern-action-leave)
  nmap <silent><buffer> x :Back<CR>
endfunction
augroup FernEvents
  autocmd!
  autocmd FileType fern call FernInit()
augroup END
let g:fern#disable_default_mappings = 1
let g:fern#default_hidden = 1

nmap <silent> rel :Fern ~/.http -reveal=% -stay<CR>
