#!/bin/bash

function append_path () {
    case ":$PATH:" in
        *:"$1":*)
            ;;
        *)
            PATH="${PATH:+$PATH:}$1"
    esac
}

function common.get_sourceable_bash_files_ordered
{
    find /etc/profile ~/.bash_custom/ ~/.shell/source ~/.shell/completions -type f -follow  2> /dev/null | while read file;do
        echo "$(basename "$file") $file"
    done | sort -n | awk '{print $2}'
}

[[ -z $SOURCE ]] && export SOURCED=()

function is_already_sourced
{
    for f in "${SOURCE[@]}"; do
        [[ $f = "$1" ]] && return 0
    done
    return 1
}

function common.source
{
    for target in $*; do
        is_already_sourced $target && echo "$target already sourced" && continue
        builtin source $target
        SOURCE+=("$target")
    done
}
