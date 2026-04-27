# System setup: SSH agent, network namespace

# ========================================
# SSH Agent
# ========================================
[[ ! -d $HOME/.ssh ]] && return

function agent.launch_ssh_agent
{
    [[ $SSH_TTY && -n $SSH_AUTH_SOCK && -S $SSH_AUTH_SOCK ]] && return

    lifetime=${SSH_AGENT_CACHE_SECONDS:-36000}

    AGENT_CACHE="${HOME}/.ssh/agent.${lifetime}.cache"

    if [[ -f $AGENT_CACHE ]]; then
        eval "$( < $AGENT_CACHE)" >/dev/null 2>&1
        cache_age=$(( $(date +%s) - $(stat -c %Y "$AGENT_CACHE") ))
        [[ $cache_age -lt $lifetime && -n $SSH_AGENT_PID ]] && \
            kill -0 "$SSH_AGENT_PID" 2>/dev/null && return
    else
        pkill ssh-agent -u $USER 2>/dev/null
    fi

    [[ -n $SSH_AGENT_PID ]] && kill $SSH_AGENT_PID 2>/dev/null
    (umask 066; ssh-agent -s -t $lifetime >| $AGENT_CACHE)
    eval "$( < $AGENT_CACHE)" >/dev/null
    ssh-add $(ls ~/.ssh/*.pub 2>/dev/null | sed -re 's/\.pub$//') 2>/dev/null
}

if [[ -z $SSH_TTY ]]; then
    if [[ $SHELL =~ zsh ]]; then
        autoload -U add-zsh-hook
        # Check and respawn ssh-agent before each prompt if expired
        add-zsh-hook precmd agent.launch_ssh_agent 2>/dev/null
    else
        agent.launch_ssh_agent
    fi
fi

# ========================================
# Network Namespace
# ========================================
netns.enter () {
    name=$1; shift
    [[ -z $name ]] && echo "Missing netns name" && return

    if [[ $name == "default" ]]; then
        nsenter -t 1 -n $*
    else
        [[ $# -eq 0 ]] && ip netns exec $name $SHELL || ip netns exec $name $*
    fi
}

alias nse=netns.enter
alias ons=netns.enter

function _complete_nse
{
    [[ $COMP_CWORD -ne 1 ]] && return
    local word=${COMP_WORDS[1]}
    COMPREPLY=($(compgen -W "$(ip netns list | awk '{print $1}' | xargs)" -- ${word}))
}

complete -F _complete_nse netns.enter
complete -F _complete_nse nse
complete -F _complete_nse ons

netns.current () {
    ip netns identify $$
    # netns=$(lsns -p $$ -t net -no NSFS)
    # [[ -n $netns ]] && basename $netns
}

netns.ps () {
    ps ef $(ip netns pids $(netns.current))
}

netns.docker_mount () {(
    set -e
    name=$1
    pid=$(docker inspect -f '{{.State.Pid}}' $name)
    [[ ! -d /var/run/netns/ ]] && mkdir -p /var/run/netns/
    ln -sfT /proc/$pid/ns/net /var/run/netns/$name
    netns.enter $name
)}
