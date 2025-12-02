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
    path.append "$HOME/.local/go/bin" && \
    export GOROOT="$HOME/.local/go"

[[ -d "$HOME/go/bin" ]] && \
    path.append "$HOME/go/bin" && \
    export GOPATH="$HOME/go"

# do not depends on glibc
export CGO_ENABLED=0
export GOFLAGS=-buildvcs=false

function go.test
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
