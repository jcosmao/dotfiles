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
    if [[ $? -eq 0 && ! $1 =~ (debug) ]]; then
        command kubecolor ${OPT[@]} $* ${PLUGIN_OPT[@]}
    else
        [[ $* =~ .*kubecolor-stdin.* ]] && tee && return
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
        echo -n "${BOLD}NAME\tCONTAINER\tSTATUS\tRESTARTS\tLAST\tAGE\tIP\tNODE\tNODE_IP${NORMAL}\n";
        {
            kub get pods -o json | \
            jq -r --arg current_date "$(date +%s)" \
            '.items[] | .metadata.name as $pod_name |
                        .spec.nodeName as $node |
                        .status.hostIP as $nodeip |
                        .status.podIP as $podip |
                        .metadata.creationTimestamp as $pod_created |
                        .metadata.deletionTimestamp as $pod_deleted |
                        .status.containerStatuses[] | [
                "pod/" + $pod_name,
                .name,
                (
                    if $pod_deleted then "Terminating"
                    elif .state.waiting then (.state.waiting.reason // "Waiting")
                    elif (.state.terminated and .state.terminated.reason == "Completed") then .state.terminated.reason
                    elif .state.terminated then (.state.terminated.reason // "Terminated")
                    elif .state.running then "Running"
                    else "Unknown"
                    end
                ),
                (
                    (.state.terminated.startedAt // .state.running.startedAt) as $last_start |
                    if $last_start then
                        ($last_start | fromdateiso8601) as $last_start_epoch |
                        (($current_date | tonumber) - $last_start_epoch) as $diff_seconds |
                        if $diff_seconds < 60 then
                            "\(.restartCount) (" + ($diff_seconds | tostring) + "s ago)"
                        elif $diff_seconds < 3600 then
                            "\(.restartCount) (" + ($diff_seconds / 60 | floor | tostring) + "m ago)"
                        elif $diff_seconds < 86400 then
                            "\(.restartCount) (" + ($diff_seconds / 3600 | floor | tostring) + "h ago)"
                        else
                            "\(.restartCount) (" + ($diff_seconds / 86400 | floor | tostring) + "d ago)"
                        end
                    else
                        "\(.restartCount) (Unknown)"
                    end
                ),
                (
                    (.state.terminated.startedAt // .state.running.startedAt) as $last_start |
                    if $last_start then
                        (($last_start | fromdateiso8601) // ($current_date | tonumber) | strftime("%Y-%m-%d %H:%M:%S %Z"))
                    else
                        "Unknown"
                    end
                ),
                (
                    ($pod_created | fromdateiso8601) as $created_epoch |
                    (($current_date | tonumber) - $created_epoch) as $created_seconds |
                    $created_seconds / 86400 | floor | "\(.)d"
                ),
                $podip,
                $node,
                $nodeip
            ] | @tsv'
        } | sort -k7 -k8
    } | column -ts $'\t' | kub get pods --kubecolor-stdin
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
        grep --color=never -E "$(k get pods -A -o='custom-columns=NAME:.metadata.name' --field-selector=spec.nodeName=${node} --no-headers | paste -d'|' -s)|NAMESPACE" | \
        kub top pods --kubecolor-stdin
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
        kub get deploy,replicaset,statefulset,daemonset,pod,pvc,cm,secret,svc,$(k api-resources --verbs=list --namespaced -o name | grep -v events | sort | paste -d, -s) $*
    else
        kub get deploy,replicaset,statefulset,daemonset,pod,pvc,cm,secret,svc,$(k api-resources --verbs=list --namespaced -o name | grep ingress | sort | paste -d, -s) $*
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


# if [[ $(basename $SHELL) == zsh ]]; then
#     # get zsh complete kubectl
#     source <(command kubectl completion zsh)
#     compdef kubecolor=kubectl
#     compdef k=kubectl
#     compdef k=kub
# fi
