call ddu#custom#patch_global(#{
      \  ui: 'ff',
      \  uiParams: #{
      \     ff: #{
      \       maxHighlightItems: 10000,
      \       previewSplit: "vertical",
      \       winHeight: 45,
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

" autocmd sometimes disables syntax highlight
" func AutoPreview()
"   let current_mode = mode()
"   let filetype = &filetype
"   if current_mode == 'n'
"     if filetype == 'ddu-ff'
"       call ddu#ui#do_action('preview')
"     endif
"   endif
" endfunc

func StartHandler(timer)
  call ddu#start({})
endfunc

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
        \ <Cmd>call ddu#ui#do_action('toggleSelectItem')<CR>gj
  nnoremap <buffer><silent> i
        \ <Cmd>call ddu#ui#do_action('openFilterWindow')<CR>
  nnoremap <buffer><silent> x
        \ <Cmd>call ddu#ui#do_action('quit')<CR>
  nnoremap <buffer><silent> h
        \ h<Cmd>call ddu#ui#do_action('preview')<CR>
  nnoremap <buffer><silent> l
        \ l<Cmd>call ddu#ui#do_action('preview')<CR>
  nnoremap <buffer><silent> j
        \ gj<Cmd>call ddu#ui#do_action('preview')<CR>
  nnoremap <buffer><silent> k
        \ gk<Cmd>call ddu#ui#do_action('preview')<CR>
  nnoremap <buffer><silent> w
        \ w<Cmd>call ddu#ui#do_action('preview')<CR>
  nnoremap <buffer><silent> H
        \ H<Cmd>call ddu#ui#do_action('preview')<CR>
  nnoremap <buffer><silent> L
        \ L<Cmd>call ddu#ui#do_action('preview')<CR>
  nnoremap <buffer><silent> gg
        \ gg<Cmd>call ddu#ui#do_action('preview')<CR>
  nnoremap <buffer><silent> G
        \ G<Cmd>call ddu#ui#do_action('preview')<CR>
  nnoremap <buffer><silent> <C-f>
        \ <C-f><Cmd>call ddu#ui#do_action('preview')<CR>
  nnoremap <buffer><silent> <C-b>
        \ <C-b><Cmd>call ddu#ui#do_action('preview')<CR>
  xnoremap <buffer><silent> <ESC>
        \ <ESC><Cmd>call ddu#ui#do_action('preview')<CR>

  call timer_start(500, {t -> ddu#ui#do_action('preview') })
endfunction

autocmd BufEnter * if &filetype == 'ddu-ff' | call timer_start(500, {t -> ddu#ui#do_action('preview') }) | endif


nmap <silent><c-p> :call StartDduNoIgnore()<CR>
nmap <silent><Leader>pp :call StartDduIgnore()<CR>
nmap <silent><Leader>pt :call TabFind()<CR>
nmap <Leader>rr :RgFind ignore 
nmap <Leader>rn :RgFind noignore 

function! StartDduNoIgnore() abort
  if &filetype == 'fern'
    call timer_start(500, 'StartHandler')
    return
  endif
  call StartHandler(0)
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
      \   sources: [#{name: 'buffer'}],
      \   kindOptions: #{
      \     file: #{
      \       defaultAction: 'open',
      \     },
      \   }
      \ })

nmap <Leader>b :DduBuffer<CR>

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

function TabFind() abort
  call ddu#start({
	   \ 'uiParams': {
	   \     'ff': {
	   \         'autoAction': { 
	   \             'name': 'preview',
	   \             'params': { 'border': ['.'], 'focusBorder': ['+', '-', '+', '\|'] }
	   \         },
	    \       'previewHeight': 30,
	   \     },
	   \ },
     \ 'sources': [{'name': 'window', 'params': {'format': 'tab%tn: %w:%wi'}}],
     \ 'kindOptions': {
      \     'window': {
      \       'defaultAction': 'open',
      \     },
      \   }
	   \ })
endfunction

nmap <silent><c-d> :call ddu#start(#{
      \  ui: 'ff',
      \ sync: v:true,
      \ sources: [#{
      \   name: 'lsp_definition',
      \ }],
      \})<CR>
nmap <silent>gr :call ddu#start(#{
      \  ui: 'ff',
      \ sync: v:true,
      \ sources: [#{
      \   name: 'lsp_references',
      \ }],
      \})<CR>
nmap <silent>csm :call ddu#start(#{
      \  ui: 'ff',
      \ sync: v:true,
      \  uiParams: #{
      \     ff: #{
      \       displayTree: v:true
      \     },
      \  },
      \ sources: [#{
      \   name: 'lsp_documentSymbol',
      \ }],
      \ sourceOptions: #{
      \   lsp: #{
      \     volatile: v:true,
      \   },
      \ },
      \})<CR>
