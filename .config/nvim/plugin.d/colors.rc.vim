set termguicolors

if has('nvim')
  colorscheme kanagawa
  highlight Visual guifg=#FFFFFF guibg=SlateBlue gui=none term=reverse cterm=reverse
else
  colorscheme tokyonight
  hi Visual guibg=#FFFFFF guifg=SlateBlue gui=none
endif

highlight CursorLine term=bold cterm=bold guibg=Grey10
highlight Normal ctermbg=NONE guibg=NONE
highlight NonText ctermbg=NONE guibg=NONE
highlight SpecialKey ctermbg=NONE guibg=NONE
highlight EndOfBuffer ctermbg=NONE guibg=NONE
highlight Comment guifg=gray70
highlight rustCommentLineDoc guifg=gray70
highlight link CocMenuSel PmenuSel
highlight HopNextKey cterm=bold ctermfg=45 gui=bold guifg=#00dfff
highlight AnsiColor1 guifg=#e46876
highlight FgCocErrorFloatBgCocFloating guifg=#e46876
highlight Error guifg=#F7768E
highlight PreProc guifg=#FF9E64

" show highlight information under the cursor
function! s:get_syn_id(transparent)
    let synid = synID(line('.'), col('.'), 1)
    return a:transparent ? synIDtrans(synid) : synid
endfunction
function! s:get_syn_name(synid)
    return synIDattr(a:synid, 'name')
endfunction
function! s:get_highlight_info()
    execute "highlight " . s:get_syn_name(s:get_syn_id(0))
    execute "highlight " . s:get_syn_name(s:get_syn_id(1))
endfunction
command! HighlightInfo call s:get_highlight_info()
