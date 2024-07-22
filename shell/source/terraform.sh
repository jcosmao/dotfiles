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
    # - TF_WORKSPACE -> ./terraform.tfstate.d/$TF_WORKSPACE
    if [[ -z $TF_WORKSPACE && -n $OS_REGION_NAME ]]; then
        TF_DIR=$OS_REGION_NAME
    elif [[ -n $TF_WORKSPACE ]]; then
        TF_DIR=$TF_WORKSPACE
    fi

    [[ -z $TF_DIR ]] && unset TF_DIR || export TF_WORKSPACE=$TF_DIR

    state_dir="terraform.tfstate.d/${TF_WORKSPACE}"
    mkdir -p $state_dir

    if [[ $1 = "apply" && ! -f $state_dir/args ]]; then
        echo $* | sed -e 's/apply//' > ${state_dir}/args
    fi

    if [[ $1 =~ (apply|destroy) ]]; then
        if [[ "$*" != "$(cat ${state_dir}/args)" ]]; then
            echo "WORKSPACE=$TF_WORKSPACE  previously used with args: '$(cat ${state_dir}/args)'"
            [[ $SHELL =~ zsh ]] && vared -p 'continue ? [y] ' -c response || read -r -p 'continue ? [y] ' response
            if [[ $response != y ]]; then
                return
            fi

        fi
    fi

    terraform $* $OPTS

    [[ $? = 0 && $1 = "destroy" ]] && \
        rm -rf $state_dir && \
        unset TF_WORKSPACE
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
