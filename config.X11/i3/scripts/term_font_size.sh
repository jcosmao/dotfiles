#!/usr/bin/env bash

layout=$(autorandr |& grep detected | awk '{print $1}')

if [[ $layout == 'laptop' ]]; then
    echo "Set alacritty font size to '12'"
    sed -ri "s,^(\s*size:\s*).*,\112," $HOME/.config/alacritty/alacritty.yml
else
    echo "Set alacritty font size to '12'"
    sed -ri "s,^(\s*size:\s*).*,\112," $HOME/.config/alacritty/alacritty.yml
fi
