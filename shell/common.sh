#!/bin/bash

[[ -d $HOME/.history && -d $HOME/.bash_custom ]] || mkdir -p $HOME/{.history,.bash_custom}
[[ -f $HOME/conf ]] && source $HOME/.bash_custom/conf

[[ -z $SOURCE ]] && export SOURCE=()

function common.export_shell () {
    if [[ -n $ZSH_VERSION ]]; then
        # builtin readlink: no fork
        zmodload -F zsh/stat b:zstat
        local -a link
        zstat -A link +link /proc/$$/exe && export SHELL=${link[1]}
    else
        export SHELL=$(readlink /proc/$$/exe)
    fi
}

function _date_millisecond {
    echo -n $(( $(date +%s%N) / 1000000 ))
}

# Fill _SOURCEABLE_FILES with files to source, ordered like `sort -n` on basename:
# numeric prefix first (00-*, 10-*...), files without prefix sort as 1 (after 00-*).
function _get_sourceable_bash_files_ordered {
    _SOURCEABLE_FILES=()
    if [[ -n $ZSH_VERSION ]]; then
        # pure zsh globbing: no fork. eval: bash must not parse zsh syntax.
        eval '
        local -a entries
        local f name num
        for f in ~/.bash_aliases(N-.) ~/.bash_custom/*(N-.) ~/.shell/source/*(N-.) ~/.shell/completions/*(N-.); do
            name=${f:t}
            num=${name%%[^0-9]*}
            entries+=("${(l:3::0:)${num:-1}} $name $f")
        done
        _SOURCEABLE_FILES=(${${(o)entries}#* * })
        '
    else
        mapfile -t _SOURCEABLE_FILES < <(
            find ~/.bash_aliases ~/.bash_custom/ ~/.shell/source ~/.shell/completions \
                -type f -follow -printf '%f %p\n' 2>/dev/null | \
                sort -n | \
                cut -d' ' -f2-
        )
    fi
}

# common.cache_cmd_output FILE BIN CMD...
# Run CMD... once and cache its stdout in FILE (e.g. "kubectl completion zsh",
# "direnv hook zsh"), regenerated only when binary BIN is newer than FILE.
# Returns 1 when BIN is not installed or CMD fails.
# zsh completions go to ~/.cache/shell/completions/_NAME (dir is in fpath,
# autoloaded on first use); anything else goes to ~/.cache/shell/NAME.
function common.cache_cmd_output {
    local file=$1 bin=$2 bin_path
    shift 2
    if [[ -n $ZSH_VERSION ]]; then
        bin_path=${commands[$bin]}
    else
        bin_path=$(type -P "$bin")
    fi
    [[ -n $bin_path ]] || return 1
    if [[ ! -f $file || $bin_path -nt $file ]]; then
        [[ -d ${file%/*} ]] || mkdir -p "${file%/*}"
        "$@" > "$file" 2>/dev/null || { rm -f "$file"; return 1; }
    fi
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

    _get_sourceable_bash_files_ordered
    for src in "${_SOURCEABLE_FILES[@]}"; do
        [[ "$src" == *"terraform.sh" ]] && ! command -v terraform &> /dev/null && continue
        [[ "$src" == *"openstack.sh" ]] && ! command -v openstack &> /dev/null && continue
        [[ "$src" == *"k8s.sh" ]] && ! command -v kubectl &> /dev/null && continue
        common.source $src
    done

    [[ $ZSH_DEBUG -eq 1 ]] && end_all=$(_date_millisecond) && >&2 echo "[DEBUG] ($(( end_all - start_all )) ms) common.source_all"
}

# path.* work in place on PATH, no subshell
function path.remove
{
    local entry="$1"
    local result=":$PATH:"
    while [[ "$result" == *":$entry:"* ]]; do
        result="${result//:$entry:/:}"
    done
    result="${result#:}"
    result="${result%:}"
    PATH="$result"
}

function path.append
{
    path.remove "$1"
    PATH="${PATH:+$PATH:}$1"
}

function path.prepend
{
    path.remove "$1"
    PATH="$1${PATH:+:$PATH}"
}


for p in /bin /usr/bin /usr/sbin /snap/bin /usr/local/bin $HOME/bin $HOME/.local/bin; do
    [[ -e $p ]] && path.prepend $p
done
