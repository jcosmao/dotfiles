# source in last position because it need cr_* aliases already defined

function tmux.set_cr_env
{
    crenv="$1"
    tmux set-environment CR_COMMAND "cr ${crenv}"
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
    [[ -n $CR_COMMAND ]] && eval $CR_COMMAND 2> /dev/null
fi
