which kubectl &> /dev/null || return

# Load default kubeconfig if found
if [[ -f $HOME/.kube/config ]]; then
    export KUBECONFIG=$HOME/.kube/config
elif [[ -r /etc/rancher/k3s/k3s.yaml ]]; then
    export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
fi

export KUBECOLOR_OBJ_FRESH="2m"

function kub {
    local OPT=()
    local PLUGIN_OPT=()

    current_namespace=$(k8s.current_namespace)
    [[ -n $current_namespace && ! $* =~ '-n ' ]] && OPT+=("-n" $current_namespace)

    if [[ $1 =~ ^(d|desc)$ ]]; then
        shift; set -- "describe" "${@:1}"
    elif [[ $1 == get ]]; then
        PLUGIN_OPT+=("--show-kind")
    elif [[ $1 == g ]]; then
        shift; set -- "get" "${@:1}"
        PLUGIN_OPT+=("-o" "yaml")
    elif [[ $1 == delete && ! $* =~ \-\-dry-run ]]; then
        # append dry-run. need to pass --dry-run=none to force
        PLUGIN_OPT+=("--dry-run=client")
    fi

    which kubecolor &> /dev/null
    if [[ $? -eq 0 ]]; then
        command kubecolor ${OPT[@]} $* ${PLUGIN_OPT[@]}
    else
        command kubectl ${OPT[@]} $* ${PLUGIN_OPT[@]}
    fi
}

function argo {
    local OPT=()
    current_namespace=$(k8s.current_namespace)
    [[ -n $current_namespace && ! $* =~ '-n ' ]] && OPT+=("-n" $current_namespace)
    command argo ${OPT[@]} $*
}

function k8s.current_namespace {
    if [[ -n $KUBENS ]]; then
        echo $KUBENS
    else
        command kubectl config view --minify -o jsonpath='{..namespace}'
    fi
}

function k8s.set_context_namespace {
    command kubectl config set-context --current --namespace $1 2> /dev/null
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
    COMPREPLY=($(compgen -W "$(command kubectl get namespaces -o json 2> /dev/null | jq -r .items.[].metadata.name | xargs)" -- ${word}))
}

complete -F _complete_kns k8s.set_shell_namespace
complete -F _complete_kns kns
complete -F _complete_kns k8s.set_context_namespace
complete -F _complete_kns knsc

function k8s.list_containers_by_pod {
    {
        >&2 echo -n "POD\tCONTAINER\tSTATE\tSTARTED\tRESTARTS\tPOD_IP\tNODE\tNODE_IP\n";
        kub get pods -o json | \
            jq -r --arg RED "$(tput setaf 1)" --arg RES "$(tput sgr0)" --arg GREEN "$(tput setaf 2)" --arg BLUE "$(tput setaf 4)" --arg MAGENTA "$(tput setaf 5)" --arg GREY "$(tput setaf 8)" \
            '.items[] | .metadata.name as $pod_name |  .spec.nodeName as $node | .status.hostIP as $nodeip | .status.podIP as $podip | .status.containerStatuses[] | [
                $GREEN + $pod_name + $RES,
                $BLUE + .name + $RES,
                (
                  if .state.waiting then $RED + (.state.waiting.reason // "Waiting") + $RES
                  elif (.state.terminated and .state.terminated.reason == "Completed") then $MAGENTA + .state.terminated.reason + $RES
                  elif .state.terminated then $RED + (.state.terminated.reason // "Terminated") + $RES
                  elif .state.running then $GREEN + "Running" + $RES
                  else $MAGENTA + "Unknown" + $RES
                  end
                ),
                (.state.terminated.startedAt // .state.running.startedAt | fromdateiso8601 | strftime("%Y-%m-%d %H:%M:%S %Z")),
                if (.restartCount > 0) then $RED + (.restartCount | tostring) + $RES else $GREEN + (.restartCount | tostring)  + $RES end,
                $podip,
                $GREY + $node + $RES,
                $GREY + $nodeip  + $RES
            ] | @tsv'
    } | sort -k4 -k5 | column -ts $'\t'
}

function k8s.list_running_containers_by_pod_with_labels {
    kub get pods \
        --field-selector=status.phase=Running \
        -o="custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name,INIT-CONTAINERS:.spec.initContainers[*].name,CONTAINERS:.spec.containers[*].name,LABELS:.metadata.labels" \
        $*
}

function k8s.get_requests_limits {
    kub get pods \
        -o custom-columns="Name:metadata.name,CPU-request:spec.containers[*].resources.requests.cpu,CPU-limit:spec.containers[*].resources.limits.cpu,MEM-request:spec.containers[*].resources.requests.memory,MEM-limit:spec.containers[*].resources.limit.memory" \
        $*
}

function k8s.top_node {
    if [[ $# == 0 ]]; then
        echo "missing param: <node>"
        return
    fi
    node=$1
    kub top pods -A --sort-by cpu --containers=true | \
        grep --color=never -E $(k get pods -A -o="custom-columns=NAME:.metadata.name" --field-selector=spec.nodeName=${node} --no-headers | paste -d'|' -s)
}


function k8s.exec {
    type=$1; shift
    if [[ $# == 0 ]]; then
        echo "<pod> -c <container: default to first>"
        echo
        k8s.list_containers_by_pod
        return
    fi
    [[ $type == "cmd" ]] && kub exec -t $*
    [[ $type == "shell" ]] && kub exec -it $* -- sh
}

function k8s.get_ns_logs {
    command stern -n $KUBENS --field-selector metadata.namespace=$KUBENS $*
}

function k8s.get_port_forwarding {
    kub get svc -o json -A | jq '.items[] | {name:.metadata.name, p:.spec.ports[] } | select( .p.nodePort != null ) | "\(.name): localhost:\(.p.nodePort) -> \(.p.port) -> \(.p.targetPort)"'
}

function k8s.get_all_resources {
    if [[ $1 == all ]]; then
        shift
        kub get deploy,replicaset,statefulset,pod,pvc,cm,secret,svc,$(k api-resources --verbs=list --namespaced -o name | grep -v events | sort | paste -d, -s) $*
    else
        kub get deploy,replicaset,statefulset,pod,pvc,cm,secret,svc,$(k api-resources --verbs=list --namespaced -o name | grep ingress | sort | paste -d, -s) $*
    fi
}

function k8s.delete_all_resources {
    kub delete $(k api-resources --verbs=list --namespaced -o name | grep -v events | sort | paste -d, -s) --dry-run=client --all
    [[ $SHELL =~ zsh ]] && vared -p 'Delete all ? [yes] ' -c response || read -r -p 'Delete all ? [yes] ' response
    if [[ $response = "yes" ]]; then
        kub delete $(k api-resources --verbs=list --namespaced -o name | grep -v events | sort | paste -d, -s) --all --dry-run=none
    fi
}

function k8s.get_decrypted_secret {
    secret=$1
    [[ $secret =~ ^secret/ ]] && secret=$(echo $secret | cut -d'/' -f2-)
    kub get secret $secret -o json | jq '.data | map_values(@base64d)'
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
    kub logs  -l app.kubernetes.io/name=traefik  --tail 10000 --follow=false | grep 'Configuration received:' | sed -e 's/\\//g' -re 's/.*Configuration received: (.*)\".*/\1/'
}

# alias k="k8s.kubectl"
alias kns="k8s.set_shell_namespace"
alias kunset="k8s.unset_shell_namespace"
alias knsc="k8s.set_context_namespace"
alias kgp="kub get pods -o wide"
alias kgps="kub get pods -o wide --sort-by=.metadata.creationTimestamp"
alias kgc="k8s.list_containers_by_pod"
alias ks="k8s.exec shell"
alias kx="k8s.exec cmd"
alias klog="k8s.get_ns_logs"
alias kg="k8s.get_all_resources"
alias ksec="k8s.get_decrypted_secret"
alias knet="k8s.pod_netns_enter"
alias crictl="k3s crictl"
alias k=kub

function _complete_pod
{
    local word=${COMP_WORDS[1]}
    COMPREPLY=($(compgen -W "$(k get pods -o name | awk -F'/' '{print $2}' | xargs)" -- ${word}))
}

complete -F _complete_pod ks
complete -F _complete_pod kx
complete -F _complete_pod k8s.exec
complete -F _complete_pod knet
complete -F _complete_pod k8s.pod_netns_enter


if [[ $(basename $SHELL) == zsh ]]; then
    # get zsh complete kubectl
    source <(command kubectl completion zsh)
    compdef kubecolor=kubectl
    compdef k=kubectl
fi
