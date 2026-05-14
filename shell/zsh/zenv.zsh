autoload -U add-zsh-hook

_direnv_loaded=""

# Find the nearest .zenv file in current or parent directories
_direnv_find_all_zenv() {
    local dir=$PWD
    local -a zenv_files
    while [[ -n "$dir" ]]; do
        if [[ -f "$dir/.zenv" ]]; then
            zenv_files+=("$dir/.zenv")
        fi
        dir=${dir%/*}
    done
    # Return in reverse order (root first, then children)
    print -l -- "${(@Oa)zenv_files}"
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

_direnv_load_zenv() {
    local -a new_zenvs
    new_zenvs=($(_direnv_find_all_zenv))
    local new_zenv_str="${(j: :)new_zenvs}"

    local old_zenv=$_direnv_loaded

    # If the .zenv list changed, unload old and load new
    if [[ "$old_zenv" != "$new_zenv_str" ]]; then
        if [[ -n "$old_zenv" ]]; then
            _direnv_restore_env
        fi

        if [[ -n "$new_zenv_str" ]]; then
            _direnv_save_env
            for zenv_file in "${new_zenvs[@]}"; do
                source "$zenv_file"
            done
        fi

        _direnv_loaded="$new_zenv_str"
    fi
}

_direnv_chpwd() {
    # Skip during completion or non-interactive shells
    [[ ! -o interactive ]] && return
    [[ -v compstate ]] && return

    _direnv_load_zenv
}

# Load .zenv files on shell startup
_direnv_load_zenv

# Only add hook if not already added
if [[ -z "${chpwd_functions[(r)_direnv_chpwd]}" ]]; then
    add-zsh-hook chpwd _direnv_chpwd
fi
