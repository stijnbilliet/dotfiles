#!/usr/bin/fish

ln -sfn ~/.config/cfx/dark ~/.color.d
ln -sf ~/.local/share/wallpapers/dark_cygnus.jpg ~/.wallpaper

gsettings set org.gnome.desktop.interface color-scheme prefer-dark
gsettings set org.gnome.desktop.interface gtk-theme Adwaita:dark

for socket in $(find /run/user/1000/nvim* -type s)
    nvim --server $socket --remote-send ':set bg=dark<CR>:<ESC>'
end
