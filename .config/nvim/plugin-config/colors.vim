set termguicolors
colorscheme tokyonight

if has('nvim')
  highlight Visual guifg=#FFFFFF guibg=SlateBlue gui=none term=reverse cterm=reverse
else
  hi Visual guibg=#FFFFFF guifg=SlateBlue gui=none
endif

highlight CursorLine term=bold cterm=bold guibg=Grey40
highlight Normal ctermbg=NONE guibg=NONE
highlight NonText ctermbg=NONE guibg=NONE
highlight SpecialKey ctermbg=NONE guibg=NONE
highlight EndOfBuffer ctermbg=NONE guibg=NONE
highlight Comment guifg=darkgray