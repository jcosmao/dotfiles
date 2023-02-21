# https://github.com/pyenv/pyenv-installer
export PYENV_ROOT="$HOME/.pyenv"

function pyenv-load
{
    if [[ -d $PYENV_ROOT ]]; then
        if [[ -f $PYENV_ROOT/bin/pyenv ]]; then
            export PATH="$PYENV_ROOT/bin:$PATH"
            # eval "$(pyenv init --path)"
            eval "$(pyenv init -)"
            eval "$(pyenv virtualenv-init -)"
        fi
        export PYENV_VIRTUALENV_DISABLE_PROMPT=1
    else
        echo "pyenv not installed. > pyenv-update"
    fi
}

[[ -d $PYENV_ROOT ]] && pyenv-load

function pyenv-build-requirements
{
    apt-get install -y build-essential libssl-dev zlib1g-dev
    echo "
        $ pyenv install 3.9.0
        $ pyenv virtualenv 3.9.0 nvim
    "
}

function pyenv-update
{
    if [[ ! -f $PYENV_ROOT/bin/pyenv ]]; then
        git clone https://github.com/pyenv/pyenv.git $PYENV_ROOT
        git clone https://github.com/pyenv/pyenv-virtualenv.git $PYENV_ROOT/plugins/pyenv-virtualenv
    else
        (cd $PYENV_ROOT && git pull)
        (cd $PYENV_ROOT/plugins/pyenv-virtualenv && git pull)
    fi
}

