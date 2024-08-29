export GIT_SECRET_DIR="/dev/shm/secrets"

function gs
{
    [[ -z $SECRETS_DIR ]] && echo "Missing env SECRETS_DIR. use gs.set_secret" && return
    git secret $*
}

function gs.set_secret
{
    secret_name=$1
    export SECRETS_DIR=".gitprivate/$secret_name"
}

function gs.list_secrets
{
    [[ -d $GIT_SECRET_DIR ]] && ls ${GIT_SECRET_DIR}/.gitprivate
}

function _complete_gs_secrets
{
    local word=${COMP_WORDS[1]}
    COMPREPLY=($(compgen -W "$(gs.list_secrets | xargs)" -- ${word}))
}

complete -F _complete_gs_secrets gs.set_secret
