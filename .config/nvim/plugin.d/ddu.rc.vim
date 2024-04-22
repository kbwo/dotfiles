let g:ddu_source_lsp_clientName = 'coc.nvim'
call ddu#custom#patch_global(#{
      \  ui: 'ff',
      \  uiParams: #{
      \     ff: #{
      \       startAutoAction: v:true
      \     },
      \  },
      \  sources: [
      \    {
      \      'name': 'file_external', 
      \      'params': {
      \      'cmd': ['rg', '--files', '--hidden', '--glob', '!.git', '--color', 'never']
      \      }
      \    }
      \  ],
      \   sourceOptions: #{
      \     _: #{
      \       matchers: ['matcher_fzf'],
      \     },
      \   },
      \   kindOptions: #{
      \     file: #{
      \       defaultAction: 'open',
      \     },
      \   lsp: #{
      \       defaultAction: 'open',
      \    },
      \    lsp_codeAction: #{
      \       defaultAction: 'apply',
      \    },
      \   }
      \  })

autocmd FileType ddu-ff call s:ddu_my_settings()
function! s:ddu_my_settings() abort
  nnoremap <buffer><silent> <CR>
        \ <Cmd>call ddu#ui#do_action('itemAction')<CR>
  nnoremap <buffer><silent> <Leader>vv
        \ <Cmd>call ddu#ui#do_action('itemAction', {'params': {'command': 'vsplit'}})<CR>
  nnoremap <buffer><silent> <Leader>ss
        \ <Cmd>call ddu#ui#do_action('itemAction', {'params': {'command': 'split'}})<CR>
  nnoremap <buffer><silent> <Leader>tt
        \ <Cmd>call ddu#ui#do_action('itemAction', {'params': {'command': 'tabnew'}})<CR>
  nnoremap <buffer><silent> o
        \ <Cmd>call ddu#ui#do_action('expandItem', {'params': {'mode': 'toggle'}})<CR>
  nnoremap <buffer><silent> p
        \ <Cmd>call ddu#ui#do_action('preview')<CR>
  nnoremap <buffer><silent> m
        \ <Cmd>call ddu#ui#do_action('toggleSelectItem')<CR>
  nnoremap <buffer><silent> i
        \ <Cmd>call ddu#ui#do_action('openFilterWindow')<CR>
  nnoremap <buffer><silent> x
        \ <Cmd>call ddu#ui#do_action('quit')<CR>
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

nmap <silent><c-p> :call StartDduNoIgnore()<CR>
nmap <silent><Leader>p :call StartDduIgnore()<CR>
nmap <Leader>r :RgFind ignore 
nmap <Leader><c-r> :RgFind noignore 


command! Symbols call ddu#start({
    \   'ui': 'ff',
    \   'sources': [{'name': 'coc-symbols', 'params': {'symbols': g:CocAction('documentSymbols'), 'filePath': expand('%:p')}}],
    \   'kindOptions': {
    \     'file': {
    \       'defaultAction': 'open',
    \     },
    \   }
    \ })
nmap csm :Symbols<CR>

let g:coc_enable_locationlist = 0
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

function! StartDduNoIgnore() abort
  " :Copilot disable
  call ddu#start({})
endfunction

function! StartDduIgnore() abort
  " :Copilot disable
  call ddu#start(#{
        \  ui: 'ff',
        \  sources: [
        \    #{
        \    name: 'file_external', 
        \    params: {
        \        'cmd': ['rg', '--files', '--hidden','--no-ignore', '--color', 'never']
        \      }
        \    }
        \  ],
        \   sourceOptions: #{
        \     _: #{
        \       matchers: ['matcher_fzf'],
        \     },
        \   },
        \   kindOptions: #{
        \     file: #{
        \       defaultAction: 'open',
        \     },
        \   }
        \  })
endfunction

function! RgFindIgnore(text) abort
  echom a:text
  call ddu#start({'sources': [{'name': 'rg', 'params': {'input': a:text, 'args': ['--smart-case', "--column", "--no-heading", '--hidden', '--glob', '!.git', '--color', 'never']}}]})
endfunction

function! RgFindNoIgnore(text) abort
  call ddu#start({'sources': [{'name': 'rg', 'params': {'input': a:text, 'args': ['--smart-case', "--column", "--no-heading", '--hidden', '--glob', '!.git', '--color', 'never', "--no-ignore"]}}]})
endfunction

command! DduBuffer call ddu#start(#{
      \   ui: 'ff',
      \   sources: [#{name: 'buffer'}],
      \   kindOptions: #{
      \     file: #{
      \       defaultAction: 'open',
      \     },
      \   }
      \ })

function! RgFind(type, ...)
  let text = ''
  for arg in a:000
    if text != ''
      let text .= ' '
    endif
    let text .= arg
  endfor
  if a:type == 'ignore'
    call RgFindIgnore(text)
  else
    call RgFindNoIgnore(text)
  endif
endfunction

command! -nargs=* RgFind call RgFind(<f-args>)
