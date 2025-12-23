#!/bin/bash

# Fix terminal type
export TERM=xterm-256color
echo 'export TERM=xterm-256color' >> ~/.bashrc

# Install nvim
wget https://github.com/neovim/neovim/releases/download/v0.11.1/nvim-linux-x86_64.appimage
./nvim-linux-x86_64.appimage --appimage-extract 
mv ./squashfs-root/usr/bin/nvim /usr/bin/nvim
