#!/bin/sh
if type "brew" > /dev/null 2>&1; then
  echo "brew is already installed"
else
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
brew install zsh
brew install fish
brew install tmux
curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
brew install exa
brew install ghq
brew install fzf
fisher install jethrokuan/z
fisher install oh-my-fish/theme-bobthefish
fisher install decors/fish-ghq

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
cargo install alacritty

sh ~/dotfiles/install-nvim.sh
sh ~/dotfiles/install-python.sh
sh ~/dotfiles/install-ripgrep.sh
sh ~/dotfiles/ln.sh
