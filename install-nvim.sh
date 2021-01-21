#!/bin/sh
cd
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod u+x nvim.appimage
./nvim.appimage --appimage-extract
mv squashfs-root / && ln -s /squashfs-root/AppRun /usr/bin/nvim
