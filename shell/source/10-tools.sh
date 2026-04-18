# Tools setup: gpg, git, FZF, tmux completions, XDG utils

# ========================================
# git
# ========================================

function git
{
    if [[ $1 = "review" ]]; then
        shift
        git.review $*
        return $?
    fi

    command git $*
}

function git.review
{
    target=$1
    topic=$2

    remote="gerrit"
    [[ -z $target ]] && target=$(git rev-parse --abbrev-ref HEAD)
    [[ -n $topic ]] && topic="%topic=${topic}"

    if [[ $# -eq 0 ]]; then
        echo "git.review <target branch: default(current tracked) ex: master> <topic: default(current branch name) OR null>"
        echo "No params provided. use defaults"
    fi

    gitreview_file=$(git rev-parse --show-toplevel)/.gitreview
    if [[ ! -f "$gitreview_file" ]]; then
        echo ".gitreview not found"
        return 1
    fi

    host=$(grep host= "$gitreview_file" | cut -d= -f2)
    port=$(grep port= "$gitreview_file" | cut -d= -f2)
    project=$(grep project= "$gitreview_file" | cut -d= -f2)

    # Configure gerrit remote if not exists
    if ! git remote | grep -q gerrit; then
        if [[ -n "$host" && -n "$port" && -n "$project" ]]; then
            git remote add gerrit "ssh://${host}:${port}/${project}"
            echo "Added gerrit remote: ssh://${host}:${port}/${project}"
            git fetch gerrit
        else
            echo "Error: .gitreview file is missing required fields (host, port, project)"
            return 1
        fi
    fi

    # validate remote branch exist
    validate=$(git branch -r --format='%(refname:strip=2)' | grep -P "^${remote}/${target}$")
    if [[ -z $validate ]]; then
        echo "${remote}/${target} not found, cannot submit pr"
        return 1
    fi

    echo "CMD: git push $remote HEAD:refs/for/${target}${topic}"
    [[ $SHELL =~ zsh ]] && vared -p 'Submit ? [y] ' -c response || read -r -p 'Submit ? [y] ' response
    if [[ $response = y ]]; then
        git push $remote HEAD:refs/for/${target}${topic}
    fi
}

function git.switch_remote {
    local remote_name="${1:-origin}"
    local current_url=$(git remote get-url "$remote_name" 2>/dev/null)

    if [[ -z "$current_url" ]]; then
        echo "Error: Remote '$remote_name' not found." >&2
        return 1
    fi

    if [[ "$current_url" == https* ]]; then
        local new_url=$(echo "$current_url" | sed 's|https://||; s|\.git$||')
        new_url="ssh://git@$new_url"
    elif [[ "$current_url" == git@* ]]; then
        local new_url=$(echo "$current_url" | sed 's|git@|https://|; s|$|.git|')
    elif [[ "$current_url" == ssh://* ]]; then
        local new_url=$(echo "$current_url" | sed 's|ssh://git@|https://|; s|\.git$||')
    else
        echo "Error: Unsupported remote URL format: $current_url" >&2
        return 1
    fi

    git remote set-url "$remote_name" "$new_url"
    echo "Switched $remote_name from $current_url to $new_url"
}

# ========================================
# GPG
# ========================================
export GPG_TTY=$(tty)

if [[ -z $SSH_CONNECTION ]]; then
    # ncurses gpg prompt
    if which pinentry-curses 2>&1 > /dev/null && \
        ! grep -q pinentry-program ~/.gnupg/gpg-agent.conf; then
        echo "pinentry-program $(which pinentry-curses)" >> ~/.gnupg/gpg-agent.conf
    fi

    ! grep -q default-cache-ttl ~/.gnupg/gpg-agent.conf && \
        echo "default-cache-ttl 3600" >> ~/.gnupg/gpg-agent.conf
else
    echo no-autostart > ~/.gnupg/gpg-agent.conf
fi

function gpg.help
{
    echo '
    Flags:

    PUBKEY_USAGE_SIG      S
    PUBKEY_USAGE_CERT     C
    PUBKEY_USAGE_ENC      E
    PUBKEY_USAGE_AUTH     A

    [SC] master key
    [SA] sign/auth key - can be used for ssh
    [E]  encrypt key
    [S]  signing key

    # Sign
    echo message | gpg --clearsign

    # Export private key / backup
    gpg --export-secret-key --armor -o private.asc 742B9A262BFA5B982272F03D9A49C2939019C5A0

    # Export private subkeys
    gpg --export-secret-subkeys --armor -o private-sub.asc 742B9A262BFA5B982272F03D9A49C2939019C5A0

    # Keep only subkeys / offline master key
    # then reimport subkey only
    gpg --delete-secret-key 742B9A262BFA5B982272F03D9A49C2939019C5A0
    gpg --import private-subkeys.asc

    # Edit subkeys with offline master
    gpg.offline_master_edit ./path/to/private.asc
    '
}

function gpg.reload_agent
{
    echo RELOADAGENT | gpg-connect-agent
    echo test_sign | gpg --clearsign
}

function gpg.offline_master_edit
{
    priv_key_asc=$1; shift
    if [[ ! -f $priv_key_asc ]]; then
        echo "Need to provide master key in asc format"
        return
    fi

    function gpg.offline_master.clean {
        tmpdir=$1
        [[ -f $tmpdir/S.gpg-agent ]] && gpg-connect-agent --homedir $tmpdir KILLAGENT /bye
        rm -rf $tmpdir
    }

    # Create temporary GnuPG home directory
    tmpdir=$(mktemp -d -p /tmp gpg.XXXXXX)
    trap "gpg.offline_master.clean $tmpdir; return" SIGINT

    keyid=$(gpg --list-packets $priv_key_asc | awk '$1=="keyid:"{print$2}' | head -1)

    echo "Start edit key id: $keyid"

    echo "pinentry-program $(which pinentry-curses)" > $tmpdir/gpg-agent.conf
    echo "default-cache-ttl 600" >> $tmpdir/gpg-agent.conf

    # Import the private keys
    gpg --homedir $tmpdir --import $priv_key_asc

    # Launch GnuPG from the temporary directory,
    # with the default public keyring
    pubring=$(find $HOME/.gnupg -regex '.*pubring\.[a-z]+' -regextype posix-extended | head -1)
    gpg --homedir $tmpdir --keyring $pubring --expert --edit-key $keyid $@

    # export
    echo "* Export master/subkeys to $HOME"
    gpg --homedir $tmpdir --export-secret-key --armor -o ~/master.${keyid}.asc
    gpg --homedir $tmpdir --export-secret-subkeys --armor -o ~/subkeys.${keyid}.asc

    gpg.offline_master.clean $tmpdir
}

function gpg.trust_key
{
    key=$1
    level=${2:-4}

    if [[ -z $key ]]; then
        echo "
    $0 <key_identifier> <trust level: default=4>

    levels:
        1 = I don't know or won't say
        2 = I do NOT trust
        3 = I trust marginally
        4 = I trust fully
        5 = I trust ultimately"
    return
    fi

    if [[ -f $key ]]; then
        # it's a file, import before
        gpg --import --armor $key
        key_id=$(gpg --with-colons $key | grep ^sub | cut -d: -f5)
    else
        key_id=$key
    fi

    (echo trust & echo $level & echo y & echo quit) | gpg --command-fd 0 --batch --edit-key $key_id &> /dev/null
    echo quit | gpg --command-fd 0 --edit-key $key_id
}

function gpg.upload_key
{
    key=$1
    if [[ -z $key ]]; then
        echo "Need to provide key id"
        return
    fi

    keyservers=(
        https://keyserver.ubuntu.com
        https://keys.openpgp.org
    )

    for k in ${keyservers[*]}; do
        gpg --keyserver $k --send-key $key
    done
}


function gpg.ssh_forward_get_options
{
    user_at_host=$1
    key=$2

    if [[ -z $user_at_host || -z $key ]]; then
        echo "gpg.ssh_forward_get_options <user@host> <gpg key id/mail..>"
        return 1
    fi

    function init_gpg_remote
    {
        gpg_pubkey_b64=$1

        # create gpg dir if not exist
        gpg -K &> /dev/null

        echo no-autostart > ~/.gnupg/gpg-agent.conf
        gpgconf --kill gpg-agent
        rm -f $(gpgconf --list-dirs agent-socket)

        echo $gpg_pubkey_b64 | base64 -d | gpg --import -
    }

    # force remove gpg cache
    echo RELOADAGENT | gpg-connect-agent &> /dev/null
    # then test sign with key, it will prompt for passphrase or raise error if key not found
    echo test_sign | gpg --clearsign -u $key -o /dev/null

    # prepare remote host for gpg forward
    ssh $user_at_host "$(declare -f init_gpg_remote); init_gpg_remote $(gpg --export --armor $key | base64 -w0)" &> /dev/null

    # -R remote_socket:local_socket
    # local should be agent-extra-socket for restricted access, but it does not work...
    # then use ssh $(gpg.ssh_forward_get_options plop@plop) plop@plop ...
    echo "-R $(ssh $user_at_host 'gpgconf --list-dirs agent-socket'):$(gpgconf --list-dirs agent-socket)
          -o StreamLocalBindUnlink=yes"
}

function gpg.infos
{
	key=$1

    if [[ -z $key ]]; then
        echo "missing key id or asc file"
        return
    fi

    if [[ -f $key ]]; then
        gpgopts=("--import-options" "show-only" "--import")
    else
        gpgopts=("--list-keys")
    fi

    gpg --keyid-format long --with-keygrip --fingerprint ${gpgopts[*]} $key
}

# ========================================
# FZF
# ========================================
# ctrl-r : history
# ctrl-t : file search
# alt-c  : cd directory
export FZF_DEFAULT_COMMAND='fd --type f --no-ignore --hidden --follow --exclude .git --exclude .pyc --exclude __pycache__'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--height 50% --preview '(bat --style=numbers --color=always {} || cat {}) 2> /dev/null | head -200'"
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"

# FZF custom commands

# pass
alias pass='PASSWORD_STORE_ENABLE_EXTENSIONS=true pass fzf'

# select background jobs
function j
{
    job=$(echo $(jobs | fzf +m -0 -1) | grep -Po '(?<=^\[)\d+')
    [[ -n $job ]] && fg $job || return 0
}

# ========================================
# tmux completions
# ========================================
# vim: ft=sh

unalias tm 2> /dev/null

# tmux functions
function _complete_tm_session
{
    COMPREPLY=()
    local session_name="${COMP_WORDS[COMP_CWORD]}"

    COMPREPLY=($(compgen -W "$(tm)" -- "$session_name") $( tm --help | grep -Eo '\-\-\w+' 2> /dev/null | sort -u | xargs))
}

complete -F _complete_tm_session tm

# ========================================
# XDG utils
# ========================================
function xdg.get_extension_mimetype
{
    extension=$1
    if [[ -z $extension ]]; then
        echo "Need file extension"
        return 1
    fi

    if [[ -f $extension ]]; then
        file=$extension
    else
        file=/tmp/get_extension_mimetype.${extension}
        touch $file
        clean=1
    fi

    xdg-mime query filetype $file
    [[ $clean -eq 1 ]] && rm -f $file
}

function xdg.list_known_applications
{
    find /usr/share/applications $HOME/.local/share/applications -name '*.desktop' | while read desktop; do
        basename $desktop
    done | sort
}

function xdg.show_application
{
    application=$1
    app_path=$(find /usr/share/applications $HOME/.local/share/applications -name '*.desktop' | grep $application)
    echo -n "File: $app_path\n\n"
    cat $app_path
}

function xdg.get_default_application
{
    extension=$1
    xdg-mime query default $(xdg.get_extension_mimetype $extension)
}

function xdg.set_default_application
{
    file_or_extension=$1
    app=$2

    if [[ $# -ne 2 ]]; then
        echo "xdg.set_default_application <file_or_extension> <application>"
        return 1
    fi

    mime=$(xdg.get_extension_mimetype $file_or_extension)
    xdg.list_known_applications | grep -q "$app"
    [[ $? -ne 0 ]] && echo "Unknown app" && return 1

    xdg-mime default $app $mime
}

function xdg.open
{
    nohup xdg-open "$*" </dev/null >/tmp/open.log 2>&1 &
}

function xdg.apply_mimetype
{
    desktop=$1
    [[ -z $desktop ]] && "Need file.desktop with MimeType=.." && return
    for t in $(cat $desktop | grep MimeType= | cut -d= -f2- | tr -s ';' ' '); do
        xdg-mime default $desktop $t && \
            echo "$desktop applied default for type: $t"
    done
}

function _complete_known_app
{
    local cur=${COMP_WORDS[1]}
    [[ $COMP_CWORD -eq 1 ]] && COMPREPLY=($(compgen -f -- "${word}"))
    [[ $COMP_CWORD -eq 2 ]] && COMPREPLY=($(compgen -W "$(xdg.list_known_applications)" -- ${cur}))
}

function _complete_known_app2
{
    local cur=${COMP_WORDS[1]}
    COMPREPLY=($(compgen -W "$(xdg.list_known_applications)" -- ${cur}))
}

complete -F _complete_known_app xdg.set_default_application
complete -F _complete_known_app2 xdg.show_application

alias open="xdg.open"
