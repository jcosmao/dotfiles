#!/bin/bash

user=${LC_BASTION:-$USER}

tmux -L $user list-windows | awk -v user="$user" -F: '{system("tmux -L "user" move-window -s "$1" -t 100"$1)}'
tmux -L $user list-windows | sort -sk2 | awk -v user="$user" -F: '{system("tmux -L "user" move-window -s "$1" -t "(NR))}'
