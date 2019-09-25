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
        # Kill user processes
        ps -U $USER | grep -Ev "(ps|grep|ssh|tmux|screen|systemd|\(sd-pam\)|i3.*)$" | \
        awk '{print $1}' | tail -n +2 | xargs -t kill
        i3-msg exit
        ;;
    suspend)
        lock && systemctl suspend
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
