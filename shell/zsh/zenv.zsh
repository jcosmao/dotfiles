autoload -U add-zsh-hook

_direnv_loaded=""

# Find the nearest .zenv file in current or parent directories
_direnv_find_zenv() {
    local dir=$PWD
    while [[ -n $dir ]]; do
        if [[ -f $dir/.zenv ]]; then
            echo "$dir/.zenv"
            return 0
        fi
        dir=${dir%/*}
    done
    return 1
}

_direnv_save_env() {
    typeset -gA _direnv_saved
    local var
    for var in $(printenv | cut -d= -f1); do
        _direnv_saved[$var]="${(P)var}"
    done
}

_direnv_restore_env() {
    local var val
    # Restore saved variables
    for var in "${(@k)_direnv_saved}"; do
        val="${_direnv_saved[$var]}"
        if [[ -n "$val" ]]; then
            export "$var"="$val"
        else
            unset "$var"
        fi
    done
    
    # Unset variables that were added
    local current_var
    for current_var in $(printenv | cut -d= -f1); do
        if [[ -z "${_direnv_saved[$current_var]+x}" ]]; then
            unset "$current_var"
        fi
    done
    
    unset _direnv_saved
}

_direnv_chpwd() {
    # Skip during completion or non-interactive shells
    [[ ! -o interactive ]] && return
    [[ -v compstate ]] && return
    
    local old_zenv=$_direnv_loaded
    local new_zenv
    
    new_zenv=$(_direnv_find_zenv)
    
    # If the .zenv changed, unload old and load new
    if [[ "$old_zenv" != "$new_zenv" ]]; then
        if [[ -n "$old_zenv" ]]; then
            _direnv_restore_env
        fi
        
        if [[ -n "$new_zenv" ]]; then
            _direnv_save_env
            source "$new_zenv"
        fi
        
        _direnv_loaded="$new_zenv"
    fi
}

# Only add hook if not already added
if [[ -z "${chpwd_functions[(r)_direnv_chpwd]}" ]]; then
    add-zsh-hook chpwd _direnv_chpwd
fi
