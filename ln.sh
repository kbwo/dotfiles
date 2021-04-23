#!/bin/sh
mkdir -p ~/.config/nvim
mkdir -p ~/.config/fish
ln -sf ~/dotfiles/.config/nvim/init.vim ~/.vimrc
ln -sf ~/dotfiles/.config/nvim/init.vim ~/.config/nvim/init.vim
ln -sf ~/dotfiles/.config/nvim/coc-settings.json ~/.config/nvim/coc-settings.json
ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -sf ~/dotfiles/.config/fish/config.fish ~/.config/fish/config.fish
