#!/bin/sh
mkdir -p ~/.config/nvim
ln -sf ~/dotfiles/.config/nvim/init.vim ~/.vimrc
ln -sf ~/dotfiles/.config/nvim/init.vim ~/.config/nvim/init.vim
ln -sf ~/dotfiles/.config/nvim/coc-settings.json ~/.config/nvim/coc-settings.json
ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -sf ~/dotfiles/.tmux.conf ~/.tmux.conf
ln -sf ~/dotfiles/.alacritty.arch.yml ~/.alacritty.yml
ln -sf ~/dotfiles/ultisnips/* ~/.config/coc/ultisnips
