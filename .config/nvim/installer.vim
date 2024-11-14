if !executable("curl")
  echoerr "You have to install curl or first install vim-plug"
  execute "q!"
endif

" install vim-plug and plugins after install of necessary commands
if !filereadable(expand('~/.vim/autoload/plug.vim'))
  echo "Installing Vim-Plug..."
  echo ""
  silent !\curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  silent !\curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  let g:not_finish_vimplug = "yes"
  autocmd VimEnter * PlugInstall
endif
