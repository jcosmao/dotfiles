# ctrl-r : history
# ctrl-t : file search
# alt-c  : cd directory
export FZF_DEFAULT_COMMAND='fd --type f --no-ignore --hidden --follow --exclude .git --exclude .pyc --exclude __pycache__'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
export FZF_CTRL_T_OPTS="--height 50% --preview '(bat --style=numbers --color=always {} || cat {}) 2> /dev/null | head -200'"


# FZF custom commands

# interactive pacman
alias pac="pacman -Slq | fzf -m --preview 'pacman -Si {1}' | xargs -r sudo pacman -S --noconfirm"
alias apts='apt-cache search . | awk "{print \$1}" | fzf -m --preview "apt-cache show {1}" | xargs -r sudo apt install -y'

# select background jobs
function job
{
    job=$(echo $(jobs | fzf +m -0 -1) | grep -Po '(?<=^\[)\d+')
    [[ -n $job ]] && fg $job || return 0
}
