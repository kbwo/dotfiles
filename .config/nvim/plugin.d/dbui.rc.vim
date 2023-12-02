let g:db_ui_disable_mappings = 1

autocmd FileType dbui nmap <buffer> o <Plug>(DBUI_SelectLine)
autocmd FileType dbui nmap <buffer> <CR> <Plug>(DBUI_SelectLine)
autocmd FileType dbui nmap <buffer> R <Plug>(DBUI_Redraw)
autocmd FileType dbui nmap <buffer> d <Plug>(DBUI_DeleteLine)
autocmd FileType dbui nmap <buffer> A <Plug>(DBUI_AddConnection)
autocmd FileType dbui nmap <buffer> r <Plug>(DBUI_RenameLine)
autocmd FileType dbui nmap <buffer> <c-k> <Plug>(DBUI_GotoPrevSibling)
autocmd FileType dbui nmap <buffer> <c-j> <Plug>(DBUI_GotoNextSibling)
autocmd FileType dbui nmap <buffer> <C-p> <Plug>(DBUI_GotoParentNode)
autocmd FileType dbui nmap <buffer> <C-n> <Plug>(DBUI_GotoChildNode)



