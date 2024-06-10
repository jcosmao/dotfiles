function common.get_sourceable_bash_files_ordered
{
    find /etc/profile.d/ ~/.bash_custom/ ~/.shell/ -type f -follow -name '*.sh'  2> /dev/null | while read file;do
        echo $(basename $file) $file
    done | sort -n | awk '{print $2}'
}

[[ -z $SOURCE ]] && export SOURCED=()

function is_already_sourced
{
    for f in "${SOURCE[@]}"; do
        [[ $f = "$1" ]] && return 0
    done
    return 1
}

function common.source
{
    for target in $*; do
        is_already_sourced $target && echo "$target already sourced" && continue
        builtin source $target
        SOURCE+=("$target")
    done
}
