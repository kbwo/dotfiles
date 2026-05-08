let g:fern#disable_default_mappings = 1
let g:fern#default_hidden = 1
let g:fern#comparators = get(g:, 'fern#comparators', {})

let g:previous_buffers = {}

function! s:fern_compare_path_mtime_desc(n1, n2) abort
  let l:time1 = has_key(a:n1, '_path') ? getftime(a:n1._path) : -1
  let l:time2 = has_key(a:n2, '_path') ? getftime(a:n2._path) : -1
  if l:time1 != l:time2
    return l:time1 > l:time2 ? -1 : 1
  endif
  return a:n1.label ==# a:n2.label ? 0 : a:n1.label ># a:n2.label ? 1 : -1
endfunction

function! s:fern_compare_modified_desc(n1, n2) abort
  let l:key1 = a:n1.__key
  let l:key2 = a:n2.__key
  let l:len1 = len(l:key1)
  let l:len2 = len(l:key2)

  if l:len1 ==# l:len2 && l:key1[:-2] ==# l:key2[:-2]
    return s:fern_compare_path_mtime_desc(a:n1, a:n2)
  endif

  let l:default_comparator = fern#comparator#default#new()
  return l:default_comparator.compare(a:n1, a:n2)
endfunction

function! s:fern_modified_desc_comparator_new() abort
  return {
        \ 'compare': funcref('s:fern_compare_modified_desc'),
        \}
endfunction

call extend(g:fern#comparators, {
      \ 'modified-desc': funcref('s:fern_modified_desc_comparator_new'),
      \})

function! s:fern_toggle_modified_desc_sort(helper) abort
  let l:enabled = getbufvar(a:helper.bufnr, 'fern_modified_desc_sort', 0)
  if l:enabled
    let g:fern#comparator = 'default'
    let a:helper.fern.comparator = fern#comparator#default#new()
    call setbufvar(a:helper.bufnr, 'fern_modified_desc_sort', 0)
  else
    let g:fern#comparator = 'modified-desc'
    let a:helper.fern.comparator = s:fern_modified_desc_comparator_new()
    call setbufvar(a:helper.bufnr, 'fern_modified_desc_sort', 1)
  endif
  let l:root = a:helper.sync.get_root_node()
  return a:helper.async.reload_node(l:root.__key)
        \.then({ -> a:helper.async.redraw() })
endfunction

function! s:fern_toggle_modified_desc_sort_mapping() abort
  return fern#helper#call(funcref('s:fern_toggle_modified_desc_sort'))
endfunction

function! SavePreviousBuffer()
  let current_winnr = win_getid()
  let current_file = expand('%:p')
  let g:previous_buffers[current_winnr] = current_file
endfunction

function! ReturnToPreviousBuffer()
  let current_winnr = win_getid()
  if has_key(g:previous_buffers, current_winnr)
    if g:previous_buffers[current_winnr] != ''
      execute 'edit ' . g:previous_buffers[current_winnr]
    else
      enew
      setlocal buftype=nofile
      setlocal bufhidden=wipe
      setlocal noswapfile
      setlocal nobuflisted
      setlocal nomodified
    endif
    call remove(g:previous_buffers, current_winnr)
  else
    execute 'Back'
  endif
endfunction

" ~/.vim/fern-toggle.vim
function! s:git_fern() abort
  call SavePreviousBuffer()
  let git_root = FindNearestGitRoot()
  execute 'Fern ' . git_root . ' -reveal=% -stay'
endfunction


nnoremap <silent> <C-n> :call <SID>git_fern()<CR>
nmap <silent> <c-w>c :call SavePreviousBuffer()<CR>:Fern %:h -reveal=% -stay<CR>


function! FernInit() abort
  nmap <silent><buffer> <c-n> :Fern .<CR>
  nmap <silent><buffer> <Leader>ss <Plug>(fern-action-open:split)
  nmap <silent><buffer> <Leader>vv <Plug>(fern-action-open:vsplit)
  nmap <silent><buffer> <Leader>tt <Plug>(fern-action-open:tabedit)
  nmap <silent><buffer> D <Plug>(fern-action-new-dir)
  nmap <silent><buffer> ! <Plug>(fern-action-hidden:toggle)
  nmap <silent><buffer> m <Plug>(fern-action-mark:toggle)gj
  nmap <silent><buffer> c <Plug>(fern-action-clipboard-copy)
  nmap <silent><buffer> <Leader>m <Plug>(fern-action-clipboard-move)
  nmap <silent><buffer> p <Plug>(fern-action-clipboard-paste)
  nmap <silent><buffer> M <Plug>(fern-action-new-file)
  nmap <silent><buffer> <cr> <Plug>(fern-action-open-or-enter)
  nmap <buffer><expr>
	      \ <Plug>(fern-my-open-or-expand-or-collapse)
	      \ fern#smart#leaf(
	      \   "<Plug>(fern-action-open)",
	      \   "<Plug>(fern-action-expand)",
	      \   "<Plug>(fern-action-collapse)",
	      \ )
  nmap <silent><buffer> o <Plug>(fern-my-open-or-expand-or-collapse)
  nmap <silent><buffer> <C-l> <Plug>(fern-action-reload)
  nmap <silent><buffer> rr <Plug>(fern-action-rename)
  nmap <silent><buffer> sm :<C-u>call <SID>fern_toggle_modified_desc_sort_mapping()<CR>
  nmap <silent><buffer> yy <Plug>(fern-action-yank)
  nmap <silent><buffer> dl <Plug>(fern-action-remove)
  nmap <silent><buffer> cd <Plug>(fern-action-tcd)
  nmap <silent><buffer> < <Plug>(fern-action-leave)
  nmap <silent><buffer> > <Plug>(fern-action-open-or-enter)
  nmap <silent><buffer> x :call ReturnToPreviousBuffer()<CR>
  nmap <silent><buffer> B :Back<CR>
  nmap <silent><buffer> R <Plug>(fern-action-redraw)
  nmap <silent><buffer> g? <Plug>(fern-action-help)
endfunction

augroup FernEvents
  autocmd!
  autocmd FileType fern call FernInit()
augroup END
