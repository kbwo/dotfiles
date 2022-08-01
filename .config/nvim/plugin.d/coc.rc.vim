let g:coc_global_extensions = [
      \'coc-angular',
      \'@yaegassy/coc-ansible',
      \'coc-emmet',
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
      \'coc-git',
      \'coc-go',
      \'coc-highlight',
      \'coc-html',
      \'coc-html-css-support',
      \'coc-java',
      \'coc-json',
      \'coc-lua',
      \'coc-metals',
      \'coc-tsserver',
      \'coc-pairs',
      \'coc-phpls',
      \'coc-post',
      \'coc-prettier',
      \'coc-prisma',
      \'coc-python',
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
      \]
nnoremap <Leader>c  :call CocActionAsync('highlight')<CR>
nmap <silent> <C-d> <Plug>(coc-definition)
nmap <silent> <Leader>v<C-d> :call CocAction('jumpDefinition', 'vsplit')<CR>
nmap <silent> <Leader>s<C-d> :call CocAction('jumpDefinition', 'split')<CR>
nmap <silent> <Leader>t<C-d> :call CocAction('jumpDefinition', 'tabe')<CR>
nmap <silent> <C-l> <Plug>(coc-diagnostic-next)
nmap <silent> <C-h> <Plug>(coc-diagnostic-prev)
nmap <Leader>ic <Plug>(coc-diagnostic-info)
nmap <Leader>iw  :CocDiagnostics<CR>
nmap <Leader>is  :CocList outline<CR>
nmap <silent> gr <Plug>(coc-references)
nmap <silent> ccn <Plug>(coc-rename)
nmap <silent> cca <Plug>(coc-codeaction)
nmap <silent> ccl <Plug>(coc-codeaction-line)
nmap <silent> csd :call <SID>show_documentation()<CR>
vmap <silent><leader>sc <Plug>(coc-codeaction-selected)
command! -nargs=0 CocFormat :call CocActionAsync('format')
nmap <silent>ccr :CocRestart<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

let g:coc_enable_locationlist = 0
command! -nargs=0 Prettier :CocCommand prettier.formatFile

nnoremap <nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
nnoremap <nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
inoremap <nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1, 1)\<cr>" : "\<Right>"
inoremap <nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0, -1)\<cr>" : "\<Left>"
" highlight CocUnusedHighlight guifg=#ad8ee6 gui=bold

" hi link CocUnusedHighlight CocUnderline guifg=darkgray


autocmd CursorHold * silent call CocActionAsync('highlight')

nmap tr <Plug>(coc-translator-p)
vmap tr <Plug>(coc-translator-pv)

au FileType vue let b:coc_root_patterns = ['.git', '.env', 'package.json', 'tsconfig.json', 'jsconfig.json', 'vite.config.ts', 'nuxt.config.ts']

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction

inoremap <silent><expr> <C-n> coc#pum#visible() ? coc#pum#prev(1) : "\<C-n>"
inoremap <silent><expr> <C-p> coc#pum#visible() ? coc#pum#next(1) : "\<C-p>"

inoremap <silent><expr> <TAB>
\ coc#pum#visible() ? coc#pum#next(1):
\ <SID>check_back_space() ? "\<Tab>" :
\ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
