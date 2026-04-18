#!/bin/bash

mkdir -p $HOME/{.history,.bash_custom}
[[ -f $HOME/conf ]] && source $HOME/.bash_custom/conf

[[ -z $SOURCE ]] && export SOURCE=()

function common.export_shell () {
    export SHELL=$(readlink /proc/$$/exe)
}

function _date_millisecond {
    echo -n $(( $(date +%s%N) / 1000000 ))
}

function _get_sourceable_bash_files_ordered {
    find ~/.bash_aliases ~/.bash_custom/ ~/.shell/source ~/.shell/completions \
        -type f -follow -printf '%f %p\n' 2>/dev/null | \
        sort -n | \
        cut -d' ' -f2-
}

function common.is_already_sourced () {
    for f in "${SOURCE[@]}"; do
        [[ "$f" == "$1" ]] && return 0
    done
    return 1
}

function common.source
{
    target=$1
    [[ ! -f $target ]] && return
    common.is_already_sourced $target && >&2 echo "$target already sourced" && return
    [[ $ZSH_DEBUG -eq 1 ]] && start=$(_date_millisecond)
    builtin source $target
    [[ $ZSH_DEBUG -eq 1 ]] && end=$(_date_millisecond) && >&2 echo "[DEBUG] ($(( end - start )) ms) common.source $target"
    SOURCE+=("$target")
}

function common.source_all
{
    [[ $ZSH_DEBUG -eq 1 ]] && start_all=$(_date_millisecond)

    for src in $(_get_sourceable_bash_files_ordered); do
        [[ "$src" == *"terraform.sh" ]] && ! command -v terraform &> /dev/null && continue
        [[ "$src" == *"openstack.sh" ]] && ! command -v openstack &> /dev/null && continue
        [[ "$src" == *"k8s.sh" ]] && ! command -v kubectl &> /dev/null && continue
        common.source $src
    done

    [[ $ZSH_DEBUG -eq 1 ]] && end_all=$(_date_millisecond) && >&2 echo "[DEBUG] ($(( end_all - start_all )) ms) common.source_all"
}

function path.append
{
    case ":$PATH:" in
        *":$1:"*) PATH="$(path.remove $1):$1";;
        *) PATH="$PATH:$1";; # or PATH="$PATH:$1"
    esac
}

function path.prepend
{
    case ":$PATH:" in
        *":$1:"*) PATH="$1:$(path.remove $1)";;
        *) PATH="$1:$PATH";;
    esac
}

function path.remove
{
    local entry="$1"
    # Remove all instances of :entry: (middle)
    local result="${PATH//:$entry:/:}"
    # Remove trailing :entry
    result="${result%:$entry}"
    # Remove leading entry:
    result="${result#$entry:}"
    echo "$result"
}


for p in /bin /usr/bin /usr/sbin /snap/bin /usr/local/bin $HOME/bin $HOME/.local/bin; do
    [[ -e $p ]] && path.prepend $p
done
