let g:coc_global_extensions = [
      \'coc-angular',
      \'@yaegassy/coc-ansible',
      \'coc-biome',
      \'coc-emmet',
      \'coc-emoji',
      \'coc-calc',
      \'coc-clangd',
      \'coc-conjure',
      \'coc-css',
      \'coc-cssmodules',
      \'coc-db',
      \'coc-deno',
      \'coc-docker',
      \'coc-eslint',
      \'coc-flutter',
      \'coc-go',
      \'coc-highlight',
      \'coc-html',
      \'coc-html-css-support',
      \'coc-java',
      \'coc-json',
      \'coc-lua',
      \'coc-tsserver',
      \'coc-pairs',
      \'@yaegassy/coc-intelephense',
      \'coc-post',
      \'coc-prisma',
      \'coc-prettier',
      \'coc-pyright',
      \'coc-react-refactor',
      \'coc-rust-analyzer',
      \'coc-sh',
      \'coc-solargraph',
      \'coc-sql',
      \'coc-stylelint',
      \'coc-sourcekit',
      \'coc-styled-components',
      \'coc-svelte',
      \'coc-tailwindcss',
      \'coc-translator',
      \'coc-vimlsp',
      \'@yaegassy/coc-volar',
      \'coc-xml',
      \'coc-yaml',
      \'coc-yank',
      \'coc-zig',
      \'coc-zls',
      \]
nnoremap <Leader>c  :call CocActionAsync('highlight')<CR>
nmap <silent> <c-d> <Plug>(coc-definition)
nmap <silent> <Leader>v<c-d> :call CocAction('jumpDefinition', 'vsplit')<CR>
nmap <silent> <Leader>s<c-d> :call CocAction('jumpDefinition', 'split')<CR>
nmap <silent> <Leader>t<c-d> :call CocAction('jumpDefinition', 'tabe')<CR>
nmap <silent> <C-l> <Plug>(coc-diagnostic-next)
nmap <silent> <C-h> <Plug>(coc-diagnostic-prev)
nmap <Leader>ic <Plug>(coc-diagnostic-info)
nmap <Leader>iw  :CocDiagnostics<CR>
nmap <Leader>is  :CocList outline<CR>
nmap <silent> gr <Plug>(coc-references)
nmap <silent> ccn <Plug>(coc-rename)
nmap <silent> cca <Plug>(coc-codeaction)
nmap <silent> ccl <Plug>(coc-codeaction-line)
nmap <silent> ccc <Plug>(coc-codeaction-cursor)
nmap <silent> csd :call <SID>show_documentation()<CR>
vmap <silent><leader>sc <Plug>(coc-codeaction-selected)
command! -nargs=0 CocFormat :call CocActionAsync('format')
command! -nargs=0 Snip :CocCommand snippets.openSnippetFiles
nmap <silent>ccr :CocRestart<CR>
nnoremap <silent> cj <Plug>(coc-float-jump)

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocActionAsync('doHover')
  endif
endfunction

nnoremap <nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
nnoremap <nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
" highlight CocUnusedHighlight guifg=#ad8ee6 gui=bold

" hi link CocUnusedHighlight CocUnderline guifg=darkgray


" autocmd CursorHold * silent call CocActionAsync('highlight')

nmap tr <Plug>(coc-translator-p)
vmap tr <Plug>(coc-translator-pv)

au FileType vue let b:coc_root_patterns = ['.git', '.env', 'package.json', 'tsconfig.json', 'jsconfig.json', 'vite.config.ts', 'nuxt.config.ts']
au FileType rust nmap gd :CocCommand rust-analyzer.openDocs<CR>

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction

inoremap <silent><expr> <C-n> coc#pum#visible() ? coc#pum#next(1) : "\<C-n>"
inoremap <silent><expr> <C-p> coc#pum#visible() ? coc#pum#prev(1) : "\<C-p>"

inoremap <silent><expr> <TAB>
\ coc#pum#visible() ? coc#pum#next(1):
\ <SID>check_back_space() ? "\<Tab>" :
\ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

set pumheight=30
