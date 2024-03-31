#!/usr/bin/fish

ln -sfn ~/.config/cfx/light ~/.color.d
ln -sf ~/.local/share/wallpapers/dusk_light.jpg ~/.wallpaper

gsettings set org.gnome.desktop.interface color-scheme prefer-light
gsettings set org.gnome.desktop.interface gtk-theme Adwaita

nvim --server /tmp/nvim.pipe --remote-send ':set bg=light<CR>:<ESC>'
