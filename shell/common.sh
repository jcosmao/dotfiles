#!/bin/bash

mkdir -p $HOME/{.history,.bash_custom}

[[ -z $SOURCE ]] && export SOURCE=()

function common.export_shell () {
    export SHELL=$(readlink /proc/$$/exe)
}

function _date_millisecond {
    echo -n $(( $(date +%s%N) / 1000000 ))
}

function _get_sourceable_bash_files_ordered
{
    # skip /etc/profile
    # [[ ! $(hostname -s) =~ ^laptop ]] && echo /etc/profile
    find ~/.bash_custom/ ~/.shell/source ~/.shell/completions -type f -follow  2> /dev/null | while read file;do
        echo "$(basename "$file") $file"
    done | sort -n | awk '{print $2}'
    echo ~/.bash_aliases
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
    end=$(_date_millisecond)
    [[ $ZSH_DEBUG -eq 1 ]] && >&2 echo "[DEBUG] ($(( end - start )) ms) common.source $target"
    SOURCE+=("$target")
}

function common.source_all
{
    for src in $(_get_sourceable_bash_files_ordered); do
        [[ $(basename $src) = "go.sh" ]] && ! which go &> /dev/null && continue
        [[ $(basename $src) = "rust.sh" ]] && [[ ! -d $HOME/.cargo ]] && continue
        [[ $(basename $src) = "terraform.sh" ]] && ! which terraform &> /dev/null && continue
        [[ $(basename $src) = "openstack.sh" ]] && ! which openstack &> /dev/null && continue
        [[ $(basename $src) = "ruby.sh" ]] && ! which ruby &> /dev/null && continue
        [[ $(basename $src) = "90-k8s.sh" ]] && ! which kubectl &> /dev/null && continue
        [[ $(basename $src) = "gpg.sh" ]] && [[ ! -e $HOME/.gnupg ]] && continue
        common.source $src
    done
}
