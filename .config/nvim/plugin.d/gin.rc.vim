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
nmap gnl<Space> :GinLog --oneline --graph -n 1000<CR>
nmap gnlp :GinLog -p -n 100<CR>
nmap gnls :GinLog --oneline --graph -n 1000 ++opener=split<CR>
nmap gnlv :GinLog --oneline --graph -n 1000 ++opener=vsplit<CR>
nmap gnlt :GinLog --oneline --graph -n 1000 ++opener=tabedit<CR>
nmap gnw :GinBrowse<CR>

function! CurrentFileLog() abort
  execute 'GinLog --graph -p ++opener=vsplit -- ' . expand('%:p')
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
  autocmd FileType gin-log map <buffer><nowait> a <Plug>(gin-action-choice)
  autocmd FileType gin-log map <buffer><nowait> . <Plug>(gin-action-repeat)
  autocmd FileType gin-status map <buffer><nowait> g? <Plug>(gin-action-help:all)
  autocmd FileType gin-log map <buffer><nowait>dd<Space> <Plug>(gin-action-show)zv
  autocmd FileType gin-log map <buffer><nowait>ddv <Plug>(gin-action-show:vsplit)
  autocmd FileType gin-log map <buffer><nowait>dds <Plug>(gin-action-show:split)
  autocmd FileType gin-log map <buffer><nowait>ddt <Plug>(gin-action-show:tabedit)
augroup END

augroup GinStatusMappings
  autocmd FileType gin-log map <buffer><nowait> a <Plug>(gin-action-choice)
  autocmd FileType gin-status map <buffer><nowait> . <Plug>(gin-action-repeat)
  autocmd FileType gin-status map <buffer><nowait> <Return> <Plug>(gin-action-edit)zv
  autocmd FileType gin-status map <buffer><nowait> dd<Space> <Plug>(gin-action-diff:smart)
  autocmd FileType gin-status map <buffer><nowait> dds <Plug>(gin-action-diff:smart:split)
  autocmd FileType gin-status map <buffer><nowait> ddv <Plug>(gin-action-diff:smart:vsplit)
  autocmd FileType gin-status map <buffer><nowait> ddt <Plug>(gin-action-diff:smart:tabedit)
  autocmd FileType gin-status map <buffer><nowait> pp <Plug>(gin-action-patch)
  autocmd FileType gin-status map <buffer><nowait> !! <Plug>(gin-action-chaperon)
  autocmd FileType gin-status map <buffer><nowait> < <Plug>(gin-action-stage)
  autocmd FileType gin-status map <buffer><nowait> > <Plug>(gin-action-unstage)
  autocmd FileType gin-status map <buffer><nowait> == <Plug>(gin-action-stash)
  autocmd FileType gin-status map <buffer><nowait> g? <Plug>(gin-action-help:all)
  autocmd FileType gin-status map <buffer><nowait> <Leader>vv <Plug>(gin-action-edit:local:vsplit)
  autocmd FileType gin-status map <buffer><nowait> <Leader>ss <Plug>(gin-action-edit:local:split)
  autocmd FileType gin-status map <buffer><nowait> <Leader>tt <Plug>(gin-action-edit:local:tabedit)
augroup END

augroup GinBranchMappings
  autocmd FileType gin-log map <buffer><nowait> a <Plug>(gin-action-choice)
  autocmd FileType gin-status map <buffer><nowait> . <Plug>(gin-action-repeat)
  autocmd FileType gin-branch nmap <buffer><nowait> <Return> <Plug>(gin-action-switch)
  autocmd FileType gin-branch map <buffer><nowait> . <Plug>(gin-action-repeat)
  autocmd FileType gin-branch map <buffer><nowait> yy <Plug>(gin-action-yank:branch)
  autocmd FileType gin-status map <buffer><nowait> g? <Plug>(gin-action-help:all)
augroup END

function! DiffBranchAll()
  let l:branch = input("Enter branch: ")
  if !empty(l:branch)
    execute 'GinDiff ' . l:branch
  endif
endfunction

nnoremap <leader>da :call DiffBranchAll()<CR>
