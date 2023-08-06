nnoremap <silent><c-d> :Lspsaga goto_definition<CR>
" TODO do this with ddu
nnoremap <silent>gr :Lspsaga finder<CR>
nnoremap <silent>cca :Lspsaga code_action<CR>
nnoremap <silent>csd :Lspsaga hover_doc<CR>
nnoremap <silent>ccn :Lspsaga rename<CR>
nnoremap <silent>csd :Lspsaga outline<CR>
" TODO UI bug on call this multiple times in a short time
nnoremap <silent><c-l> :Lspsaga diagnostic_jump_next<CR>

" TODO do this with ddu
" nnoremap <silent><leader>iw <cmd>lua require'lspsaga.diagnostic'.show_line_diagnostics()<CR>
