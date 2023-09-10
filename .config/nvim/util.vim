function! FindNearestGitRoot()
  let l:current_directory = expand('%:p:h')
  let l:git_root = ''

  while l:current_directory !=# '/'
      let l:git_path = l:current_directory . '/.git'
      if isdirectory(l:git_path)
          let l:git_root = l:current_directory
          break
      endif
      let l:current_directory = fnamemodify(l:current_directory, ':h')
  endwhile

  if l:git_root ==# ''
    return expand('%:p:h')
  endif

  return l:git_root
endfunction
