nnoremap <silent>cca :Lspsaga code_action<CR>
nnoremap <silent>csd :Lspsaga hover_doc<CR>
nnoremap <silent>ccn :Lspsaga rename<CR>
nnoremap <silent>csm :Lspsaga outline<CR>
" TODO UI bug on call this multiple times in a short time
nnoremap <silent><c-l> :Lspsaga diagnostic_jump_next ++unfocus<CR>
nnoremap <silent><c-h> :Lspsaga diagnostic_jump_prev ++unfocus<CR>
nmap <silent><Leader>iw :Lspsaga show_workspace_diagnostics ++normal<CR>
" nnoremap <silent><c-l> <cmd>lua vim.lsp.diagnostic.goto_next()<CR>

" TODO do this with ddu
" nnoremap <silent><leader>iw <cmd>lua require'lspsaga.diagnostic'.show_line_diagnostics()<CR>
