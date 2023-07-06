#!/bin/bash

# prompt for GPG passphrase when needed
export GPG_TTY=$(tty)

function launch_ssh_agent
{
    if [[ -n $SSH_AUTH_SOCK && -S $SSH_AUTH_SOCK  ]]; then
        # SSH agent forwarded, nothing to spawn
        return
    fi

    # cache key for 10h
    ssh_agent_cmd="ssh-agent -s -t 36000"
    eval "$(<~/.ssh-agent)" >/dev/null

    if [[ -n $SSH_AGENT_PID ]]; then
        cmd=$(ps --no-headers -o cmd $SSH_AGENT_PID)
        if [[ $ssh_agent_cmd != $cmd ]]; then
            kill $SSH_AGENT_PID &> /dev/null
        fi
    fi

    output=$(ssh-add -l 2> /dev/null); rc=$?
    # no ssh-agent running
    if [[ $rc -eq 2 ]]; then
        # Try to export ssh-agent env
        (umask 066; ssh-agent -s -t 36000 > ~/.ssh-agent)
        eval "$(<~/.ssh-agent)" >/dev/null
        ssh-add 2> /dev/null
    elif [[ $rc -eq 1 ]]; then
        # Add default ssh-key to agent cache
        ssh-add 2> /dev/null
    else
        return
    fi
}

launch_ssh_agent
