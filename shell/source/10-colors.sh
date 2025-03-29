eval $(dircolors -b ~/.dir_colors)

alias ls='ls --color=auto'
alias dir='dir --color=auto'

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias c='ccze -A'

# COLORS
# regular
export BLACK=$(tput setaf 0)
export RED=$(tput setaf 1)
export GREEN=$(tput setaf 2)
export YELLOW=$(tput setaf 3)
export BLUE=$(tput setaf 4)
export MAGENTA=$(tput setaf 5)
export CYAN=$(tput setaf 6)
export GREY=$(tput setaf 7)
export WHITE=$(tput setaf 15)

# bright
export B_BLACK=$(tput setaf 8)
export B_RED=$(tput setaf 9)
export B_GREEN=$(tput setaf 10)
export B_YELLOW=$(tput setaf 11)
export B_BLUE=$(tput setaf 12)
export B_MAGENTA=$(tput setaf 13)
export B_CYAN=$(tput setaf 14)

export NORMAL=$(tput sgr0)          # text reset
export BOLD=$(tput bold)          # make bold
export UNDERLINE=$(tput smul)       # underline
export BLINK=$(tput blink)        # make blink
export REVERSE=$(tput rev)          # reverse

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
