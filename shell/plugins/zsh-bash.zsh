#
# bash compatibility plugin
#

# rewrite 'source' to be more bash friendly
function source_bash() {
  alias shopt=':'
  alias _expand=_bash_expand
  alias _complete=_bash_comp
  emulate -L sh
  setopt kshglob noshglob braceexpand

  builtin source "$@"
}

function fg() {
    if [[ $# -eq 1 && $1 = - ]]; then
        builtin fg %-
    else
        builtin fg %"$@"
    fi
}

alias .='source'

# allow regex
setopt NO_NOMATCH

autoload -U +X bashcompinit && bashcompinit

# source bash aliases/completion/functions
[[ -e ~/.bash_aliases ]] && source ~/.bash_aliases

if [[ -e ~/.shell ]]; then
    for src in $(find ~/.shell/completions -type f -follow -name '*.source' ); do
        source $src
    done
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
