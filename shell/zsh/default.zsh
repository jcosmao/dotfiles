# history
export HISTFILE="$HOME/.history/zsh_history"
export HISTORY_IGNORE="(ls|cd|pwd|cd ..)"
export HISTSIZE=500000
export SAVEHIST=500000
setopt append_history
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt share_history

export PROMPT_EOL_MARK=''

# hook output is static per direnv version: cached, no fork at startup
common.cache_cmd_output ~/.cache/shell/direnv_hook.zsh direnv direnv hook zsh && source ~/.cache/shell/direnv_hook.zsh
