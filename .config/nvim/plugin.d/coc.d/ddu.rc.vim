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
command! Diagnostics call ddu#start({
    \   'ui': 'ff',
    \   'sources': [{'name': 'coc-diagnostics'}],
    \ })
nmap <Leader>id :Diagnostics<CR>

let g:coc_enable_locationlist = 0
autocmd! User CocLocationsChange call ddu#start({
    \   'ui': 'ff',
    \   'sources': [{'name': 'coc-locations', 'params': {}}],
    \   'sourceOptions': {
    \     '_': {
    \       'matchers': ['matcher_fzf'],
    \     },
    \   },
    \ })
