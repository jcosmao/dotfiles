# https://github.com/pyenv/pyenv-installer
export PYENV_ROOT="$HOME/.pyenv"

# force run those command using pyenv python
alias pip="python3 -m pip"
alias pip3="python3 -m pip"
alias pipx="python3 -m pipx"
alias tox="python3 -m tox"

function python.setup_python_version
{
    [[ -z $VIRTUAL_ENV ]] && echo "VIRTUAL_ENV not set" && return
    echo $(basename $VIRTUAL_ENV) > .python-version
}

function python.setup_flake
{
    line_len=${1:120}

    project_root=$(utils.find_project_root .project)
    [[ -z $project_root ]] && project_root=$(utils.find_project_root .git)
    [[ -z $project_root ]] && echo "Project root not found" && return

    [[ -f "$project_root/.flake8" ]] && return

    found_line_len=$(grep -P 'line-length' $(find $project_root -maxdepth 1 -name pyproject.toml -o -name tox.ini) | awk -F= '{print $2}' | tail -1)
    if [[ -n $found_line_len ]] && line_len=$found_line_len

    echo "[flake8]"                    > "$project_root/.flake8"
    echo "max-line-length = $line_len" >> "$project_root/.flake8"
}

function python.setup_pyright
{
    [[ -z $VIRTUAL_ENV ]] && echo "VIRTUAL_ENV not set" && return
    VENV=$(basename $VIRTUAL_ENV)
    VENVPATH=$(dirname $VIRTUAL_ENV)

    echo '{
        "venvPath": "VENVPATH",
        "venv": "VENV",
        "typeCheckingMode": "standard",
        "reportUnboundVariable": "warning",
        "reportPossiblyUnboundVariable": "information",
        "reportOptionalMemberAccess": "information",
        "reportAttributeAccessIssue": "information"
    }' | sed "s,VENVPATH,$VENVPATH," | sed "s,VENV,$VENV," | jq > "$(git rev-parse --show-toplevel 2> /dev/null)/pyrightconfig.json"
}

function python.setup
{
    [[ -z $VIRTUAL_ENV ]] && echo "VIRTUAL_ENV not set" && return

    python.setup_python_version
    python.setup_pyright
    python.setup_flake
}


#
# PYENV
#

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


function pyenv.load
{
    if [[ -d $PYENV_ROOT ]]; then
        if [[ -f $PYENV_ROOT/bin/pyenv ]]; then
            [[ $PATH =~ .*${PYENV_ROOT}.* ]] || path.prepend $PYENV_ROOT/bin
            eval "$(pyenv init - $(basename $SHELL))"
            # https://github.com/pyenv/pyenv-virtualenv/issues/259#issuecomment-1096144748
            eval "$(pyenv virtualenv-init - | sed s/precmd/chpwd/g)"
            # _pyenv_virtualenv_hook
        fi
        export PYENV_VIRTUALENV_DISABLE_PROMPT=1
    else
        echo "pyenv not installed. > pyenv-update"
    fi
}

function pyenv.update
{
    pyenv.install
}

function pyenv.activate {
    pyenv.load
    pyenv activate "$*" 2> /dev/null
}


alias pya="pyenv.activate"

function _complete_pyenv_activate
{
    local word=${COMP_WORDS[1]}
    COMPREPLY=($(compgen -W "$(find $PYENV_ROOT/versions -maxdepth 1 -mindepth 1 -exec basename {} \; | xargs)" -- ${word}))
}

complete -F _complete_pyenv_activate pyenv.activate
complete -F _complete_pyenv_activate pya
