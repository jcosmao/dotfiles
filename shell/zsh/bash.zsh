#
# bash compatibility plugin
#

function fg {
    if [[ $# -eq 1 && $1 = - ]]; then
        builtin fg %-
    else
        builtin fg %"$@"
    fi
}

# allow regex
setopt NO_NOMATCH

source $HOME/.shell/common.sh

# source bash aliases/completion/functions
for src in $(common.get_sourceable_bash_files_ordered); do
    common.source $src
done

[[ -e ~/.bash_aliases ]] && common.source ~/.bash_aliases
# [[ -d ~/.shell/completions ]] && common.source ~/.shell/completions/*

