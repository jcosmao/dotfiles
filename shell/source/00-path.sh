type path.append &> /dev/null && return

function path.append
{
    case ":$PATH:" in
        *":$1:"*) PATH="$(path.remove $1):$1";;
        *) PATH="$PATH:$1";; # or PATH="$PATH:$1"
    esac
}

function path.prepend
{
    case ":$PATH:" in
        *":$1:"*) PATH="$1:$(path.remove $1)";;
        *) PATH="$1:$PATH";;
    esac
}

function path.remove
{
    for i in $(echo $PATH | tr -s ':' ' '); do
        [[ ! $i = $1 ]] && echo $i
    done | paste -d: -s
}


for p in /bin /usr/bin /usr/sbin /snap/bin /usr/local/bin $HOME/.local/bin; do
    path.prepend $p
done
