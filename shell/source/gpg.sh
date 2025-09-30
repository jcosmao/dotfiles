[[ ! -e $HOME/.gnupg ]] && return

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
