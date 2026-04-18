# System setup: SSH agent, network namespace

# ========================================
# SSH Agent
# ========================================
[[ ! -d $HOME/.ssh ]] && return

function agent.launch_ssh_agent
{
    AGENT_CACHE="${HOME}/.ssh/agent.conf"
    mkdir -p $(dirname $AGENT_CACHE)
    touch $AGENT_CACHE

    ssh_agent_cmd="ssh-agent -s -t ${SSH_AGENT_CACHE_SECONDS:-36000}"
    agent_pid=$(pgrep ssh-agent -u $USER -n)

    if [[ -z $agent_pid && $SSH_TTY && -n $SSH_AUTH_SOCK && -S $SSH_AUTH_SOCK ]]; then
        # SSH agent forwarded, nothing to spawn
        return
    fi

    # check current agent
    if [[ -n $agent_pid ]]; then
        cmd=$(ps --no-headers -o cmd "$agent_pid")
        if [[ $ssh_agent_cmd != "$cmd" ]]; then
            kill "$agent_pid" &> /dev/null
        fi
    fi

    eval "$(cat $AGENT_CACHE 2> /dev/null)" >/dev/null
    if [[ -n $SSH_AGENT_PID ]]; then
        cmd=$(ps --no-headers -o cmd "$SSH_AGENT_PID")
        if [[ $ssh_agent_cmd != "$cmd" ]]; then
            kill "$SSH_AGENT_PID" &> /dev/null
        fi
    fi

    sshadd_out=$(ssh-add -l 2> /dev/null); rc=$?
    sshadd_len=$(echo $sshadd_out | wc -l)
    lspub_len=$(ls ~/.ssh/*.pub 2> /dev/null | wc -l)

    # no ssh-agent running
    if [[ $rc == 2 ]]; then
        # Try to export ssh-agent env
        (umask 066; eval "$ssh_agent_cmd" >| $AGENT_CACHE)
        eval "$(< $AGENT_CACHE)" >/dev/null
        ssh-add $(ls ~/.ssh/*.pub 2> /dev/null | sed -re 's/\.pub$//') 2> /dev/null
    elif [[ $rc == 1 || ($rc == 0 && $sshadd_len < $lspub_len) ]]; then
        # Add default ssh-key to agent cache
        ssh-add $(ls ~/.ssh/*.pub 2> /dev/null | sed -re 's/\.pub$//') 2> /dev/null
    else
        return
    fi
}

_agent_init() {
    [[ -n $AGENT_INIT_DONE ]] && return
    agent.launch_ssh_agent
    export AGENT_INIT_DONE=1
}

if [[ -z $SSH_TTY ]]; then
    if [[ $SHELL =~ zsh ]]; then
        export PERIOD=120
        autoload -U add-zsh-hook
        add-zsh-hook periodic _agent_init
        # launch ssh-agent lazily on first prompt
        add-zsh-hook precmd _agent_init 2>/dev/null
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
