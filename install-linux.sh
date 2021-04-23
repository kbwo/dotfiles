#!/bin/sh
if type "apt-get" > /dev/null 2>&1; then
  apt-get update
  apt-get install -y libncurses5-dev silversearcher-ag
  apt-get install zsh
  apt-get install fish
  curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
  apt-get install exa
  apt-get install ghq
  fisher install jethrokuan/z
  fisher install oh-my-fish/theme-bobthefish
  fisher install decors/fish-ghq
fi
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

sh ~/dotfiles/install-nvim.sh
sh ~/dotfiles/install-python.sh
sh ~/dotfiles/install-ripgrep.sh
sh ~/dotfiles/ln.sh
