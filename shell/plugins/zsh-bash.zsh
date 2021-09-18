#
# bash compatibility plugin
#

function fg() {
    if [[ $# -eq 1 && $1 = - ]]; then
        builtin fg %-
    else
        builtin fg %"$@"
    fi
}

# allow regex
setopt NO_NOMATCH

# source bash aliases/completion/functions
[[ -e ~/.bash_aliases ]] && source ~/.bash_aliases

if [[ -e ~/.shell ]]; then
    for src in $(find ~/.shell/functions -type f -follow -name '*.source' ); do
        source $src
    done
fi

# Not versionned
if [[ -e ~/.bash_custom ]]; then
    for src in $(find ~/.bash_custom -type f -follow -name '*.source' ); do
        source $src
    done
fi
