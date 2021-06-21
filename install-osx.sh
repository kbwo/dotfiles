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
brew install ripgrep
brew install pyenv
brew install neovim
brew install alacritty
brew install node
brew tap sanemat/font
brew install ricty
cp -f /usr/local/opt/ricty/share/fonts/Ricty*.ttf ~/Library/Fonts/
fc-cache -vf
fisher install jethrokuan/z
fisher install oh-my-fish/theme-bobthefish
fisher install decors/fish-ghq

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
cargo install alacritty

sh ~/dotfiles/ln.sh
chsh -s /bin/zsh
source ~/.zshrc
pyenv install 3.7.0
pyenv global 3.7.0
sh ~/dotfiles/install-nvim.sh
pip3 install pynvim
npm install -g n
n 14.5.0
