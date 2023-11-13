### Exports
set fish_greeting
set TERM "alacritty"
set EDITOR "nvim"
set VISUAL "nvim"
set -x MANPAGER "nvim -c 'set ft=man' -"
# Add darkman root dir to XDG_DATA_DIRS path
set -gx --path XDG_DATA_DIRS ~/.local/share/darkman/ $XDG_DATA_DIRS
