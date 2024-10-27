#!/usr/bin/env fish
notify-send "Scanning for available Wi-Fi networks..."
set nmcli_list (nmcli --fields "SECURITY,SSID" device wifi list | sed 1d | sed 's/  */ /g' | sed "/--/d" | sed -E "s/WPA*.?\S/ /g" | sort | uniq)
set selected (for line in $nmcli_list; echo $line; end | wofi -p "Wi-Fi SSID: " --show dmenu --width 300 --height 400 -i --cache-file /dev/null --color ~/.color.d/colors.wofi)

if not string length --quiet $selected
    exit
else
    set selected_ssid (echo $selected | string replace -r '[^a-zA-Z0-9._ -]' '' | string trim)
    set saved_connections (nmcli -g NAME connection)
    if echo "$saved_connections" | grep -w "$selected_ssid"
        echo "yahoo"
    else
        set success_message "You are now connected to the Wi-Fi network "$selected_ssid
        while true
            set wifi_password (wofi --show dmenu --width 300 --height 50 --password -p "Password: " --color ~/.color.d/colors.wofi)

            if test -z "$wifi_password"
                notify-send "Action Canceled" "No password entered. Exiting."
                break
            end

            if nmcli device wifi connect "$chosen_id" password "$wifi_password" | grep "successfully"
                notify-send "Connection Established" "$success_message"
                break
            else
                notify-send "Connection Failed" "Incorrect password. Please try again."
            end
        end
    end
end
