export CLIFF_FIT_WIDTH=1

function os {
    JSON=1
    [[ $1 == "--nojson" ]] && JSON=0 && shift

    PIPE_CMD=
    APPEND_OPTS=()
    [[ "$*" =~ ( show| list| create| issue)( |$) && $JSON == 1 ]] && APPEND_OPTS+=("-f" "json")
    [[ "$*" =~ (server list) ]] && APPEND_OPTS+=("-n")
    [[ "$*" =~ (console log show|--help$| -h$| help$|lb status show|loadbalancer status show) ]] && APPEND_OPTS=()
    if [[ $1 == "fip" ]]; then
        shift; set -- "floating ip" "${@:1}"
    elif [[ $1 == "lb" ]]; then
        shift; set -- "loadbalancer" "${@:1}"
    elif [[ $1 == "net" ]]; then
        shift; set -- "network" "${@:1}"
    elif [[ $1 == "bm" ]]; then
        shift; set -- "baremetal" "${@:1}"
    elif [[ $1 == "sg" ]]; then
        shift; set -- "security group" "${@:1}"
    elif [[ $1 == "srv" || $1 == "s" ]]; then
        shift; set -- "server" "${@:1}"
        [[ $2 == "show" ]] && PIPE_CMD=openstack.server_show_jq_filter
    elif [[ $1 == "az" ]]; then
        shift; set -- "availability zone" "${@:1}"
    elif [[ $1 == "agg" ]]; then
        shift; set -- "aggregate" "${@:1}"
    fi

    echo "${APPEND_OPTS[@]}" | grep -qw '\-f json' && PIPE_CMD=${PIPE_CMD:-jq} || PIPE_CMD="tee"
    echo "$*" | grep -qw "loadbalancer status show" && PIPE_CMD=jq

    EXTRA_OPTS=()
    # Require at least 2.24 to get migration id + abort
    # Require 2.30 to specify --host
    # [[ "$*" =~ (server migration) ]] && EXTRA_OPTS+=("--os-compute-api-version" "2.30")
    # EXTRA_OPTS+=("--os-compute-api-version" "${OS_COMPUTE_API_MIN_VERSION:-"2.72"}")
    [[ -z $OS_COMPUTE_DEFAULT_MICROVERSION ]] && export OS_COMPUTE_DEFAULT_MICROVERSION="2.72"

    openstack "${EXTRA_OPTS[@]}" $* "${APPEND_OPTS[@]}" | $PIPE_CMD
}

function openstack.server_show_jq_filter
{
    # recent version of openstackcli duplicate all entries
    jq '.flavor = (.flavor.name | tostring) | with_entries(select(.key | test("^(OS-EXT-SRV-ATTR:host|flavor|addresses|availability_zone|compute_host|config_drive|created_at|disk_config|fault|flavor|host_status|hypervisor_hostname|id|image|instance_name|key_name|launched_at|locked|name|power_state|project_id|public_v4|public_v6|ramdisk_id|reservation_id|root_device_name|scheduler_hints|security_groups|server_groups|status|tags|task_state|updated_at|user_id|vm_state|volumes_attached)$") ))'
}

function openstack.install_completion {
    [[ $SHELL =~ zsh ]] && openstack complete | sed 's;local comp="${!i}";local comp="${(P)i}";' | sed -e '/.*_get_comp_words_by_ref.*/d' > ~/.bash_custom/openstack_complete.sh
    [[ $SHELL =~ bash ]] && openstack complete  > ~/.bash_custom/openstack_complete.sh
    echo "complete -F _openstack os" >> ~/.bash_custom/openstack_complete.sh
}

function openstack.unset_env {
    unset $(env | grep '^OS_' | cut -d= -f1) 2> /dev/null
}

function openstack.token {
    cached_catalog=$(openstack catalog list -f json)
    cached_token=$(openstack token issue -f json)
    user_id=$(echo $cached_token | jq -r .user_id)
    cache_file=/dev/shm/os_catalog__${user_id}
    echo $cached_catalog > $cache_file

    export OS_CACHED_CATALOG=$cache_file
    export OS_CACHED_TOKEN=$(echo $cached_token | jq -r .id)
}

alias o="os --nojson"
alias oss="os server"
alias osc="os compute"
alias osn="os network"
alias osb="os baremetal"
alias osv="os volume"
alias osi="os image"
# nova
alias osshost="os server list --all --host"
# octavia
alias osl="os loadbalancer"
alias osla="os loadbalancer amphora list --long --loadbalancer"
alias osdn="os port list --device-owner network:dhcp --long --network"
alias ostoken="openstack.token"
alias osunset=openstack.unset_env

if [[ -d ~/.os_openrc ]]; then

    function openstack.make_symlink_from_catalog
    {(
        file=${1:-openrc\..*}
        cd ~/.os_openrc
        for openrc in $(ls | grep -P "^$file$")
        do
            echo "* found openrc $openrc"
            source $openrc
            name=$(echo $openrc | sed -e 's/openrc\.//')
            openstack catalog list -f json | jq -r '.[] | select(.Name == "nova") | .Endpoints| .[].region' | while read REGION
            do
                echo "  > add ${REGION}__${name}"
                ln -sf $openrc ${REGION}__${name}.openrc
            done
        done
    )}

    function cr () {
        cr=$1
        openstack.unset_env
        openrc=$(ls ~/.os_openrc | grep -P '.openrc$' | grep -i $cr | head -1)
        region=$(echo $openrc | sed -re 's/(.*)__.*/\1/' | tr '[:lower:]' '[:upper:]')

        source ~/.os_openrc/$openrc
        export OS_REGION_NAME=$region
    }

    function list_cr () {
        for openrc in $(ls ~/.os_openrc | grep -P '.openrc$'); do
            echo $openrc | sed -e 's/.openrc$//' | tr '[:upper:]' '[:lower:]'
        done
    }

    function _complete_cr
    {
        local word=${COMP_WORDS[1]}
        COMPREPLY=($(list_cr | grep -Pi "^${word}"))
    }

    complete -F _complete_cr cr
fi

function openstack.port_list
{
    if [[ $1 =~ ^([0-9]+\.){3} ]] ; then
        os port list --long --fixed-ip ip-address=$1
    elif [[ $1 =~ ^([0-9a-f]{2}:){5} ]] ; then
        os port list --long --mac-address $1
    else
        os port list --long --device-id $1 || os port show $1
    fi
}

function openstack.port_show
{
    os port show $(openstack.port_list $1 | jq -r .[0].ID)
}

alias osports="openstack.port_list"
alias osport="openstack.port_show"

function openstack.get_snat
{
    os network agent list --long --router $*
}

alias osnat="openstack.get_snat"

function openstack.help
{
    cat<<EOF
#
# Upstream
#

# create new release note
apt install python3-reno
reno new xxx

#
# stestr
#

# init test env / launch tests
tox -e py3

# when env is already installed:
source .tox/py3/bin/activate

# Run one test
stestr run TEST

# Run one test with pdb
stestr run --no-discover TEST -- --pdb -k exec

# Run tests per unit with report

mv ~/neutron.tests_report.log ~/neutron.tests_report.\$(date +%s).log
find neutron/tests/unit/ -maxdepth 1  -exec basename {} \; | grep -v unit  | grep -v pycache | grep -v __init__ | sed -e 's/.py//' | while read u; do
    echo -e "\n=== START \$u ===="
    stestr run neutron.tests.unit.\$u
done | tee -a ~/neutron.tests_report.log
EOF
}

function devstack.get_logs {
    journalctl --no-hostname -o short-iso -u 'devstack@*' $* | oslog
}

function devstack.setup_pyright {
    [[ $USER -ne stack ]] && echo "need to be logged as stack user" && return
    source /opt/stack/data/venv/bin/activate
    cd /opt/stack
    for openstack_repo in $(find . -name requirements.txt -maxdepth 2 2> /dev/null | xargs dirname ); do
        (
            cd $openstack_repo
            python.setup_pyright
            pip install -e . --config-settings editable_mode=compat
        )
    done
}

alias stacklog="devstack.get_logs"


function devstack.svc_map {
    # Map real service names to devstack service names
    declare -A devstack_service_map=(
        ["dstat"]="devstack@dstat.service"
        ["etcd"]="devstack@etcd.service"
        ["glance-api"]="devstack@g-api.service"
        ["keystone"]="devstack@keystone.service"
        ["nova-api-metadata"]="devstack@n-api-meta.service"
        ["nova-api"]="devstack@n-api.service"
        ["nova-conductor"]="devstack@n-cond-cell1.service"
        ["nova-novncproxy"]="devstack@n-novnc-cell1.service"
        ["nova-scheduler"]="devstack@n-sch.service"
        ["nova-super-conductor"]="devstack@n-super-cond.service"
        ["neutron-api"]="devstack@neutron-api.service"
        ["neutron-periodic-workers"]="devstack@neutron-periodic-workers.service"
        ["neutron-rpc-server"]="devstack@neutron-rpc-server.service"
        ["placement-api"]="devstack@placement-api.service"
        ["neutron-openvswitch-agent"]="devstack@q-agt.service"
        ["neutron-dhcp-agent"]="devstack@q-dhcp.service"
        ["neutron-l3-agent"]="devstack@q-l3.service"
        ["neutron-metadata-agent"]="devstack@q-meta.service"
    )

    if [[ -n $1 ]]; then
        echo $devstack_service_map[$1]
    else
        echo ${(k)devstack_service_map} | tr -s ' ' '\n'
    fi
}

function devstack.systemd {
    local action=$1
    local service=$2

    if [[ -z "$(devstack.svc_map $service)" ]]; then
        echo "Error: Unknown service '$service'. Available services: $(devstack.svc_map)"
        return 1
    fi

    if [[ "$action" =~ ^(show|restart|start|stop|status)$ ]]; then
        sudo systemctl $action $(devstack.svc_map $service)
    elif [[ $action = kill ]]; then
        sudo systemctl kill -s 9 $(devstack.svc_map $service)
    elif [[ $action = guru ]]; then
        sudo systemctl kill -s USR2 $(devstack.svc_map $service)
    else
        echo "Error: Unknown action"
        return 1
    fi
}

function _complete_devstack_service
{
    local cur actions
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    actions="show restart start stop status kill guru"
    services="dstat etcd glance-api keystone nova-api-metadata nova-api nova-conductor nova-novncproxy nova-scheduler nova-super-conductor neutron-api neutron-periodic-workers neutron-rpc-server placement-api neutron-openvswitch-agent neutron-dhcp-agent neutron-l3-agent neutron-metadata-agent"

    if [[ ${COMP_CWORD} -eq 1 ]]; then
        COMPREPLY=( $(compgen -W "${actions}" -- ${cur}) )
    elif [[ ${COMP_CWORD} -eq 2 ]]; then
        COMPREPLY=( $(compgen -W "${services}" -- ${cur}) )
    fi
}

alias sysdev=devstack.systemd

complete -F _complete_devstack_service devstack.systemd
complete -F _complete_devstack_service sysdev


function devstack.venv_activate {
    source /opt/stack/data/venv/bin/activate
}

function openstack.router_delete {
    router=$1
    echo "Remove routes"
    os router set --no-route $router
    echo "Detach fip/port if any"
    os fip list --router $router | jq '.[] | .ID .Port'
    os fip list --router $router | jq -r '.[] | .ID + " " + .Port' | while read fip port; do
        if [[ -n $port ]]; then
            echo "- fip: $fip  port: $port"
            os fip unset $fip --port
        fi
    done
    echo "Detach subnets"
    for subnet in $(os router show $router 2> /dev/null | jq '.interfaces_info | .[] | .subnet_id' -r | sort -u); do
        echo "- subnet: $subnet"
        os router remove subnet $router $subnet
    done
    echo "Delete router"
    os router delete $router
}

function openstack.json_to_openrc
{
    prefix=$1
    jq -r --arg prefix "$prefix" 'to_entries | map("export \($prefix + .key | ascii_upcase)=\(.value)")|.[]'
}
