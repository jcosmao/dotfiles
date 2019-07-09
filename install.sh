#!/bin/bash

SCRIPT=$(readlink -f $0)
SCRIPTPATH=$(dirname $SCRIPT)
cd $SCRIPTPATH

mkdir -p ~/bin

function update_repo ()
{
    echo "- Update dotfiles repo"
    git fetch
    git ls-files --others --exclude-standard | xargs rm -rf
    git clean -xfd
    git submodule foreach --recursive git clean -xfd
    git reset --hard
    git submodule foreach --recursive git reset --hard
    git submodule update --init --recursive
}

function install_bash ()
{
    echo "- Install bash files"
    rm -rf ~/.bash
    cp -r bash ~/.bash
    ln -sf ~/.bash/bashrc ~/.bashrc
    ln -sf ~/.bash/dir_colors ~/.dir_colors
    ln -sf ~/.bash/agignore ~/.agignore
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

function install_neovim ()
{
    echo "- Update neovim from latest"
    wget https://github.com/neovim/neovim/releases/download/stable/nvim.appimage -O /tmp/nvim.appimage 2>/dev/null || \
        cp nvim/nvim.appimage /tmp
    chmod +x /tmp/nvim.appimage
    echo "  - install neovim under ~/bin/nvim"
    (
        cd ~/bin
        rm -rf .nvim
        /tmp/nvim.appimage --appimage-extract
        mv squashfs-root .nvim
        ln -sf ~/bin/.nvim/usr/bin/nvim ~/bin/nvim
    ) &> /dev/null
    echo "  - Need to manually install python-neovim / python3-neovim (pip|distrib..)"
}

function install_vim ()
{
    echo "- Install vim/neovim"
    rm -rf ~/.vim ~/.config/nvim
    cp -r vim ~/.vim
    ln -sf ~/.vim/vimrc ~/.vimrc
    ln -sf ~/.vim ~/.config/nvim
    echo "  - vim exec :PlugInstall"
}

function install_tmux ()
{
    echo "- Install tmux"
    rm -rf ~/.tmux
    cp -r tmux ~/.tmux
    ln -sf ~/.tmux/tmux.conf ~/.tmux.conf
    ln -sf ~/.tmux/tm.completion.source ~/.bash/completions/tm.completion.source
    ln -sf ~/.tmux/tm ~/bin/tm

    version=$(tmux -V | grep -Po '(\d|\.)+' 2> /dev/null)
    if [[ $version > 2.8 ]]; then
        python ~/.tmux/tmux-migrate-options.py ~/.tmux/tmux.conf > ~/.tmux/tmux.conf.NEW
        mv ~/.tmux/tmux.conf.NEW ~/.tmux/tmux.conf
    fi
}

function install_git ()
{
    echo "- Install git"
    git_username=$(git config --get user.name 2> /dev/null)
    git_mail=$(git config --get user.email 2> /dev/null)
    rm -rf ~/.git
    cp -r git ~/.git
    ln -sf ~/.git/gitconfig ~/.gitconfig
    [[ -z $git_username ]] && read -p 'git username : ' git_username
    [[ -z $git_mail ]] && read -p 'git mail : ' git_mail
    [[ -n $git_username ]] && sed -i "s/USERNAME/$git_username/g" ~/.git/gitconfig
    [[ -n $git_mail ]] && sed -i "s/MAIL/$git_mail/g" ~/.git/gitconfig
}

function install_terminal ()
{
    echo "- Install fonts"
    font_dir="$HOME/.fonts"
    rm -rf $font_dir
    cp -rp terminal/fonts $font_dir
    if [[ -f $(which fc-cache 2>/dev/null) ]]; then
        echo "  - Resetting font cache..."
        fc-cache -f $font_dir
    fi

    echo "- Install icons"
    icons_dir="$HOME/.icons"
    rm -rf $icons_dir
    cp -rp terminal/icons $icons_dir

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

function install_config () {
    echo '- Install .config'
    for cfg in $(ls config); do
        [[ -f config/$cfg ]] && cp -f config/$cfg $HOME/.config/
        [[ -d config/$cfg ]] && rm -rf $HOME/.config/$cfg && cp -rf config/$cfg $HOME/.config/
    done
}

function print_help ()
{
    echo "
    $0 [--update|--term|--vim|--neovim|--config]

    # Require:
     - bash: python-yaml, python-json, jq
     - terminal: gnome-terminal, rxvt-unicode, termite
     - i3: i3-wm i3lock xautolock dunst i3blocks rofi sysstat acpi
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
            --update) update_repo ;;
            --vim)    install_vim ;;
            --neovim) install_neovim ;;
            --term)   install_bash;
                      install_zsh;
                      install_tmux;
                      install_git;
                      install_terminal ;;
            --config) install_config;;
            --help)   print_help ;;
            * ) [[ $arg =~ \-+.* ]] && print_help "$arg unknown"
        esac
    done

    echo "Install dotfiles done !"
}

main "$@"
