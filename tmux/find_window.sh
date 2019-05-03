#!/bin/bash

tmux -L $USER list-windows -F '#{window_id} #{window_name}' | while read id name; do
    echo $name | grep -Pq $1 && \
    tmux -L $USER select-window -t "$id" && \
    exit
done

exit 0
