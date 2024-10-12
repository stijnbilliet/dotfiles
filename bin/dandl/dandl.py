#!/usr/bin/env python3
import os
import argparse
import subprocess
from pathlib import Path
homedir = Path.home()

def get_cur_mode():
    try:
        output = subprocess.check_output(['gsettings', 'get', 'org.gnome.desktop.interface', 'color-scheme'])
        color_scheme = output.decode('utf-8').strip()
        mode = color_scheme.replace("'", "")
        return mode.rsplit('-')[1]
    except subprocess.CalledProcessError as e:
        print(f"Error querying gsettings: {e}")
        return None

# Parse args
parser = argparse.ArgumentParser(description='DarkANDLight theme switcher')
parser.add_argument('--mode', type=str, choices=['light', 'dark'], help='Set light or dark mode')
parser.add_argument('--toggle', action='store_true', help='Switch between dark and light mode')
args = parser.parse_args()

if args.toggle:
    if get_cur_mode() == "dark":
        args.mode = "light"
    else:
        args.mode = "dark"

# Swap over colors pointed to by .color.d so that clients who include via the color symlink get the correct variant
os.unlink(f'{homedir}/.color.d')
os.symlink(f'{homedir}/.config/cfx/{args.mode}', f'{homedir}/.color.d', target_is_directory=True)

# Set up org.freedesktop.appearance (through gnomes interface)
subprocess.run(['gsettings', 'set', 'org.gnome.desktop.interface', 'color-scheme', f'prefer-{args.mode}'])

# Misc
# Touch alacritty's config to trigger reload
os.utime(f'{homedir}/.config/alacritty/alacritty.toml', None)

# Poll nvim for opened listeners and propate bg change
socket_dir = '/run/user/1000/'
nvim_sockets=[os.path.join(socket_dir, file) for file in os.listdir(socket_dir) if file.startswith('nvim.')]
for socket in nvim_sockets:
    subprocess.run(['nvim', '--server', socket, '--remote-send', f':set bg={args.mode}<CR>:<ESC>'])
