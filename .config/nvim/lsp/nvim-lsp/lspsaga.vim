nnoremap <silent><c-d> :Lspsaga lsp_finder<CR>
nnoremap <silent>cca :Lspsaga code_action<CR>
nnoremap <silent><Leader>hd :Lspsaga hover_doc<CR>
nnoremap <silent>ccn :Lspsaga rename<CR>
nnoremap <silent><c-l> :Lspsaga diagnostic_jump_next<CR>

nnoremap <silent><leader>iw <cmd>lua require'lspsaga.diagnostic'.show_line_diagnostics()<CR>
