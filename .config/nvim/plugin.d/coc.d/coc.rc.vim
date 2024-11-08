let g:coc_global_extensions = [
      \'coc-emmet',
      \'coc-emoji',
      \'coc-calc',
      \'coc-css',
      \'coc-cssmodules',
      \'coc-db',
      \'coc-deno',
      \'coc-docker',
      \'coc-eslint',
      \'coc-flutter',
      \'coc-go',
      \'coc-html',
      \'coc-html-css-support',
      \'coc-java',
      \'coc-json',
      \'coc-lua',
      \'@yaegassy/coc-marksman',
      \'coc-tsdetect',
      \'coc-tsserver',
      \'@yaegassy/coc-intelephense',
      \'coc-prisma',
      \'coc-prettier',
      \'coc-basedpyright',
      \'coc-react-refactor',
      \'coc-rust-analyzer',
      \'coc-sh',
      \'coc-solargraph',
      \'coc-sql',
      \'coc-stylelint',
      \'coc-sourcekit',
      \'coc-styled-components',
      \'coc-svelte',
      \'@yaegassy/coc-tailwindcss3',
      \'coc-translator',
      \'coc-vimlsp',
      \'@yaegassy/coc-volar',
      \'coc-xml',
      \'coc-yaml',
      \'coc-yank',
      \]
nnoremap <Leader>c  :call CocActionAsync('highlight')<CR>
nmap <silent> <c-d> <Plug>(coc-definition)
nmap <silent> <Leader>ci <Plug>(coc-implementation)
" https://zenn.dev/skanehira/articles/2021-12-12-vim-coc-nvim-jump-split
" [
"   {"text": "(e)dit", "value": "edit"}
"   {"text": "(n)ew", "value": "new"}
" ]
" NOTE: text must contains '()' to detect input and its must be 1 character
function! ChoseAction(actions) abort
  echo join(map(copy(a:actions), { _, v -> v.text }), ", ") .. ": "
  let result = getcharstr()
  let result = filter(a:actions, { _, v -> v.text =~# printf(".*\(%s\).*", result)})
  return len(result) ? result[0].value : ""
endfunction

nmap <silent> <Leader>v<c-d> :call CocActionAsync('jumpDefinition', 'vsplit')<CR>
nmap <silent> <Leader>s<c-d> :call CocActionAsync('jumpDefinition', 'split')<CR>
nmap <silent> <Leader>t<c-d> :call CocActionAsync('jumpDefinition', 'tabe')<CR>
nmap <silent> <Leader>vci :call CocActionAsync('jumpImplementation', 'vsplit')<CR>
nmap <silent> <Leader>sci :call CocActionAsync('jumpImplementation', 'split')<CR>
nmap <silent> <Leader>tci :call CocActionAsync('jumpImplementation', 'tabe')<CR>
nmap <silent> <C-l> <Plug>(coc-diagnostic-next)
nmap <silent> <C-h> <Plug>(coc-diagnostic-prev)
nmap <Leader>ic <Plug>(coc-diagnostic-info)
nmap <Leader>iw  :CocDiagnostics<CR>
" nmap <Leader>id  :CocList diagnostics<CR>
nmap <silent> gr <Plug>(coc-references)
nmap <silent> ccn <Plug>(coc-rename)
nmap <silent> cca <Plug>(coc-codeaction)
nmap <silent> ccl <Plug>(coc-codeaction-line)
nmap <silent> czc <Plug>(coc-codeaction-cursor)
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

autocmd BufEnter * call CheckOutline()
function! CheckOutline() abort
  if &filetype ==# 'coctree' && winnr('$') == 1
    if tabpagenr('$') != 1
      close
    else
      bdelete
    endif
  endif
endfunction

nnoremap <silent><nowait> <Leader>is  :call ToggleOutline()<CR>
nnoremap <silent><nowait> <Leader>cs  :call ToggleOutline()<CR>
function! ToggleOutline() abort
  let winid = coc#window#find('cocViewId', 'OUTLINE')
  if winid == -1
    " call CocActionAsync('showOutline', 1)
    execute ':CocOutline'
  else
    call coc#window#close(winid)
  endif
endfunction

function! s:coc_tsdetect_buf_write_post() abort
  if !get(g:, 'coc_enabled', 0)
    return
  endif
  if exists('b:tsdetect_is_node') && !b:tsdetect_is_node
    CocCommand deno.cacheActiveDocument
  endif
endfunction

augroup my-coc-tsdetect
  autocmd!
  autocmd BufWritePost * call <SID>coc_tsdetect_buf_write_post()
augroup END
