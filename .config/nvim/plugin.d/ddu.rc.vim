call ddu#custom#patch_global(#{
      \  ui: 'ff',
      \  uiParams: #{
      \     ff: #{
      \       maxHighlightItems: 10000,
      \       previewSplit: "vertical",
      \       previewWidth: 110,
      \       winHeight: 45,
      \       autoAction: #{
      \         name: 'preview',
      \       },
      \       startAutoAction: v:true,
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
      \     lsp_documentSymbol: #{
      \       converters: [
      \           #{
      \             name: 'converter_lsp_symbol',
      \             params: #{
      \               iconMap: #{
      \                 File: " ",
      \                 Module: " ",
      \                 Namespace: " ",
      \                 Package: " ",
      \                 Class: " ",
      \                 Method: " ",
      \                 Property: " ",
      \                 Field: " ",
      \                 Constructor: " ",
      \                 Enum: " ",
      \                 Interface: " ",
      \                 Function: " ",
      \                 Variable: " ",
      \                 Constant: " ",
      \                 String: " ",
      \                 Number: " ",
      \                 Boolean: " ",
      \                 Array: " ",
      \                 Object: " ",
      \                 Key: " ",
      \                 Null: " ",
      \                 EnumMember: " ",
      \                 Struct: " ",
      \                 Event: " ",
      \                 Operator: " ",
      \                 TypeParameter: " ",
      \               },
      \           },
      \         }
      \       ],
      \     },
      \     lsp_workspaceSymbol: #{
      \       converters: [ 'converter_lsp_symbol' ],
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
      \    gitWorktree: #{
      \       defaultAction: 'open',
      \    },
      \   }
      \  })

call ddu#custom#patch_local('lsp:diagnostic', #{
    \   sources: [
    \     #{ name: 'lsp_diagnostic' }
    \   ],
    \   sourceOptions: #{
    \     lsp_diagnostic: #{
    \       converters: ['converter_lsp_diagnostic'],
    \     },
    \   }
    \ })
call ddu#custom#patch_local('git:worktree', #{
    \   sources: [
    \     #{ name: 'gitWorktree' }
    \   ],
    \ })


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
        \ <Cmd>call ddu#ui#do_action('toggleSelectItem')<CR>gj
  nnoremap <buffer><silent> i
        \ <Cmd>call ddu#ui#do_action('openFilterWindow')<CR>
  nnoremap <buffer><silent> x
        \ <Cmd>call ddu#ui#do_action('quit')<CR>
endfunction

nmap <silent><c-p> :call StartDduNoIgnore()<CR>
nmap <silent><Leader>pp :call StartDduIgnore()<CR>
nmap <silent><Leader>pt :call TabFind()<CR>
nmap <Leader>rr :RgFind ignore 
nmap <Leader>rn :RgFind noignore 
nmap <silent> <Leader>id <Cmd>call ddu#start(#{ name: 'lsp:diagnostic' })<CR>
nmap <silent> <Leader>gw <Cmd>call ddu#start(#{ name: 'git:worktree' })<CR>

function! StartDduNoIgnore() abort
  if &filetype == 'fern'
      call ReturnToPreviousBuffer()
      call ddu#start({})
    return
  endif
  call ddu#start({})
endfunction

function! StartDduIgnore() abort
  " :Copilot disable
  :call ddu#start(#{
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
  let escaped_text = escape(a:text, '()[]{}.*+?^$|\')
    :call ddu#start({'sources': [{'name': 'rg', 'params': {'input': escaped_text, 'args': ['--smart-case', "--column", "--no-heading", '--hidden', '--max-columns', '500']}}]})
endfunction

function! RgFindNoIgnore(text) abort
  let escaped_text = escape(a:text, '()[]{}.*+?^$|\')
  :call ddu#start({'sources': [{'name': 'rg', 'params': {'input': escaped_text, 'args': ['--smart-case', "--column", "--no-heading", '--hidden', '--glob', '!.git', '--color', 'never', "--no-ignore"]}}]})
endfunction

command! -range Ainavi :call ddu#start(#{
      \   sources: [#{name: 'ainavi'}],
      \   kindOptions: #{
      \     file: #{
      \       defaultAction: 'open',
      \     },
      \   }
      \ })

command! DduBuffer :call ddu#start(#{
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
  :call ddu#start({
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

nmap <silent><Leader>im :call ddu#start(#{
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


