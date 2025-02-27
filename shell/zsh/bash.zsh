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
[[ -e ~/.bash_aliases ]] && common.source ~/.bash_aliases

common.source $(common.get_sourceable_bash_files_ordered)
