eval $(dircolors -b ~/.dir_colors)

alias ls='ls --color=auto'
alias dir='dir --color=auto'

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias c='ccze -A'

# COLORS
# regular
black="\033[0;30m"
red="\033[0;31m"
green="\033[0;32m"
yellow="\033[0;33m"
blue="\033[0;34m"
magenta="\033[0;35m"
cyan="\033[0;36m"
grey="\033[0;37m"
white="\033[1;37m"

# bright
b_black="\033[1;30m"
b_red="\033[1;31m"
b_green="\033[1;32m"
b_yellow="\033[1;33m"
b_blue="\033[1;34m"
b_magenta="\033[1;35m"
b_cyan="\033[1;36m"

normal="\033[0;0m"          # text reset
mkbold="\033[0;1m"          # make bold
undrln="\033[0;4m"          # underline
mkblnk="\033[0;5m"          # make blink
revers="\033[0;7m"          # reverse


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
