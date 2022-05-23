#!/bin/sh
mkdir -p ~/.config/nvim
mkdir -p ~/.config/fish
mkdir -p ~/.vim/UltiSnips
ln -sf ~/dotfiles/.config/nvim/init.vim ~/.vimrc
ln -sf ~/dotfiles/.config/nvim/init.vim ~/.config/nvim/init.vim
ln -sf ~/dotfiles/.config/nvim/coc-settings.json ~/.config/nvim/coc-settings.json
ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -sf ~/dotfiles/.tmux.conf ~/.tmux.conf
ln -sf ~/dotfiles/UltiSnips/ ~/.vim/UltiSnips
ln -sf ~/dotfiles/.alacritty.arch.yml ~/.alacritty.yml
