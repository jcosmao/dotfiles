export GIT_SECRET_ROOT="/dev/shm/secrets"
[[ ! -e $GIT_SECRET_ROOT ]] && return

function gs
{
    [[ $# -eq 0 ]] && cd $GIT_SECRET_ROOT

    [[ -z $SECRETS_DIR ]] && echo "Missing env SECRETS_DIR. use gs.set_secret" && return
    git -C $GIT_SECRET_ROOT secret $*
}

function gs.set_secret
{
    secret_name=$1
    export SECRETS_DIR=".gitprivate/$secret_name"
}

function gs.list_env
{
    [[ -d $GIT_SECRET_ROOT ]] && ls ${GIT_SECRET_ROOT}/.gitprivate
}

function _complete_gs_secrets
{
    local word=${COMP_WORDS[1]}
    COMPREPLY=($(compgen -W "$(gs.list_env | xargs)" -- ${word}))
}

complete -F _complete_gs_secrets gs.set_secret

function gs.gpg
{
    [[ -z $SECRETS_DIR ]] && echo "Missing env SECRETS_DIR. use gs.set_secret" && return
    gpg --homedir ${GIT_SECRET_ROOT}/${SECRETS_DIR}/keys/ $*
}
