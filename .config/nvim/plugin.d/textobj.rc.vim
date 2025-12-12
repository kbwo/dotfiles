vmap v <Plug>(expand_region_expand)
vmap <A-v> <Plug>(expand_region_shrink)

" md-textobj.vim - Custom text object for markdown sections between separators
" Requires: vim-textobj-user

" Check if a line is a markdown separator (---, ***, ___)
function! s:is_separator(line) abort
  let l:stripped = substitute(a:line, '^\s*\|\s*$', '', 'g')
  " Check for 3+ consecutive -, *, or _
  if l:stripped =~# '^-\{3,}$'
    return 1
  endif
  if l:stripped =~# '^_\{3,}$'
    return 1
  endif
  " For asterisks, check character by character to avoid regex issues
  if len(l:stripped) >= 3 && l:stripped[0] ==# '*'
    let l:all_asterisk = 1
    for l:i in range(len(l:stripped))
      if l:stripped[l:i] !=# '*'
        let l:all_asterisk = 0
        break
      endif
    endfor
    if l:all_asterisk
      return 1
    endif
  endif
  return 0
endfunction

" Find the range between separators
" Returns [start_line, end_line] or [0, 0] if not found
function! s:find_section_range() abort
  let l:current_line = line('.')
  let l:last_line = line('$')

  " Search upward for previous separator
  let l:upper_sep = 0
  let l:lnum = l:current_line - 1
  while l:lnum >= 1
    if s:is_separator(getline(l:lnum))
      let l:upper_sep = l:lnum
      break
    endif
    let l:lnum -= 1
  endwhile

  " Search downward for next separator
  let l:lower_sep = 0
  let l:lnum = l:current_line + 1
  while l:lnum <= l:last_line
    if s:is_separator(getline(l:lnum))
      let l:lower_sep = l:lnum
      break
    endif
    let l:lnum += 1
  endwhile

  " Both separators must exist
  if l:upper_sep == 0 || l:lower_sep == 0
    return [0, 0]
  endif

  " Range is between separators (exclusive)
  let l:start_line = l:upper_sep + 1
  let l:end_line = l:lower_sep - 1

  " Check if there's actual content
  if l:start_line > l:end_line
    return [0, 0]
  endif

  return [l:start_line, l:end_line]
endfunction

" Select inner section (between separators, excluding blank lines at edges)
function! Textobj_mdsection_select_i() abort
  let l:result = s:find_section_range()
  if l:result[0] == 0
    return 0
  endif

  let [l:start_line, l:end_line] = l:result

  " Skip leading blank lines
  while l:start_line <= l:end_line && getline(l:start_line) =~# '^\s*$'
    let l:start_line += 1
  endwhile

  " Skip trailing blank lines
  while l:end_line >= l:start_line && getline(l:end_line) =~# '^\s*$'
    let l:end_line -= 1
  endwhile

  if l:start_line > l:end_line
    return 0
  endif

  let l:start_pos = [0, l:start_line, 1, 0]
  let l:end_pos = [0, l:end_line, col([l:end_line, '$']), 0]

  return ['V', l:start_pos, l:end_pos]
endfunction

" Select a section (between separators, including blank lines)
function! Textobj_mdsection_select_a() abort
  let l:result = s:find_section_range()
  if l:result[0] == 0
    return 0
  endif

  let [l:start_line, l:end_line] = l:result

  let l:start_pos = [0, l:start_line, 1, 0]
  let l:end_pos = [0, l:end_line, col([l:end_line, '$']), 0]

  return ['V', l:start_pos, l:end_pos]
endfunction

" Register the text object
call textobj#user#plugin('mdsection', {
\   '-': {
\     'select-a': 'a-',
\     'select-a-function': 'Textobj_mdsection_select_a',
\     'select-i': 'i-',
\     'select-i-function': 'Textobj_mdsection_select_i',
\   }
\ })

" kebab-textobj.vim - Custom text object for kebab-case words
" Requires: vim-textobj-user

" Check if a character is part of kebab-case (alphanumeric or hyphen)
function! s:is_kebab_char(char) abort
  return a:char =~# '[a-zA-Z0-9_-]'
endfunction

" Find the range of kebab-case word under cursor
function! s:find_kebab_range() abort
  let l:line = getline('.')
  let l:col = col('.') - 1  " 0-indexed
  let l:len = len(l:line)

  " Check if cursor is on a valid kebab character
  if l:col >= l:len || !s:is_kebab_char(l:line[l:col])
    return [0, 0]
  endif

  " Search left for start of kebab-case
  let l:start = l:col
  while l:start > 0 && s:is_kebab_char(l:line[l:start - 1])
    let l:start -= 1
  endwhile

  " Search right for end of kebab-case
  let l:end = l:col
  while l:end < l:len - 1 && s:is_kebab_char(l:line[l:end + 1])
    let l:end += 1
  endwhile

  " Check if this is actually kebab-case (contains at least one hyphen)
  let l:word = l:line[l:start : l:end]
  if l:word !~# '-'
    return [0, 0]
  endif

  return [l:start + 1, l:end + 1]  " 1-indexed for Vim
endfunction

" Select inner kebab-case (the word itself)
function! Textobj_kebab_select_i() abort
  let l:result = s:find_kebab_range()
  if l:result[0] == 0
    return 0
  endif

  let l:line = line('.')
  let l:start_pos = [0, l:line, l:result[0], 0]
  let l:end_pos = [0, l:line, l:result[1], 0]

  return ['v', l:start_pos, l:end_pos]
endfunction

" Select a kebab-case (same as inner for now)
function! Textobj_kebab_select_a() abort
  return Textobj_kebab_select_i()
endfunction

" Register the kebab text object
call textobj#user#plugin('kebab', {
\   'k': {
\     'select-a': 'ak',
\     'select-a-function': 'Textobj_kebab_select_a',
\     'select-i': 'ik',
\     'select-i-function': 'Textobj_kebab_select_i',
\   }
\ })

" Integrate with vim-expand-region for markdown files
" call expand_region#custom_text_objects('markdown', {
" \   'i-': 0,
" \   'a-': 0,
" \ 'ik'  :0,
" \ 'ak'  :0,
" \ })

let g:expand_region_text_objects = {
  \ 'iw'  :0,
\ 'iW'  :0,
\ 'i"'  :0,
\ 'i''' :0,
\ 'i-': 0,
\ 'a-': 0,
\ 'i]'  :1,
\ 'a]' :1,
\ 'ib'  :1,
\ 'ab' :1,
\ 'iB'  :1,
\ 'aB' :1,
\ 'il'  :0,
\ 'ip'  :0,
\ 'ie'  :0,
\ 'ik'  :0,
\ 'ak'  :0,
\ 'ii' :0,
\ 'ai' :0,
\ }
