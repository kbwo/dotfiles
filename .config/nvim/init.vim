source ~/dotfiles/.config/nvim/base.vim
source ~/dotfiles/.config/nvim/util.vim

source ~/dotfiles/.config/nvim/plugin.lua

function! LoadConfigurations(directory) abort
  for path in glob(a:directory . '/*.vim', 1, 1, 1)
    execute printf('source %s', fnameescape(path))
  endfor
  if(has('nvim'))
    for path in glob(a:directory . '/*.lua', 1, 1, 1)
      execute printf('source %s', fnameescape(path))
    endfor
  end
endfunction

call LoadConfigurations('~/dotfiles/.config/nvim/plugin.d')
