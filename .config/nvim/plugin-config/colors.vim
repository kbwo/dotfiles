set termguicolors
let g:edge_style = 'neon'
let g:edge_transparent_background = 1

function! s:edge_custom() abort
  let l:palette = edge#get_palette('neon')
  call edge#highlight('ErrorMsg', ['#F7768E',   '203'], l:palette.none, 'bold,underline')
  call edge#highlight('SpellBad', l:palette.none, l:palette.none, 'undercurl', ['#F7768E',   '203'])
  call edge#highlight('Type', ['#F7768E',   '203'], l:palette.none, 'italic')
  call edge#highlight('Structure', ['#F7768E',   '203'], l:palette.none, 'italic')
  call edge#highlight('StorageClass', ['#F7768E',   '203'], l:palette.none, 'italic')
  call edge#highlight('Todo', ['#F7768E',   '203'], l:palette.none, 'italic')
  call edge#highlight('Red', ['#F7768E',   '203'], l:palette.none)
  call edge#highlight('RedItalic', ['#F7768E',   '203'], l:palette.none, 'italic')
  call edge#highlight('RedSign', ['#F7768E',   '203'], l:palette.none)
  call edge#highlight('ErrorFloat', ['#F7768E',   '203'], l:palette.bg2)
  call edge#highlight('TSDanger', l:palette.bg0, ['#F7768E',   '203'], 'bold')
  call edge#highlight('Lf_hl_match3', ['#F7768E',   '203'], l:palette.none, 'bold')
  call edge#highlight('ClapSelected', ['#F7768E',   '203'], l:palette.bg2, 'bold')
  call edge#highlight('ClapMatches1', ['#F7768E',   '203'], l:palette.bg2, 'bold')
  call edge#highlight('ClapNoMatchesFound', ['#F7768E',   '203'], l:palette.bg2, 'bold')
  call edge#highlight('BufferCurrentTarget', ['#F7768E',   '203'], l:palette.bg4, 'bold')
  call edge#highlight('UndotreeSavedBig', ['#F7768E',   '203'], l:palette.none, 'bold')
  call edge#highlight('markdownH2', ['#F7768E',   '203'], l:palette.none, 'bold')
  call edge#highlight('VimwikiHeader2', ['#F7768E',   '203'], l:palette.none, 'bold')
  call edge#highlight('rstStandaloneHyperlink', ['#F7768E',   '203'], l:palette.none, 'underline')
  call edge#highlight('rstHyperlinkTarget', ['#F7768E',   '203'], l:palette.none, 'underline')
  call edge#highlight('htmlH2', ['#F7768E',   '203'], l:palette.none, 'bold')
  call edge#highlight('helpHyperTextEntry', ['#F7768E',   '203'], l:palette.none, 'bold')
  call edge#highlight('DiffDelete', l:palette.none, ['#803d49',   '52'])

endfunction

augroup EdgeCustom
  autocmd!
  autocmd ColorScheme edge call s:edge_custom()
augroup END

colorscheme edge

if has('nvim')
  highlight Visual guifg=#FFFFFF guibg=SlateBlue gui=none term=reverse cterm=reverse
else
  hi Visual guibg=#FFFFFF guifg=SlateBlue gui=none
endif

highlight CursorLine term=bold cterm=bold guibg=Grey10
highlight Normal ctermbg=NONE guibg=NONE
highlight NonText ctermbg=NONE guibg=NONE
highlight SpecialKey ctermbg=NONE guibg=NONE
highlight EndOfBuffer ctermbg=NONE guibg=NONE
highlight Comment guifg=darkgray
