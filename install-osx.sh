#!/bin/sh
if type "brew" > /dev/null 2>&1; then
  echo "brew is already installed"
else
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo >> ~/.zprofile
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
xcode-select --install
brew install tmux
brew install ghq
brew install fzf
brew install ripgrep
brew install neovim
brew install alacritty
brew install asmvik/formulae/skhd
brew install noti
brew install gh

curl https://mise.run | sh
echo "eval \"\$(/Users/kbwo/.local/bin/mise activate zsh)\"" >> ~/.zshenv
source ~/.zshenv

sh ~/dotfiles/ln.sh
ln -sf ~/dotfiles/.alacritty.osx.toml ~/.alacritty.toml
mise install deno
mise use -g deno
mise install node
mise use -g node
mise install go
mise use -g go
mise install rust
mise use -g rust
mise install python
mise use -g python

pip3 install neovim-remote
source ~/.zshrc
