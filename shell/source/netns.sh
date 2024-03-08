netns.enter () {
    ip netns exec $1 $SHELL
}

alias nse=netns.enter

function _complete_nse
{
    local word=${COMP_WORDS[1]}
    COMPREPLY=($(compgen -W "$(ip netns list | awk '{print $1}' | xargs)" -- ${word}))
}

complete -F _complete_nse netns.enter
complete -F _complete_nse nse

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
