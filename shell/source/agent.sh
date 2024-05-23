#!/bin/bash

# prompt for GPG passphrase when needed
export GPG_TTY=$(tty)

function launch_ssh_agent
{
    # cache key for 10h
    ssh_agent_cmd="ssh-agent -s -t 36000"
    agent_pid=$(pidof ssh-agent | awk '{print $1}')

    if [[ -z $agent_pid && -n $SSH_AUTH_SOCK && -S $SSH_AUTH_SOCK  ]]; then
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

    ssh-add -l 2> /dev/null; rc=$?
    # no ssh-agent running
    if [[ $rc == 2 ]]; then
        # Try to export ssh-agent env
        (umask 066; eval "$ssh_agent_cmd" >| ~/.ssh-agent)
        eval "$(<~/.ssh-agent)" >/dev/null
        ssh-add $(ls ~/.ssh/*.pub | sed -re 's/\.pub$//') 2> /dev/null
    elif [[ $rc == 1 ]]; then
        # Add default ssh-key to agent cache
        ssh-add $(ls ~/.ssh/*.pub | sed -re 's/\.pub$//') 2> /dev/null
    else
        return
    fi
}

launch_ssh_agent
