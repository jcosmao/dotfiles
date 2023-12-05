unset GOROOT
utils.add_to_PATH $HOME/.local/go/bin
which go &> /dev/null || return

utils.add_to_PATH $HOME/go/bin

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
