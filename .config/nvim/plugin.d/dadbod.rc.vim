let g:db_ui_winwidth = 60

autocmd FileType sql nmap <buffer> <Leader>sd <Plug>(DBUI_SaveQuery)
autocmd FileType mysql nmap <Leader>sd <Plug>(DBUI_SaveQuery)
