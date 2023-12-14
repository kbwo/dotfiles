" nmap gns :GinStatus<CR>
" nmap gnc :Gin commit<CR>
" nmap gnb :GinBranch<CR>
" nmap gnh :Gin checkout -b
" nmap gnps :Gin push
" nmap gnpl :Gin pull<CR>
" nmap gnl :GinLog --oneline --graph<CR>
"
" function! CurrentFileLog() abort
"   execute 'GinLog --graph -p -- ' . expand('%:p')
" endfunction
"
" nmap gncl :call CurrentFileLog()<CR>
