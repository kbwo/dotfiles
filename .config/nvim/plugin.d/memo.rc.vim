nnoremap <Leader>mn :MemoNew<CR>
nnoremap <Leader>ml<Space> :Fern ~/memo -reveal=~/memo/private<CR>
nnoremap <Leader>mls :Fern ~/memo -reveal=~/memo/private -opener=split<CR>
nnoremap <Leader>mlv :Fern ~/memo -reveal=~/memo/private -opener=vsplit<CR>
nnoremap <Leader>mlt :Fern ~/memo -reveal=~/memo/private -opener=tabedit<CR>
nnoremap <Leader>mg :MemoGrep<CR>
let g:memolist_memo_suffix = "md"
let g:memolist_ex_cmd = 'Fern'
