function xdg.get_extension_mimetype
{
    extension=$1
    if [[ -z $extension ]]; then
        echo "Need file extension"
        return 1
    fi

    if [[ -f $extension ]]; then
        file=$extension
    else
        file=/tmp/get_extension_mimetype.${extension}
        touch $file
        clean=1
    fi

    xdg-mime query filetype $file
    [[ $clean -eq 1 ]] && rm -f $file
}

function xdg.list_known_applications
{
    find /usr/share/applications $HOME/.local/share/applications -name '*.desktop' | while read desktop; do
        basename $desktop
    done | sort
}

function xdg.show_application
{
    application=$1
    app_path=$(find /usr/share/applications $HOME/.local/share/applications -name '*.desktop' | grep $application)
    echo -n "File: $app_path\n\n"
    cat $app_path
}

function xdg.get_default_application
{
    extension=$1
    xdg-mime query default $(xdg.get_extension_mimetype $extension)
}

function xdg.set_default_application
{
    file_or_extension=$1
    app=$2

    if [[ $# -ne 2 ]]; then
        echo "xdg.set_default_application <file_or_extension> <application>"
        return 1
    fi

    mime=$(xdg.get_extension_mimetype $file_or_extension)
    xdg.list_known_applications | grep -q "$app"
    [[ $? -ne 0 ]] && echo "Unknown app" && return 1

    xdg-mime default $app $mime
}

function xdg.open
{
    nohup xdg-open "$*" </dev/null >/tmp/open.log 2>&1 &
}

function xdg.apply_mimetype
{
    desktop=$1
    [[ -z $desktop ]] && "Need file.desktop with MimeType=.." && return
    for t in $(cat $desktop | grep MimeType= | cut -d= -f2- | tr -s ';' ' '); do
        xdg-mime default $desktop $t && \
            echo "$desktop applied default for type: $t"
    done
}

function _complete_known_app
{
    local cur=${COMP_WORDS[1]}
    [[ $COMP_CWORD -eq 1 ]] && COMPREPLY=($(compgen -f -- "${word}"))
    [[ $COMP_CWORD -eq 2 ]] && COMPREPLY=($(compgen -W "$(xdg.list_known_applications)" -- ${cur}))
}

function _complete_known_app2
{
    local cur=${COMP_WORDS[1]}
    COMPREPLY=($(compgen -W "$(xdg.list_known_applications)" -- ${cur}))
}

complete -F _complete_known_app xdg.set_default_application
complete -F _complete_known_app2 xdg.show_application

alias open="xdg.open"
