# source in last position because it need cr_* aliases already defined

function tmux.list_cr
{
    alias | grep ^cr_ | cut -d= -f1
}

function tmux.set_cr_env
{
    crenv="$1"

    if tmux.list_cr | grep -q "^${crenv}$" ; then
        tmux set-environment CR_COMMAND "$crenv"
        eval "$crenv"
    fi
}

alias tmcr=tmux.set_cr_env

function _complete_tmcr
{
    local word=${COMP_WORDS[1]}
    COMPREPLY=($(compgen -W "$(tmux.list_cr | xargs)" -- ${word}))
}

complete -F _complete_tmcr tmux.set_cr_env
complete -F _complete_tmcr tmcr

if [[ -n $CR_COMMAND ]]; then
    eval $CR_COMMAND
fi
