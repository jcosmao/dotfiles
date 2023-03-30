# ctrl-r : history
# ctrl-t : file search
# alt-c  : cd directory
export FZF_DEFAULT_COMMAND='fd --type f --no-ignore --hidden --follow --exclude .git --exclude .pyc --exclude __pycache__'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--height 50% --preview '(bat --style=numbers --color=always {} || cat {}) 2> /dev/null | head -200'"
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
 --color=fg:#d9d1ba,bg:#201c24,hl:#9e8462
 --color=fg+:#8ac22b,bg+:#201c24,hl+:#ffb35c
 --color=info:#afaf87,prompt:#ffae00,pointer:#af5fff
 --color=marker:#87ff00,spinner:#af5fff,header:#87afaf'

# FZF custom commands

# interactive pacman
alias pac="pacman -Slq | fzf -m --preview 'pacman -Si {1}' | xargs -r sudo pacman -S --noconfirm"
alias apts='apt-cache search . | awk "{print \$1}" | fzf -m --preview "apt-cache show {1}" | xargs -r sudo apt install -y'

# pass
alias pass='PASSWORD_STORE_ENABLE_EXTENSIONS=true pass fzf'

# select background jobs
function job
{
    job=$(echo $(jobs | fzf +m -0 -1) | grep -Po '(?<=^\[)\d+')
    [[ -n $job ]] && fg $job || return 0
}
