nmap gns :Gina status --opener=vsplit<CR>
nmap gnc :Gina commit --opener=split<CR>
nmap gnb :Gina branch --opener=vsplit<CR>
nmap gnh :Gina checkout -b
nmap gnps :Gina push
nmap gnpl :Gina pull<CR>
nmap gnl :Gina log --oneline --graph<CR>
let g:gina#command#blame#formatter#format = '%au: %su%= on %ti %ma%in'

function! FindGitDir()
  let path = expand('%:p:h')
  while path !=# '/' && !isdirectory(path.'/.git')
    let path = fnamemodify(path, ':h')
  endwhile

  if isdirectory(path.'/.git')
    return path
  else
    echoerr 'Could not find .git directory'
    return ''
  endif
endfunction

function s:append_diff() abort
  " Get the Git repository root directory
  let git_dir = FindGitDir()
  let git_root = fnamemodify(git_dir, ':h')

  " Get the diff of the staged changes relative to the Git repository root
  let diff = system('git -C ' . git_root . ' diff --cached')

  " Add a comment character to each line of the diff
  let comment_diff = join(map(split(diff, '\n'), {idx, line -> '# ' . line}), "\n")

  " Append the diff to the commit message
  call append(line('$'), split(comment_diff, '\n'))
endfunction

autocmd FileType gina-commit call s:append_diff()
autocmd BufReadPost COMMIT_EDITMSG call s:append_diff()
