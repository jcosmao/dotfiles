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
