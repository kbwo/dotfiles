#!/bin/sh
mkdir -p ~/.config/nvim
# ln -s ~/dotfiles/.config/nvim/init.vim ~/.vimrc
ln -sf ~/dotfiles/.config/nvim/init.vim ~/.config/nvim/init.vim
ln -sf ~/dotfiles/.config/nvim/ftplugin ~/.config/nvim/ftplugin
ln -sf ~/dotfiles/.zsh.d/.zshrc ~/.zshrc
ln -sf ~/dotfiles/.tmux.conf ~/.tmux.conf
# ln -sf ~/dotfiles/.alacritty.sway.toml ~/.alacritty.toml
ln -sf ~/dotfiles/.alacritty.gnome.toml ~/.alacritty.toml
ln -sf ~/dotfiles/.skhdrc ~/.skhdrc
ln -sf ~/dotfiles/.config/nvim/coc-settings.json ~/.config/nvim/coc-settings.json
ln -sf ~/dotfiles/.config/nvim/coc-extensions ~/.config/nvim/coc-extensions
mkdir -p ~/.config/espanso
ln -sf ~/dotfiles/.config/espanso/* ~/.config/espanso

mkdir -p ~/.themes
ln -sf ~/dotfiles/.themes/gtk-kbwo-text-entry ~/themes/gtk-kbwo-text-entry
ln -sf ~/dotfiles/.config/autostart/xremap.desktop ~/.config/autostart/xremap.desktop
ln -sf ~/dotfiles/.config/systemd/user/xremap.service ~/.config/systemd/user/xremap.service
mkdir -p ~/.config/xremap
ln -sf ~/dotfiles/.config/xremap/config.yml ~/.config/xremap/config.yml
