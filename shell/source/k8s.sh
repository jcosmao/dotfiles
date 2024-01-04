which kubectl &> /dev/null || return

which kubecolor &> /dev/null && \
    alias kubectl=kubecolor && \
    export KUBECOLOR_OBJ_FRESH="2m"

function k {
    local OPT=()
    local PLUGIN_OPT=()
    [[ -n $KUBENS ]] && OPT+=("-n" $KUBENS)

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
    kube_context=$(kubectl config current-context 2> /dev/null)
    kubectl config view -o jsonpath="{.contexts[?(@.name == '$kube_context')].context.namespace}"
}

function k8s.set_namespace {
    kubectl config set-context --current --namespace $1 2> /dev/null
    k8s.current_namespace > /tmp/k8s.current_namespace
}

function _complete_kns
{
    local word=${COMP_WORDS[1]}
    COMPREPLY=($(compgen -W "$(kubectl get namespaces -o json | jq -r .items.[].metadata.name | xargs)" -- ${word}))
}

complete -F _complete_kns k8s.set_namespace
complete -F _complete_kns kns

function k8s.list_containers_by_pod {
    kubectl get pods -o="custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name,INIT-CONTAINERS:.spec.initContainers[*].name,CONTAINERS:.spec.containers[*].name" $*
}

function k8s.list_running_containers_by_pod {
    kubectl get pods \
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
    [[ $type == "cmd" ]] && kubectl exec -t $*
    [[ $type == "shell" ]] && kubectl exec -it $* -- sh
}

function k8s.get_ns_logs {
    current_ns=$(k8s.current_namespace)
    stern -n $current_ns --field-selector metadata.namespace=$current_ns $*
}

function k8s.get_port_forwarding {
    kubectl get svc -o json -A | jq '.items[] | {name:.metadata.name, p:.spec.ports[] } | select( .p.nodePort != null ) | "\(.name): localhost:\(.p.nodePort) -> \(.p.port) -> \(.p.targetPort)"'
}

function k8s.get_all_resources {
    kubectl get deploy,pod,pvc,cm,secret,svc,$(kubectl api-resources --verbs=list --namespaced -o name | grep -v events | sort | paste -d, -s)
}

function k8s.get_decrypted_secret {
    secret=$1
    [[ $secret =~ ^secret/ ]] && secret=$(echo $secret | cut -d'/' -f2-)
    kubectl get secret $secret -o json | jq '.data | map_values(@base64d)'
}

function _complete_ksec
{
    local word=${COMP_WORDS[1]}
    COMPREPLY=($(compgen -W "$(kubectl get secrets -o json | jq -r .items.[].metadata.name | xargs)" -- ${word}))
}
complete -F _complete_ksec ksec
complete -F _complete_ksec k8s.get_decrypted_secret

function k8s.pod_netns_enter {
    pod=$1
    [[ -z $pod ]] && echo "Missing pod" && return 1
    [[ $pod =~ ^pod/ ]] && pod=$(echo $pod | cut -d'/' -f2-)

    pod_id=$(crictl ps -o json | jq -r --arg pod $pod '.containers.[] | select(.labels."io.kubernetes.pod.name" == $pod) | .podSandboxId')
    netns=$(basename $(crictl inspectp $pod_id | jq -r '.info.runtimeSpec.linux.namespaces[] | select(.type=="network") | .path'))

    netns.enter $netns
}

function k8s.get_last_traefik_config {
    kubectl logs  -l app.kubernetes.io/name=traefik  --tail 10000 --follow=false | grep 'Configuration received:' | sed -e 's/\\//g' -re 's/.*Configuration received: (.*)\".*/\1/'
}

# alias k="k8s.kubectl"
alias kns="k8s.set_namespace"
alias klc="k8s.list_running_containers_by_pod"
alias ks="k8s.exec shell"
alias kx="k8s.exec cmd"
alias klog="k8s.get_ns_logs"
alias kall="k8s.get_all_resources"
alias ksec="k8s.get_decrypted_secret"
alias knet="k8s.pod_netns_enter"

# get zsh complete kubectl
source <(kubectl completion zsh)
compdef k=kubectl
compdef kubecolor=kubectl
