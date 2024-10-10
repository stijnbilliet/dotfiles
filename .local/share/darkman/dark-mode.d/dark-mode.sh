#!/usr/bin/fish

ln -sfn ~/.config/cfx/dark ~/.color.d
ln -sf ~/.local/share/wallpapers/dark_cygnus.jpg ~/.wallpaper
touch ~/.config/alacritty/alacritty.toml

gsettings set org.gnome.desktop.interface color-scheme prefer-dark
gsettings set org.gnome.desktop.interface gtk-theme Adwaita:dark

set nvim_sockets /run/user/1000/nvim*
for socket in $(find $nvim_sockets -type s)
    nvim --server $socket --remote-send ':set bg=dark<CR>:<ESC>'
end
