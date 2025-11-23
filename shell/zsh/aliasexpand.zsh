# Definition of alias for auto-expanding aliases
typeset -ga _vbe_abbrevations

alias() {
    builtin alias $1
    [[ $1 =~ ^(ls|dir|grep)=.*$ ]] && return
    _vbe_abbrevations+=(${1%%\=*})
}

_vbe_zle-autoexpand() {
    local -a words; words=(${(z)LBUFFER})
    if (( ${#_vbe_abbrevations[(r)${words[-1]}]} )); then
        zle _expand_alias
    fi
    zle magic-space
}

zle -N _vbe_zle-autoexpand
bindkey -M emacs " " _vbe_zle-autoexpand
bindkey -M isearch " " magic-space
