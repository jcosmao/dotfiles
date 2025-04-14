eval $(dircolors -b ~/.dir_colors)

alias ls='ls --color=auto'
alias dir='dir --color=auto'

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias c='ccze -A'

# Normal colors
export BLACK="\e[0;30m"
export RED="\e[0;31m"
export GREEN="\e[0;32m"
export YELLOW="\e[0;33m"
export BLUE="\e[0;34m"
export MAGENTA="\e[0;35m"
export CYAN="\e[0;36m"
export GREY="\e[0;37m"
export WHITE="\e[0;37m"

# Bright colors
export B_BLACK="\e[0;90m"
export B_RED="\e[0;91m"
export B_GREEN="\e[0;92m"
export B_YELLOW="\e[0;93m"
export B_BLUE="\e[0;94m"
export B_MAGENTA="\e[0;95m"
export B_CYAN="\e[0;96m"

export NORMAL="\e[0m"          # text reset
export BOLD="\e[1m"            # make bold
export UNDERLINE="\e[4m"       # underline
export BLINK="\e[5m"           # make blink
export REVERSE="\e[7m"         # reverse


function colors.display_256_colors ()
{
    for i in `seq 1 256`
    do
        tput setaf $i
        echo -n "$i "
    done
}

alias dcolors="colors.display_256_colors"

function colors.prompt_print {
    # colors.print 42 plop
    code=$1; shift;
    color_code=$(tput setaf $code)
    color_reset=$(tput sgr0)
    # https://unix.stackexchange.com/questions/158412/are-the-terminal-color-escape-sequences-defined-anywhere-for-bash
    prompt_escaped_color="\[$color_code\]"
    prompt_escaped_reset="\[$color_reset\]"
    echo -e ${prompt_escaped_color}$*${prompt_escaped_reset}
}

function colors.print {
    # colors.print 42 plop
    code=$1; shift;
    color_code=$(tput setaf $code)
    color_reset=$(tput sgr0)
    echo -e ${color_code}$*${color_reset}
}
