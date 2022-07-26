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
    for src in $(find ~/.shell -type f -follow -name '*.source' ); do
        source $src
    done
fi


# Not versionned
if [[ -e ~/.bash_custom ]]; then
    # copy locally profiles.d
    [[ ! -e ~/.bash_custom/profile.d ]] && cp -r /etc/profile.d ~/.bash_custom 2> /dev/null
    for src in $(find ~/.bash_custom -type f -follow -regextype posix-extended -regex '.*\.(source|sh)'); do
        source $src
    done
fi
