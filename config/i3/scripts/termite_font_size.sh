#!/usr/bin/env bash

layout=$(autorandr |& grep detected | awk '{print $1}')

if [[ $layout == 'laptop' ]]; then
    echo "Set termite font size to '10'"
    sed -ri 's,^(font.*) [0-9]+$,\1 10,' $HOME/.config/termite/config
else
    echo "Set termite font size to '8'"
    sed -ri 's,^(font.*) [0-9]+$,\1 8,' $HOME/.config/termite/config
fi
