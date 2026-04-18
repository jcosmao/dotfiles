#!/bin/bash

user=${LC_BASTION:-$USER}

if [[ $# == 0 ]]; then
    echo "$0 <target window index> <window index to mv: default=current>"
    exit 1
fi

target_index=$1
current=$(tmux -L $user display-message -p -F '#{window_index}')
current_window=${2:-$current}

if [[ $target_index > $current_window ]]; then
    min=$current_window
    max=$target_index
    run=1
else
    min=$target_index
    max=$current_window
    run=$(( max - min ))
fi

tmux -L $user select-window -t $min

for r in $(seq 1 $run); do
    for ((i=$min; i<$max; i++))
    do
        tmux -L $user swap-window -s :$i -t :$((i+1))
    done
done

tmux -L $user select-window -t $target_index
