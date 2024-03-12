# https://github.com/pyenv/pyenv-installer
export PYENV_ROOT="$HOME/.pyenv"

function pyenv.load
{
    if [[ -d $PYENV_ROOT ]]; then
        if [[ -f $PYENV_ROOT/bin/pyenv ]]; then
            [[ $PATH =~ .*${PYENV_ROOT}.* ]] || path.prepend $PYENV_ROOT/bin
            eval "$(pyenv init -)"
            # https://github.com/pyenv/pyenv-virtualenv/issues/259#issuecomment-1096144748
            eval "$(pyenv virtualenv-init - | sed s/precmd/chpwd/g)"
            _pyenv_virtualenv_hook
        fi
        export PYENV_VIRTUALENV_DISABLE_PROMPT=1
    else
        echo "pyenv not installed. > pyenv-update"
    fi
}

[[ -d $PYENV_ROOT ]] && pyenv.load

function pyenv.help
{
    echo "
        # Install a specific python version + build virtualenv with it
        $ apt-get install -y clang build-essential zlib1g-dev libffi-dev libssl-dev libbz2-dev libreadline-dev libsqlite3-dev liblzma-dev
        $ pyenv install -l
        # use clang compiler if it raise error
        $ pyenv install 3.9.0  || CC=clang pyenv install 3.9.0
        $ env PYTHON_CONFIGURE_OPTS='--enable-shared' pyenv install --verbose 3.9.13
        $ pyenv virtualenv 3.9.0 nvim

        # init working dir to autoload proper env
        $ mkdir nvim && echo nvim > nvim/.python-version
        $ pyenv versions
    "
}

function pyenv.install
{
    if [[ ! -f $PYENV_ROOT/bin/pyenv ]]; then
        git clone https://github.com/pyenv/pyenv.git $PYENV_ROOT
        git clone https://github.com/pyenv/pyenv-virtualenv.git $PYENV_ROOT/plugins/pyenv-virtualenv
    else
        (cd $PYENV_ROOT && git pull)
        (cd $PYENV_ROOT/plugins/pyenv-virtualenv && git pull)
    fi
}

function pyenv.update
{
    pyenv.install
}

function pyenv.setup_python_version
{
    [[ -z $VIRTUAL_ENV ]] && echo "VIRTUAL_ENV not set" && return
    echo $(basename $VIRTUAL_ENV) > .python-version
}

function pyenv.setup_flake
{
    project_root=$(utils.find_project_root .project)
    [[ -z $project_root ]] && project_root=$(utils.find_project_root .git)
    [[ -z $project_root ]] && echo "Project root not found" && return

    echo '[flake8]
max-line-length = 120' >> $project_root/.flake8
}

function pyenv.setup_pyright
{
    [[ -z $VIRTUAL_ENV ]] && echo "VIRTUAL_ENV not set" && return
    VENV=$(basename $VIRTUAL_ENV)
    VENVPATH=$(dirname $VIRTUAL_ENV)

    echo '{
        "venvPath": "VENVPATH",
        "venv": "VENV",
        "reportUnboundVariable": "information",
        "reportOptionalMemberAccess": "information"
    }' | sed "s,VENVPATH,$VENVPATH," | sed "s,VENV,$VENV," | jq > pyrightconfig.json
}

function pyenv.setup
{
    [[ -z $VIRTUAL_ENV ]] && echo "VIRTUAL_ENV not set" && return

    pyenv.setup_python_version
    pyenv.setup_pyright
    pyenv.setup_flake
}
