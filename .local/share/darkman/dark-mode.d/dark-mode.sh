#!/usr/bin/fish

ln -sfn ~/.config/cfx/dark ~/.color.d
ln -sf ~/.local/share/wallpapers/dark_cygnus.jpg ~/.wallpaper

gsettings set org.gnome.desktop.interface color-scheme prefer-dark
gsettings set org.gnome.desktop.interface gtk-theme Adwaita:dark

nvim --server /tmp/nvim.pipe --remote-send ':set bg=dark<CR>:<ESC>'
