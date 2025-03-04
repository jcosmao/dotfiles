[[ ! -d $HOME/.cargo ]] && return

export CARGO_HOME=$HOME/.cargo
export RUSTUP_HOME=$HOME/.rustup

path.prepend "$CARGO_HOME/bin"
