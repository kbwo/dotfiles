#!/bin/sh
if type "apt-get" > /dev/null 2>&1; then
  apt-get update
  apt-get install -y libncurses5-dev silversearcher-ag
  apt-get install neovim
  apt-get install python-neovim
  apt-get install python3-neovim
  apt-get install zsh
fi

sh ~/dotfiles/install-nvim.sh
sh ~/dotfiles/install-python.sh
sh ~/dotfiles/install-ripgrep.sh
sh ~/dotfiles/ln.sh
