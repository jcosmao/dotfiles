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

# source bash aliases/completion/functions
[[ -e ~/.bash_aliases ]] && source ~/.bash_aliases

if [[ -e ~/.shell ]]; then
    for src in $(find ~/.shell/ -type f -follow -name '*.sh' ); do
        source $src
    done
fi

[[ -d ~/.shell/completions ]] && source ~/.shell/completions/*

for dir in /etc/profile.d/ ~/.bash_custom/; do
    if [[ -d $dir ]]; then
        for src in $(find $dir -type f -name '*.sh'); do source $src 2> /dev/null; done
    fi
done
