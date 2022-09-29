" let g:gin_status_disable_default_mappings = 1
" autocmd FileType gin-status map <silent> -- <Plug>(gin-action-unstage)
" autocmd FileType gin-status map <silent> << <Plug>(gin-action-stash)
" autocmd FileType gin-status map <silent> ++ <Plug>(gin-action-stage)
" autocmd FileType gin-status map <silent> ? <Plug>(gin-action-help)
"
" nmap gns :GinStatus ++opener=botright\ vsplit<CR>
" nmap gnc :Gin commit<CR>
" nmap gnb :Gin branch ++opener=botright\ vsplit<CR>
" nmap gnh :Gin checkout -b
" nmap gnps :Gin push
" nmap gnpl :Gin pull<CR>
" nmap gnl :Gina log --oneline --graph<CR>
