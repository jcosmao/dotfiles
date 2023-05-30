which ruby &> /dev/null || return

mkdir -p $HOME/.gem
alias gem_install="gem install --user-install"

# gem install bundler
# bundle install
export BUNDLE_PATH=$HOME/.gem
export GEM_HOME=$HOME/.gem

if [[ -d $HOME/.gem/ruby ]]; then
    v=$(ls $HOME/.gem/ruby | sort -rn | head -1)
    GEM_PATH="$HOME/.gem/ruby/${v}/bin"
    [[ -d $GEM_PATH ]] && export PATH="$PATH:$GEM_PATH"
fi
