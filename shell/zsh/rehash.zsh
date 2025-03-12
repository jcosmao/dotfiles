autoload -U add-zsh-hook

# rehash on SIGUSR1
TRAPUSR1() { rehash };

# anything newly intalled from last command?
precmd_install() {
    cmd=$history[$[ HISTCMD -1 ]]
    [[ $cmd =~ ^(apt|apt-get|yay|pacman|pamac|pip) ]] && killall -u $USER -USR1 zsh
}

# do this on precmd
add-zsh-hook precmd precmd_install
