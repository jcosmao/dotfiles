export CLIFF_FIT_WIDTH=1

function os {
    JQ=0
    [[ "$*" =~ (show|list|create) ]] && JQ=1
    [[ "$*" =~ (console log show) ]] && JQ=0

    EXTRA_OPTS=""
    # Require at least 2.24 to get migration id + abort
    [[ "$*" =~ (server migration) ]] && EXTRA_OPTS="--os-compute-api-version 2.24"

    if [[ $JQ == 1 ]]; then
        eval $(echo openstack $EXTRA_OPTS $* -f json | tr -s "  " " ") | jq .
    else
        eval $(echo openstack $EXTRA_OPTS $* | tr -s "  " " ")
    fi
}

alias oss="os server"
alias osc="os compute"
alias osn="os network"
alias osb="os baremetal"
alias osv="os volume"
alias osi="os image"
alias osl="os loadbalancer"

function os_log_color
{(
    cmd=${1:-tail}; shift
    opts=("$@")

    tail_opts=()
    os_files=()
    for f in ${opts[@]}; do
        if [[ -e $f ]]; then
            os_files+=($f)
            shift
        else
            if [[ ${#os_files[@]} == 0 ]]; then
                tail_opts+=($f)
                shift
            fi
        fi
    done

    if [[ ${#os_files[@]} == 0 ]]; then
        echo "Need to pass valid files in args..."
        return 1
    fi

    os_opts=$*

    [[ $cmd == "less" ]] && cat ${os_files[@]} | ~/.local/bin/os-log-color $os_opts | less -R
    [[ $cmd == "tail" ]] && tail ${tail_opts[@]} -F ${os_files[@]} | ~/.local/bin/os-log-color $os_opts
)}

function otail
{
    os_log_color "tail" $*
}

function oless
{
    os_log_color "less" $*
}
