#!/bin/bash
set -e

# Update
sudo apt-get update

# Install zsh
sudo apt-get install -y zsh

# Install starship prompt
curl -sS https://starship.rs/install.sh | sh -s -- -y

# Set zsh as default shell
chsh -s $(which zsh)

# Install nvim from AppImage
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
chmod u+x nvim-linux-x86_64.appimage

# Extract AppImage
./nvim-linux-x86_64.appimage --appimage-extract

# Exposing nvim globally.
sudo mv squashfs-root /
sudo ln -s /squashfs-root/AppRun /usr/bin/nvim

# Neovim configuration (user config, no sudo required)
mkdir -p ~/.config/nvim/lua/plugins
cp ./.config/nvim/init.lua ~/.config/nvim/init.lua
cp ./.config/nvim/lua/plugins/core.lua ~/.config/nvim/lua/plugins/core.lua
cp ./.config/nvim/lua/plugins/study.lua ~/.config/nvim/lua/plugins/study.lua
cp ./.config/nvim/lua/plugins/work.lua ~/.config/nvim/lua/plugins/work.lua

# Zsh and Starship configuration
cp ./.zshrc ~/.zshrc
mkdir -p ~/.config
cp ./.config/starship.toml ~/.config/starship.toml

# Install yazi (file manager)
curl -LO https://github.com/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-gnu.tar.gz
tar -xzf yazi-x86_64-unknown-linux-gnu.tar.gz
sudo mv yazi-x86_64-unknown-linux-gnu/yazi /usr/local/bin/
rm -rf yazi-x86_64-unknown-linux-gnu yazi-x86_64-unknown-linux-gnu.tar.gz

# Install Open Code
curl -fsSL https://opencode.ai/install | bash
sudo apt-get install -y procps lsof
mkdir -p ~/.config/opencode
cp ./opencode.json ~/.config/opencode/opencode.json

echo "Installation complete! Please log out and log back in for zsh to take effect."
echo "Or run: exec zsh"
