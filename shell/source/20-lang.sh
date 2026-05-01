# Language setup: Go, Rust, Ruby, Node.js (nvm), Python

# ========================================
# Go
# ========================================
function go.install
{(
    version=$1
    [[ -z $version ]] && echo "Missing version" && return

    set -xe
    wget "https://go.dev/dl/go${version}.linux-amd64.tar.gz" -O /tmp/go.tar.gz
    dir="$HOME/.local/download/go.${version}"
    rm -rf "$dir" && mkdir -p "$dir"
    tar xzf /tmp/go.tar.gz -C  "$dir"
    ln -sf "$dir/go" ~/.local/go
)}

[[ -d "$HOME/.local/go/bin" ]] && \
    path.prepend "$HOME/.local/go/bin" && \
    export GOROOT="$HOME/.local/go"

[[ -d "$HOME/go/bin" ]] && \
    path.prepend "$HOME/go/bin" && \
    export GOPATH="$HOME/go"

# do not depends on glibc
export CGO_ENABLED=0
export GOFLAGS=-buildvcs=false
export GOTMPDIR=$HOME/go/tmp
mkdir -p $GOTMPDIR

function go.testify
{
    func=${1:-.*}
    if [[ $func == *'/'* ]]; then
        suite=$(echo $func | cut -d/ -f1)
        func=$(echo $func | cut -d/ -f2)
    else
        suite=".*"
    fi
    # syntax error bash
    # go test -run ^${suite}$ -testify.m ^(${func})$ -v . | ccze -A
    go test -run ^${suite}$ -testify.m ^\(${func}\)$ -v . | ccze -A
}

# ========================================
# Rust
# ========================================
[[ -z $CARGO_HOME ]] && export CARGO_HOME=$HOME/.cargo
[[ -z $RUSTUP_HOME ]] && export RUSTUP_HOME=$HOME/.rustup
export CARGO_TARGET_DIR=$HOME/.cache/cargo-target

[[ -d $CARGO_HOME ]] && path.prepend "$CARGO_HOME/bin"

# ========================================
# Ruby
# ========================================
mkdir -p $HOME/.gem
alias gem_install="gem install --user-install"

# gem install bundler
# bundle install
export BUNDLE_PATH=$HOME/.gem
export GEM_HOME=$HOME/.gem

# Cache lookup - only check once per shell session
if [[ -z $GEM_PATH_CACHED && -d $HOME/.gem/ruby ]]; then
    v=$(ls $HOME/.gem/ruby/ | sort -rn | head -1)
    GEM_PATH="$HOME/.gem/ruby/${v}/bin"
    [[ -d $GEM_PATH ]] && path.append $GEM_PATH
    export GEM_PATH_CACHED=1
fi

# ========================================
# Node.js (nvm)
# ========================================
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

# ========================================
# Python
# ========================================

# force run those command using pyenv python
# alias pip="python3 -m pip"
# alias pip3="python3 -m pip"
# alias pipx="python3 -m pipx"
# alias tox="python3 -m tox"

function python.setup_flake
{
    line_len=${1:120}

    project_root=$(utils.find_project_root .project)
    [[ -z $project_root ]] && project_root=$(utils.find_project_root .git)
    [[ -z $project_root ]] && echo "Project root not found" && return

    [[ -f "$project_root/.flake8" ]] && return

    found_line_len=$(find $project_root -maxdepth 1 -name pyproject.toml -o -name tox.ini | grep -P 'line-length' | awk -F= '{print $2}' | tail -1)
    [[ -n $found_line_len ]] && line_len=$found_line_len

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

function venv
{
    if [[ $# -eq 0 ]]; then
        echo "Usage: venv <environment_name>"
        echo "Available environments in ~/.venvs:"
        ls -1 ~/.venvs
        return 1
    fi
    source "$HOME/.venvs/$1/bin/activate"
}

_venv_completion() {
    local cur
    cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=($(compgen -W "$(ls -1 ~/.venvs 2>/dev/null)" -- "$cur"))
}

complete -F _venv_completion venv

function python.auto_venv() {
    local git_root
    git_root=$(git rev-parse --show-toplevel 2>/dev/null) || return

    local venv_path=""
    # .venv dans le repo
    if [[ -d "$git_root/.venv" ]]; then
        venv_path="$git_root/.venv"
    # ~/.venvs/<nom-du-repo>
    elif [[ -d "$HOME/.venvs/$(basename "$git_root")" ]]; then
        venv_path="$HOME/.venvs/$(basename "$git_root")"
    fi

    if [[ -n "$venv_path" && "$VIRTUAL_ENV" != "$venv_path" ]]; then
        source "$venv_path/bin/activate"
    fi
}

if [[ $SHELL =~ zsh ]]; then
    autoload -U add-zsh-hook
    add-zsh-hook chpwd python.auto_venv
fi
