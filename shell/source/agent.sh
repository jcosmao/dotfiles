#!/bin/bash

export SSH_AUTH_SOCK=~/.cache/ssh-agent.sock
# prompt for GPG passphrase when needed
export GPG_TTY=$(tty)

function launch_ssh_agent ()
{
    ssh_agent_cmd="ssh-agent -s -t 36000 -a ${SSH_AUTH_SOCK}"

    if [[ -f ~/.ssh-agent ]]; then
        eval "$(<~/.ssh-agent)" >/dev/null
    fi

    if env | grep -q SSH_AGENT_PID=; then
        cmd=$(ps --no-headers -o cmd $SSH_AGENT_PID)
        if [[ $ssh_agent_cmd != $cmd ]]; then
            kill $SSH_AGENT_PID &> /dev/null
        fi
    fi

    output=$(ssh-add -l 2> /dev/null)
    rc=$?
    # Seems no ssh-agent running
    if [[ $rc -eq 2 ]]; then
        # Try to export ssh-agent env
        rm -f $SSH_AUTH_SOCK
        (umask 066; ssh-agent -s -t 36000 -a ${SSH_AUTH_SOCK} > ~/.ssh-agent)
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