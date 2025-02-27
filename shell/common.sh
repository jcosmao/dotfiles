#!/bin/bash

mkdir -p $HOME/{.history,.bash_custom}

[[ -z $SOURCE ]] && export SOURCE=()

function export_shell () {
    export SHELL=$(readlink /proc/$$/exe)
}

function append_path () {
    case ":$PATH:" in
        *:"$1":*)
            ;;
        *)
            PATH="${PATH:+$PATH:}$1"
    esac
}

function date_millisecond {
    echo -n $(( $(date +%s%N) / 1000000 ))
}

function common.get_sourceable_bash_files_ordered
{
    # skip /etc/profile
    [[ ! $(hostname -s) =~ ^laptop ]] && echo /etc/profile
    find ~/.bash_custom/ ~/.shell/source ~/.shell/completions -type f -follow  2> /dev/null | while read file;do
        echo "$(basename "$file") $file"
    done | sort -n | awk '{print $2}'
}

function is_already_sourced
{
    for f in "${SOURCE[@]}"; do
        [[ "$f" == "$1" ]] && return 0
    done
    return 1

}

function common.source
{
    for target in $*; do
        is_already_sourced $target && >&2 echo "$target already sourced" && continue
        [[ $ZSH_DEBUG -eq 1 ]] && start=$(date_millisecond)
        builtin source $target
        end=$(date_millisecond)
        [[ $ZSH_DEBUG -eq 1 ]] && >&2 echo "[DEBUG] ($(( end - start )) ms) common.source $target"
        SOURCE+=("$target")
    done
}
