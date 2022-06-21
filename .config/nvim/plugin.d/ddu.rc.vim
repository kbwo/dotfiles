call ddu#custom#patch_global({
  \  'ui': 'ff',
  \  'sources': [
    \  {'name': 'file_external', 
    \  'params': 
    \  {
        \  'cmd': ['rg', '--files', '--hidden', '--glob', '!.git', '--color', 'never']
      \  }
    \  }
  \  ],
  \   'sourceOptions': {
  \     '_': {
  \       'matchers': ['matcher_fzf'],
  \     },
  \   },
  \   'kindOptions': {
  \     'file': {
  \       'defaultAction': 'open',
  \     },
  \   }
\  })

autocmd FileType ddu-ff call s:ddu_my_settings()
function! s:ddu_my_settings() abort
  nnoremap <buffer><silent> <CR>
        \ <Cmd>call ddu#ui#ff#do_action('itemAction')<CR>
  nnoremap <buffer><silent> <Leader>v
        \ <Cmd>call ddu#ui#ff#do_action('itemAction', {'params': {'command': 'vsplit'}})<CR>
  nnoremap <buffer><silent> <Leader>s
        \ <Cmd>call ddu#ui#ff#do_action('itemAction', {'params': {'command': 'split'}})<CR>
  nnoremap <buffer><silent> <Leader>t
        \ <Cmd>call ddu#ui#ff#do_action('itemAction', {'params': {'command': 'tabnew'}})<CR>
  nnoremap <buffer><silent> m
        \ <Cmd>call ddu#ui#ff#do_action('toggleSelectItem')<CR>
  nnoremap <buffer><silent> i
        \ <Cmd>call ddu#ui#ff#do_action('openFilterWindow')<CR>
  nnoremap <buffer><silent> q
        \ <Cmd>call ddu#ui#ff#do_action('quit')<CR>
endfunction

autocmd FileType ddu-ff-filter call s:ddu_filter_my_settings()

function! s:ddu_filter_my_settings() abort
  " https://github.com/Shougo/ddu-ui-ff/issues/44
  inoremap <buffer><silent> <CR>
      \ <Esc><Cmd>close<CR>
      \<Cmd>call win_gotoid(g:ddu#ui#ff#_filter_parent_winid)<CR>
  nnoremap <buffer><silent> <CR>
  \ <Cmd>close<CR>
  nnoremap <buffer><silent> q
  \ <Cmd>close<CR>
endfunction

nmap <silent><c-p> :call ddu#start({})<CR>
nmap <silent><Leader>r :call RgFindIgnore()<CR>
nmap <silent><Leader><c-r> :call RgFindNoIgnore()<CR>
nmap <silent><Leader>p :call ddu#start({
  \  'ui': 'ff',
  \  'sources': [
    \  {'name': 'file_external', 
    \  'params': 
    \  {
        \  'cmd': ['rg', '--files', '--hidden','--no-ignore', '--color', 'never']
      \  }
    \  }
  \  ],
  \   'sourceOptions': {
  \     '_': {
  \       'matchers': ['matcher_fzf'],
  \     },
  \   },
  \   'kindOptions': {
  \     'file': {
  \       'defaultAction': 'open',
  \     },
  \   }
\  })<CR>

function! RgFindIgnore() abort
  let word = input("search word: ")
  call ddu#start({'sources': [{'name': 'rg', 'params': {'input': word, 'args': ['--smart-case', "--column", "--no-heading", '--hidden', '--glob', '!.git', '--color', 'never', '--']}}]})
endfunction

function! RgFindNoIgnore() abort
  let word = input("search word: ")
  call ddu#start({'sources': [{'name': 'rg', 'params': {'input': word, 'args': ['--smart-case', "--column", "--no-heading", '--hidden', '--glob', '!.git', '--color', 'never', "--no-ignore", '--']}}]})
endfunction

command! Symbols call ddu#start({
    \   'ui': 'ff',
    \   'sources': [{'name': 'coc-symbols', 'params': {'symbols': g:CocAction('documentSymbols')}}],
    \   'kindOptions': {
    \     'file': {
    \       'defaultAction': 'open',
    \     },
    \   }
    \ })

autocmd! User CocLocationsChange call ddu#start({
    \   'ui': 'ff',
    \   'sources': [{'name': 'coc-locations', 'params': {}}],
    \   'sourceOptions': {
    \     '_': {
    \       'matchers': ['matcher_fzf'],
    \     },
    \   },
    \   'kindOptions': {
    \     'file': {
    \       'defaultAction': 'open',
    \     },
    \   }
    \ })

command! DduBuffer call ddu#start({
    \   'ui': 'ff',
    \   'sources': [{'name': 'buffer'}],
    \   'sourceOptions': {
    \     '_': {
    \       'matchers': ['matcher_fzf'],
    \     },
    \   },
    \   'kindOptions': {
    \     'file': {
    \       'defaultAction': 'open',
    \     },
    \   }
    \ })
