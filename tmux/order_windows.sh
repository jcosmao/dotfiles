#!/bin/bash

tmux -L $USER list-windows | awk -F: '{system("tmux -L $USER move-window -s "$1" -t 100"$1)}'
tmux -L $USER list-windows | sort -sk2 | awk -F: '{system("tmux -L $USER move-window -s "$1" -t "(NR))}'

