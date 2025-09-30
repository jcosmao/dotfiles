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

    remote="gerrit"
    [[ -z $target ]] && target=$(git rev-parse --abbrev-ref HEAD)
    [[ -n $topic ]] && topic="%topic=${topic}"

    if [[ $# -eq 0 ]]; then
        echo "git.review <target branch: default(current tracked) ex: master> <topic: default(current branch name) OR null>"
        echo "No params provided. use defaults"
    fi

    gitreview_file=$(git rev-parse --show-toplevel)/.gitreview
    if [[ ! -f "$gitreview_file" ]]; then
        echo ".gitreview not found"
        return 1
    fi

    host=$(grep host= "$gitreview_file" | cut -d= -f2)
    port=$(grep port= "$gitreview_file" | cut -d= -f2)
    project=$(grep project= "$gitreview_file" | cut -d= -f2)

    # Configure gerrit remote if not exists
    if ! git remote | grep -q gerrit; then
        if [[ -n "$host" && -n "$port" && -n "$project" ]]; then
            git remote add gerrit "ssh://${host}:${port}/${project}"
            echo "Added gerrit remote: ssh://${host}:${port}/${project}"
            git fetch gerrit
        else
            echo "Error: .gitreview file is missing required fields (host, port, project)"
            return 1
        fi
    fi

    # validate remote branch exist
    validate=$(git branch -r --format='%(refname:strip=2)' | grep -P "^${remote}/${target}$")
    if [[ -z $validate ]]; then
        echo "${remote}/${target} not found, cannot submit pr"
        return 1
    fi

    echo "CMD: git push $remote HEAD:refs/for/${target}${topic}"
    [[ $SHELL =~ zsh ]] && vared -p 'Submit ? [y] ' -c response || read -r -p 'Submit ? [y] ' response
    if [[ $response = y ]]; then
        git push $remote HEAD:refs/for/${target}${topic}
    fi
}

