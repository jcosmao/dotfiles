function prompt.display
{
    history -a
    triangle='❭'
    PS1=$(printf "\n %s %s\n ${green}${triangle}${normal} " "$(prompt_left)" "$(prompt_add)")
}

function prompt_add
{
    add=''
    if git branch > /dev/null 2>&1 ; then
        add=$(set_git)
    fi

    if test -n "$VIRTUAL_ENV" ; then
        add="${add} $(set_virtualenv)"
    fi

    echo $add
}

function prompt_left
{
    PROMPT_LEFT=''
    PROMPT_COLOR=$b_blue
    left_color=$PROMPT_COLOR

    [[ "`id -u`" -eq 0 ]] && left_color=${b_red}

    if [[ -n $SSH_TTY ]]; then
        PROMPT_LEFT="${yellow}\u${b_black}@${left_color}\H${normal}"
    else
        PROMPT_LEFT="${left_color}\u:${normal}"
    fi

    echo "${PROMPT_LEFT} ${b_black}\w${normal}"
}

function set_git
{
    repo=$(basename -s .git $(git config --get remote.origin.url) 2> /dev/null)
    branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
    commit_id=$(git rev-parse --short HEAD 2> /dev/null)
    modified=$( git status --porcelain | grep -c '^ M')
    removed=$( git status --porcelain | grep -c '^ D')
    commit=''
    if [[ $removed -ne 0 || $modified -ne 0 ]]; then
        commit=${yellow}${normal}
    else
        commit=${green}${normal}
    fi

    echo "$(tput setaf 204)[󰊢 $repo] ${b_black}${branch}${magenta}[${commit_id}]${normal} ${commit}  "
}

function set_virtualenv
{
    echo "${b_yellow}[ $(basename $VIRTUAL_ENV)]${normal}"
}
