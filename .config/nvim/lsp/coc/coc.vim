let g:coc_global_extensions = [
      \'coc-json',
      \'coc-flutter',
      \'coc-tsserver',
      \'coc-go',
      \'coc-git',
      \'coc-highlight',
      \'coc-java',
      \'coc-markdownlint',
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
      \'coc-flow',
      \'coc-snippets',
      \'coc-db'
      \]
nnoremap <Leader>c  :call CocActionAsync('highlight')<CR>
nmap <silent> <C-d> <Plug>(coc-definition)
nmap <silent> <Leader>v<C-d> :call CocAction('jumpDefinition', 'vsplit')<CR>
nmap <silent> <C-l> <Plug>(coc-diagnostic-next)
nmap <Leader>ic <Plug>(coc-diagnostic-info)
nmap <Leader>iw  :CocDiagnostics<CR>
nmap <Leader>is  :CocList outline<CR>
nmap <silent> gr <Plug>(coc-references)
nmap <silent> ccn <Plug>(coc-rename)
nmap <silent> cca <Plug>(coc-codeaction)
nmap <silent> ccl <Plug>(coc-codeaction-line)
nmap <silent> csd :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

let g:coc_enable_locationlist = 0
autocmd! User CocLocationsChange Denite -smartcase -auto-action=preview coc-locations
command! -nargs=0 Prettier :CocCommand prettier.formatFile
highlight CocUnusedHighlight guifg=#ad8ee6 gui=bold

" hi link CocUnusedHighlight CocUnderline guifg=darkgray


autocmd CursorHold * silent call CocActionAsync('highlight')
