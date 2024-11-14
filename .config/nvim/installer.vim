if !executable("curl")
  echoerr "You have to install curl or first install vim-jetpack"
  execute "q!"
endif

" install vim-jetpack and plugins after install of necessary commands
if !filereadable(expand('~/.local/share/nvim/site/pack/jetpack/opt/vim-jetpack/plugin/jetpack.vim'))
  echo "Installing vim-jetpack..."
  echo ""
  silent !\curl -fLo ~/.local/share/nvim/site/pack/jetpack/opt/vim-jetpack/plugin/jetpack.vim --create-dirs https://raw.githubusercontent.com/tani/vim-jetpack/master/plugin/jetpack.vim
  autocmd VimEnter * JetpackSync
endif
