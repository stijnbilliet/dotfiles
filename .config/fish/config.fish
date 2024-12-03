### Exports
set fish_greeting
set -x TERM "alacritty"
set -x EDITOR "nvim"
set -x VISUAL "nvim"
set -x MANPAGER 'nvim +Man!'

# Wrap sway to ensure correct env vars are set on login
function startw
    set -x XDG_CURRENT_DESKTOP sway
    set -x XDG_SESSION_DESKTOP sway
    set -x XDG_SESSION_TYPE wayland

    # Wayland stuff
    set -x MOZ_ENABLE_WAYLAND 1
    set -x QT_QPA_PLATFORM wayland
    set -x _JAVA_AWT_WM_NONREPARENTING 1

    exec sway $argv 
end
