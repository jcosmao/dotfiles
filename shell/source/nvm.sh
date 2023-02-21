# Node JS
export NVM_DIR="$HOME/.nvm"

function nodejs.install
{
    # mkdir ~/.nvm  to auto install nodejs
    mkdir -p $NVM_DIR
    if [[ ! -f "$NVM_DIR/nvm.sh" ]]; then
        echo "NodeJS install"
        (
            git clone https://github.com/nvm-sh/nvm.git "$NVM_DIR"
            cd "$NVM_DIR"
            git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)`
        ) &> /dev/null
    else
        (cd $NVM_DIR && git pull)
    fi

    source $NVM_DIR/nvm.sh
    nvm install --lts
    nvm alias default node
    # sometimes node is installed with unknown user
    chown -R ${USER}: $NVM_DIR
}

function nodejs.load
{
    [[ -d $NVM_DIR ]] || return
    [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
}
