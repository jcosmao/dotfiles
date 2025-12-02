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
common.source_all
