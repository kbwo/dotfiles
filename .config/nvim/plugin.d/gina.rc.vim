nmap gns :Gina status --opener=vsplit<CR>
nmap gnc :Gina commit --opener=split<CR>
nmap gnb :Gina branch --opener=vsplit<CR>
nmap gnh :Gina checkout -b
nmap gnps :Gina push
nmap gnpl :Gina pull<CR>
nmap gnl :Gina log --oneline --graph<CR>
let g:gina#command#blame#formatter#format = '%au: %su%= on %ti %ma%in'

function! FindGitDir()
  let git_dir = system('git rev-parse --show-toplevel 2>/dev/null')
  return git_dir ==# '' ? '' : git_dir[:-2]
endfunction

function s:append_diff() abort
  " Get the Git repository root directory
  let git_dir = FindGitDir()
  let git_root = fnamemodify(git_dir, ':h')

  " Get the diff of the staged changes relative to the Git repository root
  let diff = system('git -C ' . git_dir . ' diff --cached')

  " Add a comment character to each line of the diff
  let comment_diff = join(map(split(diff, '\n'), {idx, line -> '# ' . line}), "\n")

  " Append the diff to the commit message
  call append(line('$'), split(comment_diff, '\n'))
endfunction

autocmd FileType gina-commit call s:append_diff()
autocmd FileType git-commit call s:append_diff()
