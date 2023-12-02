function! StartsWith(string, prefix)
  " Returns 1 (true) if 'string' starts with 'prefix', otherwise 0 (false)
  return stridx(a:string, a:prefix) == 0
endfunction

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

  let l:cwd = getcwd()
  if StartsWith(l:cwd, l:git_root)
    return l:cwd
  endif

  return l:git_root
endfunction
