#!/bin/bash

user=${LC_BASTION:-$USER}

tmux -L $user list-windows -F '#{window_id} #{window_name}' | while read id name; do
    echo $name | grep -Pq $1 && \
    tmux -L $user select-window -t "$id" && \
    exit
done

exit 0
