function git
{
    if [[ $1 = "review" ]]; then
        shift
        git.review $*
        return $?
    fi

    command git $*
}

function git.review
{
    target=$1
    topic=$2

    if [[ $# -eq 0 ]]; then
        echo "git.review <target: default(current tracked) OR ex: origin/master> <topic: default(current branch name) OR null>"
        echo "No params provided. use defaults"
    fi

    if [[ -z $target ]]; then
        target_branch=$(grep defaultbranch= $(git rev-parse --show-toplevel)/.gitreview | cut -d= -f2 2> /dev/null)
        if [[ -z $target_branch ]]; then
            target=$(git trackshow)
            echo "- defaultbranch not found in .gitreview, use current tracked $target"
        else
            remote=$(git trackshow | cut -d'/' -f1)
            target="${remote}/${target_branch}"
        fi
    fi

    # validate remote branch exist
    validate=$(git branch -r --format='%(refname:strip=2)' | grep -P "^${target}$")
    remote=$(echo $validate | cut -d/ -f1)
    branch=$(echo $validate | cut -d/ -f2-)
    current_branch=$(git symbolic-ref --short HEAD)

    if [[ -z $topic && ! $current_branch = $branch ]]; then
        topic="%topic=$(git symbolic-ref --short HEAD)"
    elif [[ -n $topic && ! $topic = null ]]; then
        topic="%topic=${topic}"
    else
        unset topic
    fi

    if [[ -n $branch && -n $remote ]]; then
        echo "CMD: git push $remote HEAD:refs/for/${branch}${topic}"
        [[ $SHELL =~ zsh ]] && vared -p 'Submit ? [y] ' -c response || read -r -p 'Submit ? [y] ' response
        if [[ $response = y ]]; then
            git push $remote HEAD:refs/for/${branch}${topic}
        fi
    else
        echo "Unable to find remote branch (git branch -r): $target"
    fi
}
