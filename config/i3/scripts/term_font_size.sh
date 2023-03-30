#!/usr/bin/env bash

layout=$(autorandr |& grep detected | awk '{print $1}')

if [[ $layout == 'laptop' ]]; then
    echo "Set termite font size to '10'"
    sed -ri 's,^(font.*) [0-9]+$,\1 10,' $HOME/.config/termite/config

 uto   echo "Set alacritty font size to '12'"
    sed -ri "s,^(\s*size:\s*).*,\1 12," $HOME/.config/alacritty/alacritty.yml
else
    echo "Set termite font size to '8'"
    sed -ri 's,^(font.*) [0-9]+$,\1 8,' $HOME/.config/termite/config

    echo "Set alacritty font size to '12'"
    sed -ri "s,^(\s*size:\s*).*,\1 12," $HOME/.config/alacritty/alacritty.yml
fi
