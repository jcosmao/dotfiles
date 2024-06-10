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

function _get_sourceable_bash_files_ordered
{
    find /etc/profile.d/ ~/.bash_custom/ ~/.shell/ -type f -follow -name '*.sh'  2> /dev/null | while read file;do
        echo $(basename $file) $file
    done | sort -n | awk '{print $2}'
}

for src in $(_get_sourceable_bash_files_ordered); do
    source $src
done

# source bash aliases/completion/functions
[[ -e ~/.bash_aliases ]] && source ~/.bash_aliases
[[ -d ~/.shell/completions ]] && source ~/.shell/completions/*

