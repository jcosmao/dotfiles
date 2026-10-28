#!/usr/bin/env bash
#
# Watch DRM hotplug events and rebuild/restart i3 when the autorandr layout changes

exec &> /tmp/$(basename $0).log

# single instance
exec 9> /tmp/$(basename $0).lock
flock -n 9 || exit 0

function set_wifi
{
    busctl set-property org.freedesktop.NetworkManager /org/freedesktop/NetworkManager \
        org.freedesktop.NetworkManager WirelessEnabled b $1
}

# laptop: wifi on. external screen: wifi off only if wired (dock) default route comes up
function update_wifi
{
    if [[ $1 == laptop ]]; then
        echo "$(date '+%F %T') wifi on"
        set_wifi true
        return
    fi

    # dock ethernet needs a few seconds for link + dhcp
    for _ in {1..20}; do
        if ip route show default | grep -q " dev en"; then
            echo "$(date '+%F %T') wired default route up: wifi off"
            set_wifi false
            return
        fi
        sleep 1
    done
    echo "$(date '+%F %T') no wired link: keep wifi"
}

current_layout=$(autorandr --detected 2> /dev/null | head -1)
update_wifi "$current_layout" &

udevadm monitor --udev --subsystem-match=drm | while read -r line; do
    [[ $line == *change* ]] || continue

    # debounce: one plug sends several events, wait until it settles
    while read -r -t 2 _; do :; done

    layout=$(autorandr --detected 2> /dev/null | head -1)
    echo "$(date '+%F %T') hotplug: '$current_layout' -> '$layout'"
    [[ -z "$layout" || "$layout" == "$current_layout" ]] && continue

    current_layout=$layout
    update_wifi "$layout" < /dev/null 9>&- &
    ~/.config/i3/i3_build_conf.sh restart < /dev/null 9>&-
done
