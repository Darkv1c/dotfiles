#!/bin/bash

# Fix terminal type
export TERM=xterm-256color
echo 'export TERM=xterm-256color' >> ~/.bashrc

# Install nvim
wget http://ftp.osuosl.org/pub/ubuntu/pool/universe/n/neovim/neovim_0.11.5-2_amd64.deb
sudo dpkg -i neovim_0.11.5-2_amd64.deb
yes | sudo apt --fix-broken install
