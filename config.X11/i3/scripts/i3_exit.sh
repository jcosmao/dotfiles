#!/bin/bash

select=$(
    echo -e "lock\nlogout\nsuspend\nreboot\nshutdown" | \
        dmenu -sf '#000000' -sb '#f00060' -i -p "i3 action ?"
)

function lock()
{
    ~/.config/i3/scripts/i3lock_blur.sh
}

case "$select" in
    lock)
        lock
        ;;
    logout)
        loginctl list-sessions -o json | jq -r .[].session | xargs loginctl terminate-session
        ;;
    suspend)
        # need root
        # nmcli radio wifi off && \
        #
        # dbus list
        # busctl introspect org.freedesktop.NetworkManager /org/freedesktop/NetworkManager
        dbus-send --system --print-reply --dest=org.freedesktop.NetworkManager /org/freedesktop/NetworkManager \
            org.freedesktop.DBus.Properties.Set string:'org.freedesktop.NetworkManager' string:'WirelessEnabled' variant:boolean:false

        lock && \
        systemctl suspend
        ;;
    reboot)
        systemctl reboot
        ;;
    shutdown)
        systemctl poweroff
        ;;
    *)
        echo "Usage: $0 {lock|logout|suspend|reboot|shutdown}"
        exit 2
esac
