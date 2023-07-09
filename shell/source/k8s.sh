function k8s.set_namespace {
    kubectl config set-context --current --namespace $1
    [[ $? -ne 0 ]] && export KUBENS=$1
    export _KUBENS=$1
}

function k8s.kubectl {
    local OPT
    [[ -n $KUBENS ]] && OPT="-n$KUBENS"
    kubectl ${OPT} $*
}

function k8s.list_containers_by_pod {
    kubectl get pods -o="custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name,INIT-CONTAINERS:.spec.initContainers[*].name,CONTAINERS:.spec.containers[*].name" $*
}

function k8s.exec {
    pod=$1
    container=$2

    if [[ -z $pod ]]; then
        echo "kx <pod> <container>"
        echo

        k8s.list_containers_by_pod -A
        return
    fi

    kubectl exec -it $pod -c $container -- bash
}

alias kns="k8s.set_namespace"
alias k="k8s.kubectl"
alias klc="k8s.list_containers_by_pod"
alias kx="k8s.exec"
