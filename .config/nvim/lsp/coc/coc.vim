let g:coc_global_extensions = [
      \'coc-angular',
      \'@yaegassy/coc-ansible',
      \'coc-json',
      \'coc-flutter',
      \'coc-tsserver',
      \'coc-go',
      \'coc-git',
      \'coc-highlight',
      \'coc-java',
      \'coc-phpls',
      \'coc-python',
      \'coc-rust-analyzer',
      \'coc-stylelint',
      \'coc-sql',
      \'coc-vimlsp',
      \'coc-xml',
      \'coc-yaml',
      \'coc-prettier',
      \'coc-html',
      \'coc-solargraph',
      \'coc-prisma',
      \'coc-sh',
      \'coc-yank',
      \'coc-eslint',
      \'coc-pairs',
      \'coc-css',
      \'coc-calc',
      \'coc-sh',
      \'coc-sourcekit',
      \'coc-tailwindcss',
      \'coc-cssmodules',
      \'coc-vetur',
      \'coc-clangd',
      \'coc-deno',
      \'coc-emmet',
      \'coc-post',
      \'coc-docker',
      \'coc-react-refactor',
      \'coc-styled-components',
      \'coc-docker',
      \'coc-metals',
      \'coc-snippets',
      \'coc-just-complete',
      \'coc-dash-complete',
      \'coc-dot-complete',
      \'coc-html-css-support',
      \'coc-tabnine',
      \'@yaegassy/coc-volar',
      \'coc-conjure',
      \'coc-db'
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
nmap <silent><leader>sc <Plug>(coc-codeaction-selected)
nmap <silent>csb :Denite coc-symbols<CR>
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
