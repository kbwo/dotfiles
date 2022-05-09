if !executable("curl")
  echoerr "You have to install curl or first install vim-plug, volta, rust yourself!"
  execute "q!"
endif

" install rustup
if !executable("cargo")
  echo "Installing rustup..."
  echo ""
  silent !\curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
endif

" install volta
if !isdirectory($HOME .'/.volta')
  echo "Installing Volta..."
  echo ""
  silent !\curl https://get.volta.sh | bash -s -- --skip-setup
  silent !\~/.volta/bin/volta install node@14
endif

" install deno
if !executable("deno")
  echo "Installing deno..."
  echo ""
  silent !\cargo install
endif

" install deno
if !executable("rg")
  echo "Installing ripgrep..."
  echo ""
  silent !\cargo install ripgrep
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
