#!/usr/bin/env python3
import os
import argparse
import subprocess
import signal
import configparser
import sys
import random
import dbus
import stat
import time
import typing

from pathlib import Path
from gi.repository import Gio

def get_cur_mode():
    # See following image for future reference on how to use dbus
    # https://i.sstatic.net/lIAWr.png
    # get_object(bus_name, object_path, introspect=True, follow_name_owner_changes=False, **kwargs)
    bus = dbus.SessionBus()
    proxy = bus.get_object('org.freedesktop.portal.Desktop', '/org/freedesktop/portal/desktop')
    settings_iface = dbus.Interface(proxy, dbus_interface='org.freedesktop.portal.Settings')
    color_scheme_val = settings_iface.ReadOne('org.freedesktop.appearance', 'color-scheme')
    tlb = {
        0: "unset",
        1: "dark",
        2: "light",
    }
    return tlb[color_scheme_val]

def set_toolkit_mode(mode):
    # In the future implementation for a dbus org.freedesktop path might get added
    # However at the moment, we need to do this for each toolkit/DE individually.
    # Regardless of this, desktops do tend to listen for the settings_changed signal
    # on the org.freedesktop.appearance interface and should change their perferences accordingly

    # Set gnomes color-scheme
    de_iface_settings = Gio.Settings(schema='org.gnome.desktop.interface')
    de_iface_settings.set_string('color-scheme', f'prefer-{mode}')

# Parse args
parser = argparse.ArgumentParser(description='DandL+ A system Dark AND Light theme switcher 🌼')

group = parser.add_mutually_exclusive_group()
group.add_argument('--mode', type=str, choices=['light', 'dark'], \
                   help='Set light or dark mode')
group.add_argument('--toggle', action='store_true', \
                   help='Switch between dark and light mode')
group.add_argument('--get', choices=['simple', 'waybar'], const='simple', nargs='?', \
                   help='Get current system dark/light mode')

parser.add_argument('--config', type=argparse.FileType('r', encoding='UTF-8'), \
                   help='Path to custom config file, otherwise xdg_config_home/dandl/dandl.ini is used')

args = parser.parse_args(None if sys.argv[1:] else ['-h'])

# Main args
if args.get:
    if args.get == 'waybar':
        cur_mode = get_cur_mode()
        waybar_percentage = 0 if cur_mode =="dark" else 100
        waybar_return = '{' + f'"percentage": "{waybar_percentage}"' + '}'
        print(waybar_return)
        exit()
    else:
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

# Set up org.freedesktop.appearance (through gnomes interface)
set_toolkit_mode(args.mode)

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

# Misc
# Touch alacritty's config to trigger reload
os.utime(f'{homedir}/.config/alacritty/alacritty.toml', None)

# Check for open neovim sockets and propagate bg change
def find_socket_files(socketkind):
    xdg_runtime_dir = os.environ.get('XDG_RUNTIME_DIR')
    tmpdir = os.environ.get('TMPDIR', '/tmp')
    user = os.environ.get('USER')

    search_dir = xdg_runtime_dir or os.path.join(tmpdir, f'{socketkind}.{user}')
    socket_list = []
    for endpoint in os.listdir(search_dir):
        ep_path = os.path.join(search_dir, endpoint)
        mode = os.stat(ep_path).st_mode
        isSocket = stat.S_ISSOCK(mode)
        if isSocket and endpoint.startswith(f'{socketkind}.'):
            socket_list.append(ep_path)

    return socket_list

for socket in find_socket_files('nvim'):
    shell_cmd = f'nvim --server {socket} --remote-send "<Cmd>set bg={args.mode}<CR>"'
    subprocess.run(['nvim', '--server', socket, '--remote-send', f'<Cmd>set bg={args.mode}<CR>'], start_new_session=True)

# Reload background
swaybgpid_proc = subprocess.run(['pidof', 'swaybg'], capture_output=True)
shouldkill = True if swaybgpid_proc.returncode == 0 else False
bgproc = subprocess.Popen(['swaybg', '-o', '*', '-i', f'{homedir}/.wallpaper', '-m', 'fill'], start_new_session=True)
time.sleep(1)
if shouldkill:
    print(shouldkill)
    swaybgpids = swaybgpid_proc.stdout.strip().split()
    print(swaybgpids)
    for proc in swaybgpids:
        os.kill(int(proc), signal.SIGKILL)
