call ddc#custom#patch_global('ui', 'native')
call ddc#custom#patch_global('backspaceCompletion', v:true)

call ddc#custom#patch_global('sources', [ 'lsp', 'file', 'buffer', 'around'])

call ddc#custom#patch_global('sourceOptions', {
    \   '_': {
    \     'matchers': ['matcher_fuzzy'],
    \     'sorters': ['sorter_fuzzy'],
    \     'converters': ['converter_fuzzy'],
    \     'minAutoCompleteLength': 1,
    \     'ignoreCase': v:true,
    \   },
    \   'around': {
    \     'mark': 'A'
    \   },
    \   'file': {
    \     'mark': 'F',
    \     'isVolatile': v:true,
    \     'forceCompletionPattern': '\S/\S*',
    \   },
    \   'lsp': {
    \     'mark': 'lsp',
    \     'forceCompletionPattern': '\.\w*|:\w*|->\w*',
    \     'maxItems': 15,
    \   },
    \   'buffer': {
    \     'mark': 'B',
    \     'maxItems': 5,
    \  },
    \   'yank': {'mark': 'Y'},
    \   'input': {
    \     'mark': 'input',
    \     'isVolatile': v:true,
    \   },
    \})

call ddc#custom#patch_filetype(
    \ ['ps1', 'dosbatch', 'autohotkey', 'registry'], {
    \ 'sourceOptions': {
    \   'file': {
    \     'forceCompletionPattern': '\S\/\S*',
    \   },
    \ },
    \ 'sourceParams': {
    \   'file': {
    \     'mode': 'unix',
    \   },
    \ }})

call ddc#custom#patch_global('sourceParams', #{
      \   lsp: #{
      \     snippetEngine: denops#callback#register({
      \           body -> vsnip#anonymous(body)
      \     }),
      \     enableAdditionalTextEdit: v:true,
      \     enableDisplayDetail: v:true,
      \     enableMatchLabel: v:true,
      \     enableResolveItem: v:true
      \   }
      \ })

call ddc#custom#patch_global('sourceParams', {
    \ 'buffer': {
    \   'requireSameFiletype': v:false,
    \   'limitBytes': 5000000,
    \   'fromAltBuf': v:true,
    \   'forceCollect': v:true,
    \ },
    \ })


call ddc#custom#patch_global('filterParams', {
    \   'matcher_fuzzy': {
    \     'splitMode': 'word'
    \   }
    \ })

call ddc#custom#patch_filetype(['sql', 'mysql', 'plsql'], 'sources', 'dadbod-completion')
call ddc#custom#patch_filetype(['sql', 'mysql', 'plsql'], 'sourceOptions', {
\ 'dadbod-completion': {
\   'mark': 'DB',
\   'isVolatile': v:true,
\ },
\ })

call ddc#enable()

" <TAB>: completion.
inoremap <expr> <TAB>
    \ pumvisible() ? '<C-n>' :
    \ (col('.') <= 1 <Bar><Bar> getline('.')[col('.') - 2] =~# '\s') ?
    \ '<TAB>' : ddc#map#manual_complete()

" <S-TAB>: completion back.
inoremap <expr> <S-TAB>  pumvisible() ? '<C-p>' : '<C-h>'

call popup_preview#enable()
