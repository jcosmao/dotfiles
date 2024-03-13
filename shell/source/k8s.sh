which kubectl &> /dev/null || return

# Load default kubeconfig if found
if [[ -f $HOME/.kube/config ]]; then
    export KUBECONFIG=$HOME/.kube/config
elif [[ -r /etc/rancher/k3s/k3s.yaml ]]; then
    export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
fi

which kubecolor &> /dev/null && \
    alias kubectl=kubecolor && \
    export KUBECOLOR_OBJ_FRESH="2m"

function k {
    local OPT=()
    local PLUGIN_OPT=()

    current_namespace=$(k8s.current_namespace)
    [[ -n $current_namespace ]] && OPT+=("-n" $current_namespace)

    if [[ $1 =~ ^(d|desc)$ ]]; then
        shift; set -- "describe" "${@:1}"
    elif [[ $1 == get ]]; then
        PLUGIN_OPT+=("--show-kind")
    elif [[ $1 == g ]]; then
        shift; set -- "get" "${@:1}"
        PLUGIN_OPT+=("-o" "yaml")
    fi

    kubectl ${OPT[@]} $* ${PLUGIN_OPT[@]}
}

function k8s.current_namespace {
    if [[ -n $KUBENS ]]; then
        echo $KUBENS
    else
        \kubectl config view --minify -o jsonpath='{..namespace}'
    fi
}

function k8s.set_context_namespace {
    \kubectl config set-context --current --namespace $1 2> /dev/null
}

function k8s.set_shell_namespace {
    export KUBENS=$1
}

function k8s.unset_shell_namespace {
    unset KUBENS
}

function _complete_kns
{
    local word=${COMP_WORDS[1]}
    COMPREPLY=($(compgen -W "$(\kubectl get namespaces -o json | jq -r .items.[].metadata.name | xargs)" -- ${word}))
}

complete -F _complete_kns k8s.set_shell_namespace
complete -F _complete_kns kns
complete -F _complete_kns k8s.set_context_namespace
complete -F _complete_kns knsc

function k8s.list_containers_by_pod {
    k get pods -o="custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name,INIT-CONTAINERS:.spec.initContainers[*].name,CONTAINERS:.spec.containers[*].name" $*
}

function k8s.list_running_containers_by_pod {
    k get pods \
        --field-selector=status.phase=Running \
        -o="custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name,INIT-CONTAINERS:.spec.initContainers[*].name,CONTAINERS:.spec.containers[*].name,LABELS:.metadata.labels" \
        $*
}

function k8s.exec {
    type=$1; shift
    if [[ $# == 0 ]]; then
        echo "<pod> -c <container: default to first>"
        echo
        k8s.list_containers_by_pod
        return
    fi
    [[ $type == "cmd" ]] && k exec -t $*
    [[ $type == "shell" ]] && k exec -it $* -- sh
}

function k8s.get_ns_logs {
    stern -n $KUBENS --field-selector metadata.namespace=$KUBENS $*
}

function k8s.get_port_forwarding {
    k get svc -o json -A | jq '.items[] | {name:.metadata.name, p:.spec.ports[] } | select( .p.nodePort != null ) | "\(.name): localhost:\(.p.nodePort) -> \(.p.port) -> \(.p.targetPort)"'
}

function k8s.get_all_resources {
    if [[ $1 == all ]]; then
        shift
        k get deploy,replicaset,statefulset,pod,pvc,cm,secret,svc,$(k api-resources --verbs=list --namespaced -o name | grep -v events | sort | paste -d, -s) $*
    else
        k get deploy,replicaset,statefulset,pod,pvc,cm,secret,svc,$(k api-resources --verbs=list --namespaced -o name | grep ingress | sort | paste -d, -s) $*
    fi
}

function k8s.get_decrypted_secret {
    secret=$1
    [[ $secret =~ ^secret/ ]] && secret=$(echo $secret | cut -d'/' -f2-)
    k get secret $secret -o json | jq '.data | map_values(@base64d)'
}

function _complete_ksec
{
    local word=${COMP_WORDS[1]}
    COMPREPLY=($(compgen -W "$(k get secrets -o json | jq -r .items.[].metadata.name | xargs)" -- ${word}))
}
complete -F _complete_ksec ksec
complete -F _complete_ksec k8s.get_decrypted_secret

function k8s.pod_netns_enter {
    pod=$1
    [[ -z $pod ]] && echo "Missing pod" && return 1
    [[ $pod =~ ^pod/ ]] && pod=$(echo $pod | cut -d'/' -f2-)

    pod_id=$(crictl ps -o json | jq -r --arg pod $pod '.containers.[] | select(.labels."io.kubernetes.pod.name" == $pod) | .podSandboxId' | uniq)
    netns=$(basename $(crictl inspectp $pod_id | jq -r '.info.runtimeSpec.linux.namespaces[] | select(.type=="network") | .path'))

    netns.enter $netns
}

function k8s.get_last_traefik_config {
    k logs  -l app.kubernetes.io/name=traefik  --tail 10000 --follow=false | grep 'Configuration received:' | sed -e 's/\\//g' -re 's/.*Configuration received: (.*)\".*/\1/'
}

# alias k="k8s.kubectl"
alias kns="k8s.set_shell_namespace"
alias kunset="k8s.unset_shell_namespace"
alias knsc="k8s.set_context_namespace"
alias klc="k8s.list_running_containers_by_pod"
alias ks="k8s.exec shell"
alias kx="k8s.exec cmd"
alias klog="k8s.get_ns_logs"
alias kg="k8s.get_all_resources"
alias ksec="k8s.get_decrypted_secret"
alias knet="k8s.pod_netns_enter"
alias crictl="k3s crictl"

if [[ $(basename $SHELL) == zsh ]]; then
    # get zsh complete kubectl
    source <(kubectl completion zsh)
    compdef k=kubectl
    compdef kubecolor=kubectl
fi
