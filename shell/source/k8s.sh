function k8s.set_namespace {
    kubectl config set-context --current --namespace $1 2> /dev/null
    [[ $? -ne 0 ]] && export KUBENS=$1
    export _KUBENS=$1
}

function k8s.kubectl {
    local OPT
    [[ -n $KUBENS ]] && OPT="-n$KUBENS"
    kubectl ${OPT} $*
}

function k8s.list_containers_by_pod {
    k8s.kubectl get pods -o="custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name,INIT-CONTAINERS:.spec.initContainers[*].name,CONTAINERS:.spec.containers[*].name" $*
}

function k8s.list_running_containers_by_pod {
    k8s.kubectl get pods \
        --field-selector=status.phase=Running \
        -o="custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name,INIT-CONTAINERS:.spec.initContainers[*].name,CONTAINERS:.spec.containers[*].name,LABELS:.metadata.labels" \
        $*
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

    k8s.kubectl exec -it $pod -c $container -- bash
}

function k8s.get_log {
    if [[ -z $* ]]; then
        echo "ex:
            $ kns octavia
            $ k8s.get_log -c worker --since 24h
            => stern -n octavia -l application=octavia -c worker --since 24h | os-log-color"
        return
    fi

    if [[ ! "$*" =~ -l ]]; then
        default_selector="-l application=${_KUBENS:-default}"
    fi

    echo "CMD: stern -n ${_KUBENS:-default} $default_selector $* | os-log-color"
    stern -n ${_KUBENS:-default} $default_selector $* | os-log-color
}

alias kns="k8s.set_namespace"
alias k="k8s.kubectl"
alias klc="k8s.list_running_containers_by_pod"
alias klac="k8s.list_all_containers_by_pod"
alias kx="k8s.exec"
alias klog="k8s.get_log"
