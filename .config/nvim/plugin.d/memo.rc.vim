nnoremap <silent><Leader>mn :MemoNew<CR>
nnoremap <silent><Leader>ml<Space> :Fern ~/memo -reveal=~/memo/private<CR>
nnoremap <silent><Leader>mls :Fern ~/memo -reveal=~/memo/private -opener=split<CR>
nnoremap <silent><Leader>mlv :Fern ~/memo -reveal=~/memo/private -opener=vsplit<CR>
nnoremap <silent><Leader>mlt :Fern ~/memo -reveal=~/memo/private -opener=tabedit<CR>
nnoremap <silent><Leader>mg :MemoGrep<CR>
nnoremap <silent><leader>md<Space> :execute 'edit ~/memo/' . strftime('%Y-%m-%d') . '.md'<CR>
nnoremap <silent><leader>mds :execute 'split ~/memo/' . strftime('%Y-%m-%d') . '.md'<CR>
nnoremap <silent><leader>mdv :execute 'vsplit ~/memo/' . strftime('%Y-%m-%d') . '.md'<CR>
nnoremap <silent><leader>mdt :execute 'tabnew ~/memo/' . strftime('%Y-%m-%d') . '.md'<CR>

let g:memolist_memo_suffix = "md"
let g:memolist_ex_cmd = 'Fern'
