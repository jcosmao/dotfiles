# vim: ft=sh

export TERM=screen-256color
export VISUAL=vim
export EDITOR=vim
# tmux disable retitle
export DISABLE_AUTO_TITLE=true
export XDG_CONFIG_HOME=$HOME/.config
export RIPGREP_CONFIG_PATH=$HOME/.config/ripgreprc

if [[ -f $HOME/.local/bin/nvim ]]; then
    alias lvim="THEME=light nvim"
    alias dvim="THEME=dark nvim"
    alias vim="lvim"
    alias vimdiff="vim -d"
fi

# fucking keyboard
alias vi=vim
alias vun=vim
alias bim=vim
alias gti=git

function vim.which {
    vim $(which $1)
}
alias vwhich="vim.which"

alias ofc='ofctl --names --no-stats --read-only --color=always dump-flows'
