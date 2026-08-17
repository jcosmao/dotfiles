function prompt.display
{
    history -a
    PS1=$(echo -e "\n $(prompt_prefix)$(prompt) $(prompt_add)\n $(colors.prompt_print 6 ❭) ")
}

function prompt_prefix
{
    prompt="$(set_date)"

    NETNS=$(netns.current)
    if [[ -n $NETNS ]]; then
        prompt="$prompt $(set_netns $NETNS)"
    fi

    echo "$prompt "
}

function prompt_add
{
    prompt=''
    if git branch > /dev/null 2>&1 ; then
        prompt=$(set_git)
    fi

    if [[ -n "$VIRTUAL_ENV" ]] ; then
        prompt="${prompt} $(set_virtualenv)"
    fi

    echo $prompt
}

function prompt
{
    prompt=''
    [[ "`id -u`" -eq 0 ]] && color=204 || color=36

    if [[ -n $SSH_TTY ]]; then
        prompt="$(colors.prompt_print 181 '\u')$(colors.prompt_print 8 @)$(colors.prompt_print ${color} '\H')"
    else
        prompt="$(colors.prompt_print ${color} '\u:')"
    fi

    echo "${prompt} $(colors.prompt_print 8 '\w')"
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
        commit=$(colors.prompt_print 11 )
    else
        commit=$(colors.prompt_print 2 )
    fi

    echo "$(colors.prompt_print 204 [󰊢 $repo]) $(colors.prompt_print 8 ${branch})$(colors.prompt_print 5 [${commit_id}]) ${commit}  "
}

function set_virtualenv
{
    echo "$(colors.prompt_print 11 [ $(basename $VIRTUAL_ENV)])"
}

function set_netns
{
    echo "$(colors.prompt_print 198 [' ' $1])"
}

function set_date
{
    # strftime format
    echo "$(colors.prompt_print 239 '[\D{%H:%M}]')"
}
