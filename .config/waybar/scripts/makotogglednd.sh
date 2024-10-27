#!/usr/bin/env bash
makoctl mode | grep 'do-not-disturb' && makoctl mode -r do-not-disturb || makoctl mode -a do-not-disturb; pkill -RTMIN+11 waybar
