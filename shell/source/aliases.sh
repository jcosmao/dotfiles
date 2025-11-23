# vim: ft=sh

export TERM=xterm-256color
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
alias grpe=grep

alias ls='ls --color=auto'
alias dir='dir --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

function vim.which {
    vim $(which $1)
}
alias vwhich="vim.which"

alias ofc='ovs-ofctl --names --no-stats --read-only --color=always dump-flows'
alias ip6='ip -6'
alias ipb='ip -brief'
alias mtrr='mtr -wzbe'
