type path.append &> /dev/null && return

function path.append
{
    case ":$PATH:" in
        *":$1:"*) :;; # already there
        *) PATH="$PATH:$1";; # or PATH="$PATH:$1"
    esac
}

function path.prepend
{
    case ":$PATH:" in
        *":$1:"*) :;; # already there
        *) PATH="$1:$PATH";; # or PATH="$PATH:$1"
    esac
}


for p in /bin /usr/bin /usr/sbin /snap/bin /usr/local/bin $HOME/.local/bin; do
    path.prepend $p
done


