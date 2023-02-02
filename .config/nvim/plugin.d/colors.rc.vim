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
highlight Error guifg=#e46876
