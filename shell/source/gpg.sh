function gpg.import_and_trust
{
    if [[ ! -f $1 ]]; then
        echo "missing pub key file: gpg.import_and_trust <asc>"
        return
    fi

    # import in keyring
    gpg --import --armor $1
    kid=$(gpg  --with-colons $1 | grep ^sub | cut -d: -f5)
    # trust key
    (echo trust &echo 5 &echo y &echo quit) | gpg --command-fd 0 --edit-key $kid
}
