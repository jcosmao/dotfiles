export CLIFF_FIT_WIDTH=1

function os {
    APPEND_OPTS=()
    [[ "$*" =~ (show|list|create|issue) ]] && APPEND_OPTS+=("-f" "json")
    [[ "$*" =~ (console log show) ]] && APPEND_OPTS=()
    [[ "$*" =~ (server list) ]] && APPEND_OPTS+=("-n")

    echo "${APPEND_OPTS[@]}" | grep -qw '\-f json' && PIPE_CMD="jq" || PIPE_CMD="tee"

    EXTRA_OPTS=()
    # Require at least 2.24 to get migration id + abort
    [[ "$*" =~ (server migration) ]] && EXTRA_OPTS+=("--os-compute-api-version" "2.24")

    openstack "${EXTRA_OPTS[@]}" $* "${APPEND_OPTS[@]}" | $PIPE_CMD
}

function openstack.unset_env {
    unset $(env | grep ^OS_ | cut -d= -f1) 2> /dev/null
}

function openstack.token {
    export OSTOKEN=$(os token issue | jq -r .id)
}

alias oss="os server"
alias osc="os compute"
alias osn="os network"
alias osb="os baremetal"
alias osv="os volume"
alias osi="os image"
alias op="openstack"
# nova
alias ossall="os server list --all --host"
# octavia
alias osl="os loadbalancer"
alias osla="os loadbalancer amphora list --loadbalancer"
alias ostoken="openstack.token"

if [[ -d ~/.os_openrc ]]; then

    function openstack.make_symlink_from_catalog
    {(
        file=${1:-openrc\..*}
        cd ~/.os_openrc
        for openrc in $(ls | grep -P "^$file$")
        do
            source $openrc
            name=$(echo $openrc | sed -e 's/openrc\.//')
            openstack catalog list -f json | jq -r '.[] | select(.Name == "nova") | .Endpoints| .[].region' | while read REGION
            do
                ln -sf $openrc ${REGION}__${name}.openrc
            done
        done
    )}

    for openrc in $(ls ~/.os_openrc | grep -P '.openrc$'); do
        name=$(echo $openrc | sed -e 's/.openrc$//')
        region=$(echo $openrc | sed -re 's/(.*)__.*/\1/' | tr '[:lower:]' '[:upper:]')
        alias cr_${name}="openstack.unset_env; source ~/.os_openrc/$openrc; export OS_REGION_NAME=${region}"
    done
fi

function openstack.port_list
{
    if [[ $1 =~ ^([0-9]+\.){3} ]] ; then
        os port list --fixed-ip ip-address=$1
    else
        os port list --device-id $1
    fi
}

alias osport="openstack.port_list"

function openstack.get_snat
{
    os network agent list --long --router $*
}

alias osnat="openstack.get_snat"

function openstack.log_color
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

alias otail="openstack.log_color tail"
alias olog="openstack.log_color less"
