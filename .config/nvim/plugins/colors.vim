set termguicolors
colorscheme tokyonight

let g:airline_theme = "tokyonight"
let g:airline#extensions#syntastic#enabled = 1
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline_skip_empty_sections = 1
let g:airline#extensions#virtualenv#enabled = 1
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif

"左側に使用されるセパレータ
let g:airline_left_sep = '>'
"右側に使用されるセパレータ
let g:airline_right_sep = '<'
let g:airline_symbols.crypt = '🔒'		"暗号化されたファイル
let g:airline_symbols.linenr = 'L'			"行
let g:airline_symbols.maxlinenr = '㏑'		"最大行
let g:airline_symbols.branch = 'B'		"gitブランチ
let g:airline_symbols.paste = 'P'			"ペーストモード
let g:airline_symbols.spell = 'C'			"スペルチェック
let g:airline_symbols.notexists = 'U'		"gitで管理されていない場合
let g:airline_symbols.whitespace = 'E'

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
