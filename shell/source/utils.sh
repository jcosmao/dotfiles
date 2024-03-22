function utils.dotfiles_update
{
    [[ ! -e ~/.dotfiles ]] && return 1
    (cd ~/.dotfiles; git fetch; git stash save "$(date +"%m/%d/%Y") - $0"; git reset --hard origin/master)
    [[ $SHELL =~ zsh ]] && exec zsh
    [[ $SHELL =~ bash ]] && exec bash
}

function utils.zsh_update
{
    [[ ! -d ~/.zsh ]] && return 1
    pwd=$(pwd)
    maxwidth=0
    for module in $(ls ~/.zsh); do
        width=$(echo $module | wc -c)
        [[ $width -gt $maxwidth ]] && maxwidth=$width
    done
    set +o monitor
    echo "* Update zsh modules (~/.zsh):"
    for module in $(ls ~/.zsh); do
        (
            cd ~/.zsh/$module
            git fetch |& > /dev/null
            git reset --hard origin/master |& > /dev/null
            if [[ $? -eq 0 ]]; then
                value=$(colors.print 10 OK)
            else
                value=$(colors.print 9 FAIL)
            fi
            commit=$(git rev-parse --short HEAD)
            mod=$(printf "[%-${maxwidth}s]" $module)
            printf "%s master[%s]: %s\n" "$(colors.print 13 $mod)" $(colors.print 244 $commit) $value
        )&
    done
    wait
    set -o monitor
    cd $pwd
    exec zsh
}

function utils.json ()
{
    jq=$(which jq)
    if [[ -n $jq ]]; then
        $jq .
    else
        python -mjson.tool
    fi
}

function utils.json2yaml ()
{
    python -c 'import sys, yaml, json; yaml.safe_dump(json.load(sys.stdin), sys.stdout, default_flow_style=False)'
}

function utils.uuid ()
{
    grep -Po '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'
}

# useful to parse docker json logs for ex:  docker logs bla | jqlines
function utils.jqlines
{
    jq -Rr '. as $line | (fromjson?) // $line'
}

# same as jqlines, but interpret \n \t to display properly json value like long stacktrace
function utils.jqlines_format
{
    jq -CRr '. as $line | (fromjson?) // $line' | sed -e 's/\\n/\n/g' -e 's/\\t/    /g'
}

function utils.jqmap2csv
{
    jq -r '(.[0] | keys_unsorted) as $keys | ([$keys] + map([.[ $keys[] ]])) [] | @csv'
}

# csv to table display
function utils.pretty_csv {
    column -t -s, -n "$@" | less -F -S -X -K
}

function utils.open
{
    nohup xdg-open "$*" </dev/null >/tmp/open.log 2>&1 &
}

function utils.ssl_info
{
    [[ -z $1 ]] && echo "need domain" && return

    echo -e "== brief info =="
    echo | openssl s_client -connect $1 -brief

    echo -e "\n== Chain Info =="
    echo | openssl s_client -showcerts -connect $1 2>&1 | \
        sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p;/-END CERTIFICATE-/a\\x0' | \
        sed -e '$ d' | xargs -0rl -I% sh -c "echo '%' | openssl x509 -subject -issuer  -fingerprint -sha1 -dates -noout"
}

function utils.ssl_get
{
    [[ -z $1 ]] && echo "need domain" && return

    echo | \
        openssl s_client -showcerts -connect $1 </dev/null | \
        openssl x509 -text
}

function utils.randpass
{
    size=${1:-32}
    tr -cd '[:alnum:]' < /dev/urandom | fold -w $size | head -n1 | tr -d '\n'
}

function utils.randpass_b64
{
    password=$(utils.randpass $1)
    echo "password: $password"
    echo "base64: $(echo -n $password | base64 -w0)"
}

function ssh-rdp.help
{
    echo "https://github.com/kokoko3k/ssh-rdp"
    echo
    echo "Software requirements:
    * Local and Remote: bash,ffmpeg,openssh,netevent
    * Local: wmctrl, mpv >=0.29, taskset
    * Remote: xdpyinfo,pulseaudio

    yay -S netevent-git mpv wmctrl tevent vid.stab libvdpau-va-gl"

    echo
    echo "Reinit config:
    * rm ~/.config/ssh-rdp*config
        and ssh-rdp -u user -s remote"

    echo
    echo "Ex: without fwd audio
        ssh-rdp -u ju -s desk  --audioenc null
    "
}

function utils.wireguard_toggle
{
    iface=$(ip --json link show | jq -r '.[] | select(.ifname | test("^wg")) | .ifname')
    if [[ -n $iface ]]; then
        wg-quick down $iface
    else
        broadcast=$(ip --json a show  | jq -r '.[] | select(.operstate == "UP") | .addr_info.[0].broadcast' | head -1)
        if [[ $broadcast == 192.168.1.255 ]]; then
            # Do not route 192.168.1.0/24 in tunnel
            wg-quick up wg1
        else
            wg-quick up wg0
        fi
    fi
}

function utils.find_project_root
{(
    rootdir_pattern=${1:-.project}

    prev=.
    while [[ $PWD != "$prev" ]] ; do
        proot=$(find "$PWD" -maxdepth 1 -name $rootdir_pattern | grep .)
        [[ $? -eq 0 ]] && dirname $proot && exit
        prev=$PWD
        cd ..
    done
)}

alias dotup="utils.dotfiles_update"
alias zup="utils.zsh_update"
alias open="utils.open"
alias json="utils.json"
alias ssl_info="utils.ssl_info"
alias ssl_get="utils.ssl_get"
alias randpass="utils.randpass"
alias randpass64="utils.randpass_b64"
alias passgen="utils.randpass"
alias passgen64="utils.randpass_b64"
alias uuid="utils.uuid"
alias wg-toggle="utils.wireguard_toggle"
