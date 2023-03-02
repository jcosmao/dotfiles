#!/bin/bash

action=${1:-reload}

i3_dir=$( dirname "${BASH_SOURCE[0]}" )
i3_config_base="$i3_dir/base.config"
hw_name=$(cat /sys/devices/virtual/dmi/id/product_name)
i3_family_config="${i3_dir}/$hw_name.hw.config"
layout=$(autorandr 2>&1 | grep -P "(\(current\)|\(detected\))" | awk '{print $1}' 2> /dev/null)

screen_laptop=$(xrandr | grep " connected" | awk '{print $1}' | grep ^eDP)
screen_hdmi_1=$(xrandr | grep " connected" | awk '{print $1}' | grep ^HDMI | head -n 1)
screen_hdmi_2=$(xrandr | grep " connected" | awk '{print $1}' | grep ^HDMI | head -n 2 | tail -1)
screen_display_port_1=$(xrandr | grep " connected" | awk '{print $1}' | grep ^DP | head -n 1)
screen_display_port_2=$(xrandr | grep " connected" | awk '{print $1}' | grep ^DP | head -n 2 | tail -1)

if [[ -f "${i3_dir}/${layout}.layout.config" ]]; then
    i3_layout_config="${i3_dir}/${layout}.layout.config"
fi

# build final i3 config
cat "$i3_config_base" \
    "$i3_family_config" \
    "$i3_layout_config" > ${i3_dir}/config

sed -ri "s/<LAYOUT_NAME>/$layout/g" ${i3_dir}/config
sed -ri "s/<HDMI_1>/$screen_hdmi_1/g" ${i3_dir}/config
sed -ri "s/<HDMI_2>/$screen_hdmi_2/g" ${i3_dir}/config
sed -ri "s/<eDP>/$screen_laptop/g" ${i3_dir}/config
sed -ri "s/<DP_1>/$screen_display_port_1/g" ${i3_dir}/config
sed -ri "s/<DP_2>/$screen_display_port_2/g" ${i3_dir}/config

# Term font size
SCRIPT=$(readlink -f $0)
SCRIPTPATH=$(dirname $SCRIPT)
bash $SCRIPTPATH/scripts/term_font_size.sh

# Then reload/restart i3
i3-msg $action
