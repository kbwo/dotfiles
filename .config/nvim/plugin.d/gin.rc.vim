let g:gin_branch_disable_default_mappings = 1
let g:gin_status_disable_default_mappings = 1
let g:gin_log_disable_default_mappings = 1

nmap gns :GinStatus<CR>
nmap gnc :Gin commit<CR>
nmap gnb :GinBranch<CR>
nmap gnh :Gin checkout -b
nmap gnps :Gin push
nmap gnpl :Gin pull<CR>
nmap gnl :GinLog --oneline --graph -n 1000

function! CurrentFileLog() abort
  execute 'GinLog --graph -p -- ' . expand('%:p')
endfunction

nmap gncl :call CurrentFileLog()<CR>

" map <buffer><nowait> a <Plug>(gin-action-choice)
" map <buffer><nowait> . <Plug>(gin-action-repeat)
" nmap <buffer><nowait> ? <Plug>(gin-action-help)
"
" map <buffer><nowait> <Return> <Plug>(gin-action-show)zv
"
" nunmap <buffer><nowait> yy
" vunmap <buffer><nowait> y
augroup GinLogMappings
  autocmd!
  autocmd FileType gin-log map <buffer><nowait> <Return> <Plug>(gin-action-show)zv
augroup END

augroup GinStatusMappings
  autocmd FileType gin-status map <buffer><nowait> . <Plug>(gin-action-repeat)
  autocmd FileType gin-status map <buffer><nowait> <Return> <Plug>(gin-action-edit)zv
  autocmd FileType gin-status map <buffer><nowait> dd <Plug>(gin-action-diff:smart)
  autocmd FileType gin-status map <buffer><nowait> pp <Plug>(gin-action-patch)
  autocmd FileType gin-status map <buffer><nowait> !! <Plug>(gin-action-chaperon)
  autocmd FileType gin-status map <buffer><nowait> < <Plug>(gin-action-stage)
  autocmd FileType gin-status map <buffer><nowait> > <Plug>(gin-action-unstage)
  autocmd FileType gin-status map <buffer><nowait> == <Plug>(gin-action-stash)
augroup END

augroup GinBranchMappings
  autocmd FileType gin-branch nmap <buffer><nowait> <Return> <Plug>(gin-action-switch)
  autocmd FileType gin-branch map <buffer><nowait> . <Plug>(gin-action-repeat)
augroup END

function! DiffBranchAll()
  let l:branch = input("Enter branch: ")
  if !empty(l:branch)
    execute 'GinDiff ' . l:branch
  endif
endfunction

nnoremap <leader>da :call DiffBranchAll()<CR>
