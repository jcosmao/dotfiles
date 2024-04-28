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
        # nmcli radio wifi off && \
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
