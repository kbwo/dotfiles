function! StartsWith(string, prefix)
  " Returns 1 (true) if 'string' starts with 'prefix', otherwise 0 (false)
  return stridx(a:string, a:prefix) == 0
endfunction

function! FindNearestGitRoot()
  let s:gin_filetypes = ['', 'gin', 'gin-status', 'gin-branch', 'gin-log', 'gin-diff']
  let l:result = ''

  if index(s:gin_filetypes, &filetype) != -1
    let l:result = '.'
  else
    let l:current_directory = expand('%:p:h')
    let l:current_file = expand('%:p')
    let l:git_root = ''

    if l:current_file =~ '\v^\w+://'
      if l:current_file !~ '\v^file://'
        let l:result = '.'
      endif
    endif

    if l:result ==# ''
      while l:current_directory !=# '/'
          let l:git_path = l:current_directory . '/.git'
          if isdirectory(l:git_path)
              let l:git_root = l:current_directory
              break
          endif
          let l:current_directory = fnamemodify(l:current_directory, ':h')
      endwhile

      let l:cwd = getcwd()

      if l:git_root ==# '' && StartsWith(l:current_file, l:cwd)
        let l:result = l:cwd
      elseif l:git_root ==# ''
        let l:result = expand('%:p:h')
      elseif StartsWith(l:current_directory, l:git_root) && !StartsWith(l:current_file, l:cwd)
        let l:result = l:git_root
      elseif StartsWith(l:cwd, l:git_root)
        let l:result = l:cwd
      else
        let l:result = l:git_root
      endif
    endif
  endif

  " Escape spaces in directory path for macOS compatibility
  if has('mac') || has('macunix')
    let l:result = substitute(l:result, ' ', '\\ ', 'g')
  endif

  return l:result
endfunction
