#!/usr/bin/env fish

# Read and parse the notification log
set notifications (makoctl history | jq -r '.data[][] | "\(.summary.data)\r\(.body.data)"')

# Display notifications in rofi menu
for notification in $notifications; echo $notification; end | wofi --show dmenu -i -p "Notifications:" --height 400 -i --cache-file /dev/null --color ~/.color.d/colors.wofi
