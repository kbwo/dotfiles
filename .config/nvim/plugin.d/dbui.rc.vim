let g:db_ui_disable_mappings = 1

" call db_ui#utils#set_mapping(['o', '<CR>', '<2-LeftMouse>'], '<Plug>(DBUI_SelectLine)')
" call db_ui#utils#set_mapping('R', '<Plug>(DBUI_Redraw)')
" call db_ui#utils#set_mapping('d', '<Plug>(DBUI_DeleteLine)')
" call db_ui#utils#set_mapping('A', '<Plug>(DBUI_AddConnection)')
" call db_ui#utils#set_mapping('r', '<Plug>(DBUI_RenameLine)')
" call db_ui#utils#set_mapping('<c-k>', '<Plug>(DBUI_GotoPrevSibling)')
" call db_ui#utils#set_mapping('<c-j>', '<Plug>(DBUI_GotoNextSibling)')
" call db_ui#utils#set_mapping('<C-p>', '<Plug>(DBUI_GotoParentNode)')
" call db_ui#utils#set_mapping('<C-n>', '<Plug>(DBUI_GotoChildNode)')

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



