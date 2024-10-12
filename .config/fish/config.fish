### Exports
set fish_greeting
set -x TERM "alacritty"
set -x EDITOR "nvim"
set -x VISUAL "nvim"
set -x MANPAGER 'nvim +Man!'

# Wrap sway to ensure correct env vars are set on login
function sway
    set -x XDG_CURRENT_DESKTOP sway
    set -x XDG_SESSION_DESKTOP sway
    set -x XDG_SESSION_TYPE wayland
    sway $argv
end
