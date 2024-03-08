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

function vim.which {
    vim $(which $1)
}
alias vwhich="vim.which"

alias pip="python3 -m pip"
alias pip3="python3 -m pip"

alias ofc='ofctl --names --no-stats --read-only --color=always dump-flows'

which terraform &> /dev/null
if [[ $? == 0 ]]; then

    function tf
    {
        OPTS=""
        if [[ $1 == auto-approve ]]; then
            shift
            OPTS="-auto-approve"
        fi

        TFDIR="default"
        [[ -n $OS_REGION_NAME ]] && TFDIR="$OS_REGION_NAME"

        TF_WORKSPACE=$TFDIR terraform $* $OPTS
    }

    alias tfy="tf auto-approve"
    complete -C $(which terraform) terraform
    complete -C $(which terraform) tf
    complete -C $(which terraform) tfy
fi

if [[ $(id -u) > 0 ]]; then
    alias docker="sudo docker"
    alias docker-compose="sudo docker-compose"
fi
