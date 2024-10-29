# source in last position because it need cr_* aliases already defined

function tmux.list_cr
{
    alias | grep ^cr_ | cut -d= -f1 | sed -re 's/cr_//'
}

function tmux.set_cr_env
{
    crenv="$1"

    if tmux.list_cr | grep -q "^${crenv}$" ; then
        tmux set-environment CR_COMMAND "cr_${crenv}"
        eval "cr_${crenv}"
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

if [[ -n $TMUX ]]; then
    session_name=$(tmux display-message -p '#S')
    [[ -z $CR_COMMAND ]] && tmux.set_cr_env $session_name
fi

if [[ -n $CR_COMMAND ]]; then
    eval $CR_COMMAND
fi
