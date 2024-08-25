#!/bin/sh
mkdir -p ~/.config/nvim
# ln -sf ~/dotfiles/.config/nvim/init.vim ~/.vimrc
ln -sf ~/dotfiles/.config/nvim/init.vim ~/.config/nvim/init.vim
ln -sf ~/dotfiles/.zsh.d/.zshrc ~/.zshrc
ln -sf ~/dotfiles/.tmux.conf ~/.tmux.conf
# ln -sf ~/dotfiles/.alacritty.sway.toml ~/.alacritty.toml
ln -sf ~/dotfiles/.alacritty.gnome.toml ~/.alacritty.toml
ln -sf ~/dotfiles/.skhdrc ~/.skhdrc
ln -sf ~/dotfiles/.config/nvim/coc-settings.json ~/.config/nvim/coc-settings.json
