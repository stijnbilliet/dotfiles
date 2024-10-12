#!/bin/bash

entries="\tLock\n\tLogout\n⏾\tSuspend\n\tReboot\n⏻\tShutdown"
selected=$(echo -e $entries|wofi --show dmenu -i --width 300 --height 275 --cache-file /dev/null --color ~/.color.d/colors.wofi | awk '{print tolower($2)}')

case $selected in
  lock)
    swaylock -f -c 000000;;
  logout)
    swaymsg exit;;
  suspend)
    exec systemctl suspend;;
  reboot)
    exec systemctl reboot;;
  shutdown)
    exec systemctl poweroff -i;;
esac
