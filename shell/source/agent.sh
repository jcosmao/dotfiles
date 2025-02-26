#!/bin/bash

# prompt for GPG passphrase when needed
export GPG_TTY=$(tty)

function agent.launch_ssh_agent
{
    # cache key for 10h
    ssh_agent_cmd="ssh-agent -s -t 36000"
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

    eval "$(cat ~/.ssh-agent 2> /dev/null)" >/dev/null
    if [[ -n $SSH_AGENT_PID ]]; then
        cmd=$(ps --no-headers -o cmd "$SSH_AGENT_PID")
        if [[ $ssh_agent_cmd != "$cmd" ]]; then
            kill "$SSH_AGENT_PID" &> /dev/null
        fi
    fi

    sshadd_out=$(ssh-add -l 2> /dev/null); rc=$?
    sshadd_len=$(echo $sshadd_out | wc -l)
    lspub_len=$(ls ~/.ssh/*.pub | wc -l)

    # no ssh-agent running
    if [[ $rc == 2 ]]; then
        # Try to export ssh-agent env
        (umask 066; eval "$ssh_agent_cmd" >| ~/.ssh-agent)
        eval "$(<~/.ssh-agent)" >/dev/null
        ssh-add $(ls ~/.ssh/*.pub | sed -re 's/\.pub$//') 2> /dev/null
    elif [[ $rc == 1 || ($rc == 0 && $sshadd_len < $lspub_len) ]]; then
        # Add default ssh-key to agent cache
        ssh-add $(ls ~/.ssh/*.pub | sed -re 's/\.pub$//') 2> /dev/null
    else
        return
    fi
}

if [[ -z $SSH_TTY ]]; then
    if [[ $SHELL =~ zsh ]]; then
        export PERIOD=120
        autoload -U add-zsh-hook
        add-zsh-hook periodic "agent.launch_ssh_agent"

        # launch ssh-agent at shell startup if it is not running yet, else use async mechanism
        pgrep ssh-agent &> /dev/null || agent.launch_ssh_agent
    else
        agent.launch_ssh_agent
    fi
fi
