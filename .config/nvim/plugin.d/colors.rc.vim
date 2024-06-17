set termguicolors

if has('nvim')
  colorscheme kanagawa
  highlight Visual guifg=#FFFFFF guibg=SlateBlue gui=none term=reverse cterm=reverse
else
  colorscheme tokyonight
  hi Visual guibg=#FFFFFF guifg=SlateBlue gui=none
endif

hi CursorLine term=bold cterm=bold guibg=Grey10
hi NonText ctermbg=NONE guibg=NONE
hi SpecialKey ctermbg=NONE guibg=NONE
hi EndOfBuffer ctermbg=NONE guibg=NONE
hi Comment guifg=gray70
hi rustCommentLineDoc guifg=gray70
hi link CocMenuSel PmenuSel
hi HopNextKey cterm=bold ctermfg=45 gui=bold guifg=#00dfff
hi AnsiColor1 guifg=#F7768E
hi FgCocErrorFloatBgCocFloating guifg=#F7768E
hi Error guifg=#F7768E
hi ErrorMsg guifg=#F7768E
hi PreProc guifg=#FF9E64
hi DiagnosticError guifg=#F7768E
hi DiagnosticSignError guifg=#F7768E
hi DiagnosticUnderlineError guifg=#F7768E
hi DiagnosticFloatingError guifg=#F7768E
hi NvimInternalError guifg=#F7768E
hi healthError guifg=#F7768E
hi DapUIWatchesError guifg=#F7768E
hi DapUIWatchesEmpty guifg=#F7768E
hi FloatShadowThrough cterm=bold gui=bold guifg=#938aa9 guibg=#16161d
hi FloatShadow cterm=bold gui=bold guifg=#938aa9 guibg=#16161d

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

augroup fidget-highlights
  autocmd!
  autocmd ColorScheme * highlight FidgetTitle guifg=#b48ead
  autocmd ColorScheme * highlight FidgetTask guifg=#d8dee9
augroup END
