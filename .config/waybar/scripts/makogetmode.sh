#!/usr/bin/env bash
mode=$(makoctl mode | grep -q 'do-not-disturb' && echo dnd || echo default) && printf '{\"alt\":\"%s\",\"tooltip\":\"Notify: %s\",\"class\":\"%s\"}' $mode $mode $mode
