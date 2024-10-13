#!/usr/bin/env python3
import os
import argparse
import subprocess
import signal
import configparser
import sys
import random
from pathlib import Path

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
parser = argparse.ArgumentParser(description='DandL+ A system Dark AND Light theme switcher 🌼')

group = parser.add_mutually_exclusive_group()
group.add_argument('--mode', type=str, choices=['light', 'dark'], \
                   help='Set light or dark mode')
group.add_argument('--toggle', action='store_true', \
                   help='Switch between dark and light mode')
group.add_argument('--get', action='store_true', \
                   help='Get current system dark/light mode')

parser.add_argument('--config', type=argparse.FileType('r', encoding='UTF-8'), \
                   help='Path to custom config file, otherwise xdg_config_home/dandl/dandl.ini is used')

args = parser.parse_args(None if sys.argv[1:] else ['-h'])

# Main args
if args.get:
    print(get_cur_mode())
    exit()
elif args.toggle:
    if get_cur_mode() == "dark":
        args.mode = "light"
    else:
        args.mode = "dark"

# At this point mode should be set, if not exit
if not args.mode:
    parser.print_help()
    exit()

# Handle config
homedir = os.path.expanduser('~')
config = configparser.ConfigParser()
if args.config:
    config_path = os.path.abspath(args.config)
else:
    # Get XDG dirs
    xdg_config_home = os.environ.get('XDG_CONFIG_HOME') or \
                os.path.join(homedir, '.config')
    config_path = os.path.join(xdg_config_home, 'dandl', 'dandl.ini')
config.read(config_path)

# Swap over colors pointed to by .color.d so that clients who include via the color symlink get the correct variant
os.unlink(f'{homedir}/.color.d')
os.symlink(f'{homedir}/.config/cfx/{args.mode}', f'{homedir}/.color.d', target_is_directory=True)

# Set preferred wallpaper for mode
config_wallpaper = config.get(f'{args.mode}', 'wallpaper')
wallpaper_path = os.path.expanduser(config_wallpaper)
if not os.path.isabs(wallpaper_path):
    wallpaper_path_obj = (Path(config_path).parent).joinpath(config_wallpaper)
    wallpaper_path = wallpaper_path_obj.resolve()
if os.path.isdir(wallpaper_path):
    wallpaper = random.choice(os.listdir(wallpaper_path))
    wallpaper_path = os.path.join(wallpaper_path, wallpaper)
    print(f"selecting wallpaper: {wallpaper}")

if os.path.isfile(wallpaper_path):
    print(f"changing wallpaper to: {wallpaper_path}")
    os.unlink(f'{homedir}/.wallpaper')
    os.symlink(wallpaper_path, f'{homedir}/.wallpaper')

# Set up org.freedesktop.appearance (through gnomes interface)
subprocess.run(['gsettings', 'set', 'org.gnome.desktop.interface', 'color-scheme', f'prefer-{args.mode}'])

# Misc
# Reload background
shouldkill = True
try:
    swaybgpid_result = subprocess.check_output(['pidof', 'swaybg'])
except subprocess.CalledProcessError:
    shouldkill=False
finally:
    subprocess.Popen(['swaybg', '-o', '*', '-i', f'{homedir}/.wallpaper', '-m', 'fill'], start_new_session=True)
    if shouldkill:
        swaybgpids = swaybgpid_result.decode().strip().split()
        for proc in swaybgpids:
            os.kill(int(proc), signal.SIGKILL)

# Touch alacritty's config to trigger reload
os.utime(f'{homedir}/.config/alacritty/alacritty.toml', None)

# Poll nvim for opened listeners and propate bg change
socket_dir = '/run/user/1000/'
nvim_sockets=[os.path.join(socket_dir, file) for file in os.listdir(socket_dir) if file.startswith('nvim.')]
for socket in nvim_sockets:
    subprocess.run(['nvim', '--server', socket, '--remote-send', f':set bg={args.mode}<CR>:<ESC>'])
