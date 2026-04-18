#!/usr/bin/env bash

# SETUP from gnome
# ❯ xinput list-props 12
gnome_setup="
	libinput Tapping Enabled (284):	1
	libinput Tapping Enabled Default (285):	0
	libinput Tapping Drag Enabled (286):	1
	libinput Tapping Drag Enabled Default (287):	1
	libinput Tapping Drag Lock Enabled (288):	1
	libinput Tapping Drag Lock Enabled Default (289):	0
	libinput Tapping Button Mapping Enabled (290):	1, 0
	libinput Tapping Button Mapping Default (291):	1, 0
	libinput Natural Scrolling Enabled (292):	0
	libinput Natural Scrolling Enabled Default (293):	0
	libinput Disable While Typing Enabled (294):	1
	libinput Disable While Typing Enabled Default (295):	1
	libinput Scroll Methods Available (296):	1, 1, 0
	libinput Scroll Method Enabled (297):	1, 0, 0
	libinput Scroll Method Enabled Default (298):	1, 0, 0
	libinput Accel Speed (299):	0.136691
	libinput Accel Speed Default (300):	0.000000
	libinput Left Handed Enabled (301):	0
	libinput Left Handed Enabled Default (302):	0
	libinput Send Events Modes Available (269):	1, 1
	libinput Send Events Mode Enabled (270):	0, 0
	libinput Send Events Mode Enabled Default (271):	0, 0
	libinput Horizontal Scroll Enabled (304):	1
"

touchpad_id=$(xinput list | grep Touchpad | grep -Po '(?<=id=)\d+')

echo "$gnome_setup" | while read line; do
    name=$(echo "$line" | grep -Po '.*(?= \(\d+\))')
    value=$(echo "$line" | cut -d':' -f2)
    if [[ -n "$value" ]]; then
        xinput set-prop $touchpad_id "$name" $value 2> /dev/null
    fi
done
