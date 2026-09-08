" タブごとに参照する git worktree ディレクトリを切り替えるための設定。
"
" 「タブごとの workspace」はタブローカル変数 (t:) で管理する。t: 変数は
" 新規タブに引き継がれない (:tabnew で開いたタブは常に未設定から始まる) ため、
" 「あるタブで worktree を選んでも、新しく開いたタブでは選び直しになり、
" 何も選ばなければ cwd がベースになる」という挙動をそのまま満たせる。
" (:tcd はタブをまたいで cwd の値そのものが新規タブに引き継がれてしまう
" ため、ここでは使わずタブローカル変数だけで完結させている。)
"
" <C-n> (fern.rc.vim の s:git_fern) と ddu によるファイル探索
" (ddu.rc.vim の StartDduNoIgnore / StartDduIgnore / RgFindIgnore /
" RgFindNoIgnore) は、WorktreeTabDir() が空でなければそちらを、空なら
" 従来通りの git root 自動検出 / cwd を対象にする。

highlight default WorktreeTabLabel guifg=#1c1c1c guibg=#ffaf00 gui=bold ctermfg=black ctermbg=214

" 現在のタブに worktree ディレクトリを割り当てる。
function! SetTabWorktree(path) abort
  let path = substitute(fnamemodify(a:path, ':p'), '/$', '', '')
  if !isdirectory(path)
    echoerr 'Not a directory: ' . path
    return
  endif
  let t:worktree_dir = path
  " GitBranchAt() は base.vim で定義 (タブ/lualine のブランチ表示で共通利用)。
  let t:worktree_branch = GitBranchAt(path)
  if t:worktree_branch !=# ''
    echo 'Tab worktree -> ' . t:worktree_branch . ' (' . path . ')'
  else
    echo 'Tab worktree -> ' . path
  endif
endfunction

" 現在のタブへの worktree 割り当てを解除し、cwd 基準の挙動に戻す。
function! ClearTabWorktree() abort
  if exists('t:worktree_dir')
    unlet t:worktree_dir
  endif
  if exists('t:worktree_branch')
    unlet t:worktree_branch
  endif
  echo 'Tab worktree cleared'
endfunction

" 現在のタブに割り当てられている worktree ディレクトリ。未割り当てなら
" 空文字を返す。fern / ddu 側はこれが空かどうかで分岐する。
function! WorktreeTabDir() abort
  return get(t:, 'worktree_dir', '')
endfunction

command! -nargs=1 -complete=dir WorktreeTabSet call SetTabWorktree(<q-args>)
command! WorktreeTabClear call ClearTabWorktree()
