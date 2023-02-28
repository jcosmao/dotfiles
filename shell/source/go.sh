which go &> /dev/null || return

GOROOT=$(go env GOROOT)
export GOROOT=${GOROOT:-/usr/local/go}
export GOPATH="$HOME/go"
export GOBIN="$GOPATH/bin"
export PATH="$PATH:$GOROOT/bin:$GOBIN"

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
