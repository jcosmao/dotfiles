export CLIFF_FIT_WIDTH=1

function os {
    APPEND_OPTS=()
    [[ "$*" =~ (show|list|create|issue) ]] && APPEND_OPTS+=("-f" "json")
    [[ "$*" =~ (server list) ]] && APPEND_OPTS+=("-n")
    [[ "$*" =~ (console log show|--help$| -h$| help$) ]] && APPEND_OPTS=()
    if [[ $1 == "fip" ]]; then
        shift; set -- "floating ip" "${@:1}"
    elif [[ $1 == "lb" ]]; then
        shift; set -- "loadbalancer" "${@:1}"
    fi

    echo "${APPEND_OPTS[@]}" | grep -qw '\-f json' && PIPE_CMD="jq" || PIPE_CMD="tee"

    EXTRA_OPTS=()
    # Require at least 2.24 to get migration id + abort
    [[ "$*" =~ (server migration) ]] && EXTRA_OPTS+=("--os-compute-api-version" "2.24")

    openstack "${EXTRA_OPTS[@]}" $* "${APPEND_OPTS[@]}" | $PIPE_CMD
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
alias osunset=openstack.unset_env

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
        name=$(echo $openrc | sed -e 's/.openrc$//' | tr '[:upper:]' '[:lower:]')
        region=$(echo $openrc | sed -re 's/(.*)__.*/\1/' | tr '[:lower:]' '[:upper:]')
        alias cr_${name}="openstack.unset_env; source ~/.os_openrc/$openrc; export OS_REGION_NAME=${region}"
    done
fi

function openstack.port_list
{
    if [[ $1 =~ ^([0-9]+\.){3} ]] ; then
        os port list --long --fixed-ip ip-address=$1
    elif [[ $1 =~ ^([0-9a-f]{2}:){5} ]] ; then
        os port list --long --mac-address $1
    else
        os port list --long --device-id $1
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

function openstack.help_stestr
{
    cat<<EOF
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
    journalctl --no-hostname -o short-iso -u 'devstack@*' $*
}

alias stacklog="devstack.get_logs"

function devstack.venv_activate {
    source /opt/stack/data/venv/bin/activate
}

function openstack.router_delete {
    router=$1
    echo "Detach fip/port if any"
    os fip list --router $router | jq '.[] | .ID .Port'
    os fip list --router $router | jq -r '.[] | .ID + " " + .Port' | while read fip port; do
        if [[ -n $port ]]; then
            echo "- fip: $fip  port: $port"
            os fip unset $fip --port $port
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

function openstack.lb_show {
    lb=$1

    echo === LB $1 ===
    op loadbalancer show  $lb | grep --color=always -Pe '(ERROR|[^ ]+ING[^ ]+|^)'
    echo === AMPHORA ===
    op loadbalancer amphora list --loadbalancer  $lb --long | grep --color=always -Pe '(ERROR|[^ ]+ING[^ ]+|^)'
    echo === LISTENER ===
    op loadbalancer listener list --loadbalancer  $lb | grep --color=always -Pe '(ERROR|[^ ]+ING[^ ]+|^)'
    echo === POOL ===
    op loadbalancer pool list --loadbalancer  $lb | grep --color -Pe '(ERROR|[^ ]+ING[^ ]+|^)'

    for pool in $(os loadbalancer pool list --loadbalancer  $lb | jq -r .[].id); do
        echo === MEMBERS of pool $pool ===
        op loadbalancer member list $pool | grep --color -Pe '(ERROR|[^ ]+ING[^ ]+|^)'
    done
}
