" imap <silent><script><expr> <c-e><c-n> copilot#Accept("\<CR>")
" imap <silent><script><expr> <c-e><c-d> <Plug>(copilot-dismiss)
" imap <silent><script><expr> <c-e><c-l> <Plug>(copilot-next)
" imap <silent><script><expr> <c-e><c-h> <Plug>(copilot-previous)
" let g:copilot_filetypes = {
" \ 'ddu-ff': v:false,
" \ 'ddu-ff-filter': v:true,
" \ }
" autocmd BufWritePre * :Copilot enable
" let g:copilot_no_tab_map = v:true
