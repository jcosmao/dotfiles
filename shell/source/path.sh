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


for p in $HOME/.local/bin /usr/local/sbin /usr/local/bin /snap/bin /usr/sbin /usr/bin /sbin /bin; do
    path.append $p
done


