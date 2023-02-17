# Go path
if which go &> /dev/null; then
    GOROOT=$(go env GOROOT)
    export GOROOT=${GOROOT:-/usr/local/go}
    export GOPATH="$HOME/go"
    export GOBIN="$GOPATH/bin"
    export PATH="$PATH:$GOROOT/bin:$GOBIN"

    function gotest
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

fi

# Ruby path
if which ruby &> /dev/null; then
    mkdir -p $HOME/.gem
    alias gem_install="gem install --user-install"

    # gem install bundler
    # bundle install
    export BUNDLE_PATH=$HOME/.gem
    export GEM_HOME=$HOME/.gem

    if [[ -d $HOME/.gem/ruby ]]; then
        v=$(ls $HOME/.gem/ruby | head -1)
        GEM_PATH="$HOME/.gem/ruby/${v}/bin"
        [[ -d $GEM_PATH ]] && export PATH="$PATH:$GEM_PATH"
    fi
fi
