### Exports
set fish_greeting
set -x TERM "alacritty"
set -x EDITOR "nvim"
set -x VISUAL "nvim"
set -x MANPAGER 'nvim +Man!'

# Set XDG base directory defaults
set -x XDG_CONFIG_HOME (set -q XDG_CONFIG_HOME; and echo $XDG_CONFIG_HOME; or echo $HOME/.config)
set -x XDG_DATA_HOME (set -q XDG_DATA_HOME; and echo $XDG_DATA_HOME; or echo $HOME/.local/share)
set -x XDG_CACHE_HOME (set -q XDG_CACHE_HOME; and echo $XDG_CACHE_HOME; or echo $HOME/.cache)
set -x XDG_RUNTIME_DIR (set -q XDG_RUNTIME_DIR; and echo $XDG_RUNTIME_DIR; or echo /run/user/(id -u))

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
