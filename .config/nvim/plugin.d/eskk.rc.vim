" if empty(glob('~/.config/nvim/eskk.vim/SKK-JISYO.L'))
"   silent !curl -fLo ~/.config/nvim/eskk.vim/SKK-JISYO.L --create-dirs
"         \ http://openlab.jp/skk/skk/dic/SKK-JISYO.L
" endif
" let g:eskk#directory = '~/.config/nvim/eskk.vim'
"
" let g:eskk#large_dictionary = {
"       \ 'path': '~/.config/nvim/eskk.vim/SKK-JISYO.L',
"       \ 'sorted': 1,
"       \ 'encoding': 'euc-jp',
"       \ }
"
" let g:eskk#dictionary = {
"       \ 'path': '~/.config/nvim/eskk.vim/user.dict',
"       \ 'sorted': 0,
"       \ 'encoding': 'utf-8',
"       \}
"
" autocmd User eskk-initialize-pre call s:eskk_initial_pre()
" autocmd  User eskk-enable-pre  silent! let b:coc_diagnostic_disable = 1
" autocmd  User eskk-disable-pre silent! let b:coc_diagnostic_disable = 0
" function! s:eskk_initial_pre()
"   let t = eskk#table#new('rom_to_hira*', 'rom_to_hira')
"   call t.add_map('pc', '・')
"   call eskk#register_mode_table('hira', t)
" endfunction
" let g:eskk#marker_henkan = '»'
" let g:eskk#marker_okuri = '*'
" let g:eskk#marker_henkan_select = '«'
" let g:eskk#show_candidates_count = 2
