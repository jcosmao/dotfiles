# Load default kubeconfig if found
if [[ -f $HOME/.kube/config ]]; then
    export KUBECONFIG=$HOME/.kube/config
elif [[ -r /etc/rancher/k3s/k3s.yaml ]]; then
    export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
fi

# Dependency checks
command -v kubectl >/dev/null 2>&1 || { echo "Error: kubectl is required but not found" >&2; return 1; }
command -v jq >/dev/null 2>&1 || { echo "Error: jq is required but not found" >&2; return 1; }

# Cache api-resources (reset with: unset K8S_API_RESOURCES)
function _k8s-api-resources() {
    if [[ -z ${K8S_API_RESOURCES+x} ]]; then
        K8S_API_RESOURCES=$(kubectl api-resources --verbs=list -o name 2>/dev/null | grep -v events | sort | paste -d, -s)
    fi
    echo "$K8S_API_RESOURCES"
}

export KUBECOLOR_OBJ_FRESH="2m"

function kub {
    local OPT=()
    local PLUGIN_OPT=()

    current_namespace=$(k.current_namespace)
    [[ -n $current_namespace && ! $* =~ '-n ' ]] && OPT+=("-n" $current_namespace)

    if [[ $1 =~ ^(d|desc)$ ]]; then
        shift; set -- "describe" "${@:1}"
    elif [[ $1 == get ]]; then
        PLUGIN_OPT+=("--show-kind")
    elif [[ $1 == g ]]; then
        shift; set -- "get" "${@:1}"
        PLUGIN_OPT+=("-o" "yaml")
    elif [[ $1 == delete && ! $* =~ (\-\-dry-run|\-\-force) ]]; then
        # append dry-run. need to pass --dry-run=none or --force to bypass
        PLUGIN_OPT+=("--dry-run=client")
    fi

    command -v kubecolor &> /dev/null
    if [[ $? -eq 0 && ! $1 =~ (debug) ]]; then
        command kubecolor ${OPT[@]} $* ${PLUGIN_OPT[@]}
    else
        [[ $* =~ .*kubecolor-stdin.* ]] && tee && return
        command kubectl ${OPT[@]} $* ${PLUGIN_OPT[@]}
    fi
}

function argo {
    local OPT=()
    current_namespace=$(k.current_namespace)
    [[ -n $current_namespace && ! $* =~ '-n ' ]] && OPT+=("-n" $current_namespace)
    command argo ${OPT[@]} $*
}

function k.current_namespace {
    if [[ -n $KUBENS ]]; then
        echo "$KUBENS"
    else
        command kubectl config view --minify -o jsonpath='{..namespace}' 2>/dev/null
    fi
}

function k.set_context_namespace {
    command kubectl config set-context --current --namespace "$1"
}

function k.set_shell_namespace {
    local ns=$1
    [[ -z $ns ]] && unset KUBENS && return
    if ! command kubectl get namespace "$ns" >/dev/null 2>&1; then
        echo "Error: namespace '$ns' does not exist" >&2
        return 1
    fi
    export KUBENS=$ns
}

function _complete_kns
{
    local word=${COMP_WORDS[1]}
    COMPREPLY=($(compgen -W "$(command kubectl get namespaces -o json 2> /dev/null | jq -r .items.[].metadata.name | xargs)" -- ${word}))
}

complete -F _complete_kns k.set_shell_namespace
complete -F _complete_kns kns
complete -F _complete_kns k.set_context_namespace
complete -F _complete_kns knsc

function k.list_containers_by_pod {
    {
        echo -n "${BOLD}NAME\tCONTAINER\tINIT\tSTATUS\tRESTARTS\tLAST\tAGE\tIP\tNODE\tNODE_IP${NORMAL}\n";
        {
            kub get pods -o json | \
            jq -r --arg current_date "$(date +%s)" \
            '.items[] | .metadata.name as $pod_name |
                        .spec.nodeName as $node |
                        .status.hostIP as $nodeip |
                        .status.podIP as $podip |
                        .metadata.creationTimestamp as $pod_created |
                        .metadata.deletionTimestamp as $pod_deleted |
                        ((.status.initContainerStatuses // [] | map(. + {_init: "Yes"})) + (.status.containerStatuses // [] | map(. + {_init: "No"})))[] | [
                "pod/" + $pod_name,
                .name,
                ._init,
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
                        ($last_start | fromdateiso8601) as $last_start_epoch |
                        (($current_date | tonumber) - $last_start_epoch) as $diff |
                        if $diff < 600 then "\($diff)s"
                        elif $diff < 7200 then "\($diff / 60 | floor)m"
                        elif $diff < 86400 then "\($diff / 3600 | floor)h"
                        else "\($diff / 86400 | floor)d"
                        end
                    else
                        "Unknown"
                    end
                ),
                (
                    ($pod_created | fromdateiso8601) as $created_epoch |
                    (($current_date | tonumber) - $created_epoch) as $diff |
                    if $diff < 600 then "\($diff)s"
                    elif $diff < 7200 then "\($diff / 60 | floor)m"
                    elif $diff < 86400 then "\($diff / 3600 | floor)h"
                    else "\($diff / 86400 | floor)d"
                    end
                ),
                $podip,
                $node,
                $nodeip
            ] | @tsv'
        } | sort -k1
    } | column -ts $'\t' | kub get pods --kubecolor-stdin
}

function k.limits {
    kub get pods \
        -o custom-columns="Name:metadata.name,CPU-request:spec.containers[*].resources.requests.cpu,CPU-limit:spec.containers[*].resources.limits.cpu,MEM-request:spec.containers[*].resources.requests.memory,MEM-limit:spec.containers[*].resources.limit.memory" \
        $* | kub top pods --kubecolor-stdin
}

function k.top {
    {
        local usage_data=$(kub top pods --containers | tail -n +2)
        [[ $? -ne 0 ]] && undef usage_data
        echo "POD CONTAINER CPU-requests CPU-limits CPU-usage MEM-requests MEM-limits MEM-usage"
        kub get pods -o json | jq -r '.items[] | .metadata.name as $pod |
        .spec.containers[] | {
            pod: $pod,
            container: .name,
            cpu_req: (.resources.requests.cpu // "-"),
            cpu_lim: (.resources.limits.cpu // "-"),
            mem_req: (.resources.requests.memory // "-"),
            mem_lim: (.resources.limits.memory // "-")
        } | [.pod, .container, .cpu_req, .cpu_lim, .mem_req, .mem_lim] | @tsv' | \
        while read pod container cpu_req cpu_lim mem_req mem_lim; do
            if [[ -n $usage_data ]]; then
                cpu_usage=$(echo "$usage_data" | awk -v p="$pod" -v c="$container" '$1 == p && $2 == c {print $3}')
                mem_usage=$(echo "$usage_data" | awk -v p="$pod" -v c="$container" '$1 == p && $2 == c {print $4}')
            fi
            echo "$pod $container $cpu_req $cpu_lim ${cpu_usage:-N/A} $mem_req $mem_lim ${mem_usage:-N/A}"
        done
    } | column -t | kub top pods --kubecolor-stdin
}

function k.mem_use {
    pod=$1
    [[ $# == 0 ]] && return
    kub exec -t $pod -- sh -c 'echo "scale=2; $(cat /sys/fs/cgroup/memory.current 2>/dev/null || cat /sys/fs/cgroup/memory/memory.usage_in_bytes 2>/dev/null)/1024/1024" | bc'
}

function k.top_node {
    if [[ $# == 0 ]]; then
        echo "missing param: <node>"
        return
    fi
    node=$1
    kub top pods -A --sort-by cpu --containers=true | \
        grep --color=never -E "$(k get pods -A -o='custom-columns=NAME:.metadata.name' --field-selector=spec.nodeName=${node} --no-headers | paste -d'|' -s)|NAMESPACE" | \
        kub top pods --kubecolor-stdin
}

function k.exec {
    type=$1; shift
    if [[ $# == 0 ]]; then
        echo "<pod> -c <container: default to first>"
        echo
        k.list_containers_by_pod
        return
    fi
    if [[ $type == "cmd" ]]; then
        kub exec -t $*
        return
    elif [[ $type == "shell" ]]; then
        kub exec -it $* -- bash 2>/dev/null || sh
    fi
}

function k.get_ns_logs {
    local pods=($(printf '%s\n' "$@" | sed 's|^pod/||'))
    local ns=$(k.current_namespace)
    command stern -n ${ns:-default} --field-selector metadata.namespace=${ns:-default} -s 1m "${pods[@]}"
}

function k.get_all_resources {
    local all_resources
    local filter=""
    local opts=()

    while [[ $# -gt 0 ]]; do
        case "$1" in
            all) filter="all"
                 shift ;;
            -*)  opts+=("$1")
                 shift ;;
            *)   if [[ -z "$filter" ]]; then
                    filter="$1"
                    shift
                else
                    opts+=("$1")
                    shift
                fi ;;
        esac
    done

    if [[ "$filter" == "all" ]]; then
        all_resources=$(kubectl api-resources --verbs=list -o name 2>/dev/null | grep -v events | sort | paste -d, -s)
    elif [[ -n "$filter" ]]; then
        all_resources=$(kubectl api-resources --verbs=list -o name 2>/dev/null | grep -v events | grep -E "$filter" | sort | paste -d, -s)
    else
        all_resources=$(kubectl api-resources --verbs=list --namespaced=true -o name 2>/dev/null | grep -v events | sort | paste -d, -s)
    fi

    kub get ${all_resources} ${opts[@]}
}

function k.get_decrypted_secret {
    secret=$1
    [[ $secret =~ ^secret/ ]] && secret=$(echo $secret | cut -d'/' -f2-)
    kub get secret $secret -o json | jq '.data | map_values(@base64d)'
}

function k.edit_secret {
    local secret=$1
    [[ $secret =~ ^secret/ ]] && secret=$(echo "$secret" | cut -d'/' -f2-)
    local key=$2
    [[ -z $secret ]] && echo "Error: secret name required" >&2 && return 1
    [[ -z $key ]] && echo "Error: key required" >&2 && return 1

    local tmpfile
    tmpfile=$(mktemp -p /dev/shm 2>/dev/null || mktemp)

    # Extract just the decoded value of the single key
    kub get secret "$secret" -o json | jq -r ".data[\"$key\"] | @base64d" > "$tmpfile"

    ${EDITOR:-vi} "$tmpfile"
    local exit_code=$?
    [[ $exit_code -ne 0 ]] && rm -f "$tmpfile" && return $exit_code

    local new_value
    new_value=$(cat "$tmpfile")
    kub get secret "$secret" -o json | jq --arg k "$key" --arg v "$new_value" '{
        apiVersion: "v1",
        kind: "Secret",
        metadata: .metadata,
        type: .type,
        data: (.data | .[$k] = ($v | @base64))
    }' | kub apply -f -

    rm -f "$tmpfile"
    return $exit_code
}

function _complete_ksec
{
    local word=${COMP_WORDS[1]}
    COMPREPLY=($(compgen -W "$(k get secrets -o json | jq -r .items.[].metadata.name | xargs)" -- ${word}))
}
complete -F _complete_ksec ksec
complete -F _complete_ksec k.get_decrypted_secret
complete -F _complete_ksec ksed
complete -F _complete_ksec k.edit_secret

function k.pod_netns_enter {
    local pod=$1
    [[ -z $pod ]] && echo "Error: pod required" >&2 && return 1
    command -v crictl >/dev/null 2>&1 || { echo "Error: crictl not found" >&2; return 1; }
    [[ $pod =~ ^pod/ ]] && pod=$(echo "$pod" | cut -d'/' -f2-)

    local pod_id
    pod_id=$(crictl ps -o json 2>/dev/null | jq -r --arg pod "$pod" '.containers.[] | select(.labels."io.kubernetes.pod.name" == $pod) | .podSandboxId' | uniq)
    [[ -z $pod_id ]] && echo "Error: pod '$pod' not found" >&2 && return 1

    local netns
    netns=$(basename $(crictl inspectp "$pod_id" 2>/dev/null | jq -r '.info.runtimeSpec.linux.namespaces[] | select(.type=="network") | .path'))
    [[ -z $netns ]] && echo "Error: network namespace not found for pod '$pod'" >&2 && return 1

    netns.enter "$netns"
}

function k.get_last_traefik_config {
    kub logs  -l app.kubernetes.io/name=traefik  --tail 10000 --follow=false | grep 'Configuration received:' | sed -e 's/\\//g' -re 's/.*Configuration received: (.*)\".*/\1/'
}

# alias k="k.kubectl"
alias kns="k.set_shell_namespace"
alias knsc="k.set_context_namespace"
alias kgp="kub get pods -o wide"
alias kgps="kub get pods -o wide --sort-by=.metadata.creationTimestamp"
alias kgc="k.list_containers_by_pod"
alias ks="k.exec shell"
alias kx="k.exec cmd"
alias klog="k.get_ns_logs"
alias kg="k.get_all_resources"
alias ksec="k.get_decrypted_secret"
alias ksed="k.edit_secret"
alias knet="k.pod_netns_enter"
alias crictl="k3s crictl"
alias k=kub

function _complete_pod
{
    local word=${COMP_WORDS[1]}
    COMPREPLY=($(compgen -W "$(k get pods -o name | awk -F'/' '{print $2}' | xargs)" -- ${word}))
}

complete -F _complete_pod ks
complete -F _complete_pod kx
complete -F _complete_pod k.exec
complete -F _complete_pod knet
complete -F _complete_pod k.pod_netns_enter
complete -F _complete_pod klog
complete -F _complete_pod k.get_ns_logs
complete -F _complete_pod k.mem_use


if [[ $(basename $SHELL) == zsh ]]; then
    _k8s_load_completions() {
        [[ -n $K8S_COMPLETIONS_LOADED ]] && return
        source <(command kubectl completion zsh 2>/dev/null)
        compdef kubecolor=kubectl 2>/dev/null
        compdef k=kubectl 2>/dev/null
        compdef kub=kubectl 2>/dev/null
        export K8S_COMPLETIONS_LOADED=1
    }
    add-zsh-hook precmd _k8s_load_completions 2>/dev/null
fi
