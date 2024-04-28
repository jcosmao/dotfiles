which terraform &> /dev/null || return

function tf
{
    OPTS=""
    if [[ $1 == auto-approve ]]; then
        shift
        OPTS="-auto-approve"
    fi

    # Set terraform state dir
    # - default is local dir
    # - TF_WORKSPACE -> ./terraform.d/$TF_WORKSPACE
    if [[ -z $TF_WORKSPACE && -n $OS_REGION_NAME ]]; then
        TF_DIR=$OS_REGION_NAME
    elif [[ -n $TF_WORKSPACE ]]; then
        TFDIR=$TF_WORKSPACE
    fi

    [[ -z $TF_DIR ]] && unset TF_DIR || export TF_WORKSPACE=$TF_DIR
    terraform $* $OPTS
}

function terraform.set_workspace
{
    tf_workspace=$1
    [[ -n $tf_workspace ]] && export TF_WORKSPACE=$tf_workspace
}

function terraform.unset_workspace
{
    unset TF_WORKSPACE
}

function terraform.list_workspace
{
    [[ -d terraform.tfstate.d ]] && ls terraform.tfstate.d
}

function _complete_tf_workspace
{
    local word=${COMP_WORDS[1]}
    COMPREPLY=($(compgen -W "$(terraform.list_workspace | xargs)" -- ${word}))
}


alias tfy="tf auto-approve"
alias tfset=terraform.set_workspace
alias tfunset=terraform.unset_workspace

complete -C $(which terraform) terraform
complete -C $(which terraform) tf
complete -C $(which terraform) tfy
complete -F _complete_tf_workspace terraform.set_workspace
complete -F _complete_tf_workspace tfset
