#!/bin/bash

SCRIPT=$(readlink -f $0)
SCRIPTPATH=$(dirname $SCRIPT)
cd $SCRIPTPATH

function update ()
{
    echo "- Update all submodules"
    # To update submodule to HEAD
    # git submodule update --init --remote
    git submodule update --init --recursive
    git pull --recurse-submodules
    (
        cd vim/bundle/YouCompleteMe
        git submodule update --init --recursive
    )
}

function install_bash ()
{
    echo "- Install bash files"
    rm -rf ~/.bash
    cp -r bash ~/.bash
    ln -sf ~/.bash/bashrc ~/.bashrc
    ln -sf ~/.bash/dir_colors ~/.dir_colors
    echo "source ~/.bashrc" > ~/.bash_profile
    mkdir -p ~/bin
    mkdir -p ~/.bash_custom
}

function install_zsh ()
{
    _antigen_update
    echo "- Install zsh"
    rm -rf ~/.zsh
    cp -r zsh ~/.zsh
    ln -sf ~/.zsh/zshrc ~/.zshrc
}

function _antigen_update()
{
    #http://antigen.sharats.me/
    echo '- Get last antigen from git.io/antigen'
    curl -sL git.io/antigen > zsh/antigen.zsh
    # cleanup old antigen install
    rm -rf $HOME/.antigen
}

function install_vim ()
{
    echo "- Install vim"
    rm -rf ~/.vim
    cp -r vim ~/.vim
    ln -sf ~/.vim/vimrc ~/.vimrc
    # compile ycm
    (
        cd ~/.vim/bundle/YouCompleteMe
        ./install.py --quiet
        #--clang-complete
    )
    # fuzzysearch
    (
        cd ~/.vim/bundle/fzf
        ./install --no-update-rc --key-bindings --completion --xdg
    )
}

function install_tmux ()
{
    echo "- Install tmux"
    rm -rf ~/.tmux
    cp -r tmux ~/.tmux
    ln -sf ~/.tmux/tmux.conf ~/.tmux.conf
    ln -sf ~/.tmux/tm.completion.source ~/.bash/completions/tm.completion.source
    ln -sf ~/.tmux/tm ~/bin/tm
}

function install_git ()
{
    echo "- Install git"
    rm -rf ~/.git
    cp -r git ~/.git
    ln -sf ~/.git/gitconfig ~/.gitconfig
    read -p 'git username : ' git_username
    read -p 'git mail : ' git_mail
    [[ -n $git_username ]] && sed -i "s/USERNAME/$git_username/g" ~/.gitconfig
    [[ -n $git_mail ]] && sed -i "s/MAIL/$git_mail/g" ~/.gitconfig
}

function install_terminal ()
{
    echo "- Install fonts"
    font_dir="$HOME/.fonts"
    rm -rf $font_dir
    cp -rp terminal/fonts $font_dir
    if [[ -f $(which fc-cache 2>/dev/null) ]]; then
        echo "Resetting font cache..."
        fc-cache -f $font_dir
    fi

    if which gnome-terminal 2>&1 > /dev/null; then
        echo "- Install gnome-terminal color scheme"
        for theme in $( ls terminal/gnome-terminal ); do
            echo "  - $theme"
            bash terminal/gnome-terminal/$theme
        done
    fi

    if which urxvt 2>&1 > /dev/null; then
        echo "- Configure urxvt"
        rm -rf $HOME/.urxvt
        cp -r terminal/urxvt $HOME/.urxvt
        cp $HOME/.urxvt/config $HOME/.Xresources
        xrdb -merge $HOME/.Xresources
    fi

    if which termite 2>&1 > /dev/null; then
        echo "- Configure termite"
        rm -rf $HOME/.config/termite
        cp -r terminal/termite $HOME/.config
    fi
}

function install_i3 ()
{
    echo '- Install i3'
    rm -rf "$HOME/.i3"
    cp -r i3 ~/.i3
    ln -sf ~/.i3/i3status.conf ~/.i3status.conf
    rm -rf "$HOME/.config/dunst"
    cp -r dunst ~/.config
}

function install_poezio ()
{
    echo '- Install poezio'
    rm -rf "$HOME/.config/poezio"
    cp -r poezio ~/.config
}


function print_help ()
{
    echo "
    $0 [--update|--bash|--zsh|--vim|--tmux|--git|--term|--i3|--poezio]

    # Require:
     - bash: python-yaml, python-json, jq
     - terminal: gnome-terminal, rxvt-unicode, termite
     - i3: i3-wm i3status i3lock xautolock dunst
     - vim: silversearcher-ag / fd (https://github.com/sharkdp/fd)
    "

    exit
}

function main ()
{
    echo "Install dotfiles for user $USER"

    [[ $# -eq 0 ]] && print_help

    while [[ $# -ne 0 ]]; do
        arg="$1"; shift
        case "$arg" in
            --update)   update ;;
            --bash)     install_bash ;;
            --zsh)      install_zsh ;;
            --vim)      install_vim ;;
            --tmux)     install_tmux ;;
            --git)      install_git ;;
            --i3)       install_i3 ;;
            --poezio)   install_poezio ;;
            --term)     install_terminal ;;
            --help)     print_help ;;
            * ) [[ $arg =~ \-+.* ]] && print_help "$arg unknown"
        esac
    done

    echo "Install dotfiles done !"
}

main "$@"
