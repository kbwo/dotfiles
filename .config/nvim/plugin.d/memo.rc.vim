nnoremap <Leader>mn :MemoNew<CR>
nnoremap <Leader>ml<Space> :Fern ~/memo -reveal=~/memo/private<CR>
nnoremap <Leader>mls :Fern ~/memo -reveal=~/memo/private -opener=split<CR>
nnoremap <Leader>mlv :Fern ~/memo -reveal=~/memo/private -opener=vsplit<CR>
nnoremap <Leader>mlt :Fern ~/memo -reveal=~/memo/private -opener=tabedit<CR>
nnoremap <Leader>mg :MemoGrep<CR>
nnoremap <leader>md<Space> :execute 'edit ~/memo/' . strftime('%Y-%m-%d') . '.md'<CR>
nnoremap <leader>mds :execute 'split ~/memo/' . strftime('%Y-%m-%d') . '.md'<CR>
nnoremap <leader>mdv :execute 'vsplit ~/memo/' . strftime('%Y-%m-%d') . '.md'<CR>
nnoremap <leader>mdt :execute 'tabnew ~/memo/' . strftime('%Y-%m-%d') . '.md'<CR>

let g:memolist_memo_suffix = "md"
let g:memolist_ex_cmd = 'Fern'
