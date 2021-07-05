nnoremap <silent><c-d> :Lspsaga lsp_finder<CR>
nnoremap <silent>cca :Lspsaga code_action<CR>
nnoremap <silent>hd :Lspsaga hover_doc<CR>
nnoremap <silent>ccn :Lspsaga rename<CR>

nnoremap <silent><leader>iw <cmd>lua require'lspsaga.diagnostic'.show_line_diagnostics()<CR>
nnoremap <silent><c-l> <cmd>lua require'lspsaga.diagnostic'.lsp_jump_diagnostic_next()<CR>
