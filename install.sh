#!/bin/bash

set -x

SCRIPT=$(readlink -f $0)
SCRIPTPATH=$(dirname $SCRIPT)
cd $SCRIPTPATH

mkdir -p ~/.config
mkdir -p ~/.local/bin

if [[ $(id -u) -eq 0 && $(echo $PATH | grep -c "$HOME/.local/bin") -eq 0 ]]; then
    INSTALL_ROOT_BIN=1
fi

function install_neovim {
    release=$1
    echo "- Update neovim from $release"
    wget https://github.com/neovim/neovim/releases/download/$release/nvim.appimage -O /tmp/nvim.appimage 2>/dev/null || \
        cp nvim/nvim.appimage /tmp
    chmod +x /tmp/nvim.appimage
    echo "  - install neovim under ~/.local/bin/nvim"
    (
        cd ~/.local/bin
        rm -rf .nvim
        /tmp/nvim.appimage --appimage-extract
        mv squashfs-root .nvim
        ln -s ~/.local/bin/.nvim/usr/bin/nvim ~/.local/bin/nvim
        ln -s ~/.local/bin/.nvim/usr/bin/nvim ~/.local/bin/vim
        ln -sf ~/.local/bin/.nvim/usr/bin/nvim /usr/local/bin/vim
        ln -sf ~/.local/bin/.nvim/usr/bin/nvim /usr/local/bin/vi
        [[ $INSTALL_ROOT_BIN -eq 1 ]] && ln -sf ~/.local/bin/.nvim/usr/bin/nvim /usr/local/bin/vim && \
                                         ln -sf /usr/local/bin/vim /usr/local/bin/vi
    ) &> /dev/null

    if which apt-get 2>&1 > /dev/null ; then
        if ! env | grep -q SSH_TTY; then
            # - Install ripgrep: https://github.com/BurntSushi/ripgrep/releases/latest
            version=$(
                basename $(curl -si https://github.com/BurntSushi/ripgrep/releases/latest | grep ^location | awk '{print $2}' ) | sed 's/[^a-zA-Z0-9\.]//g')
            wget "https://github.com/BurntSushi/ripgrep/releases/download/$version/ripgrep_${version}_amd64.deb" -O /tmp/ripgrep.deb
            dpkg -x /tmp/ripgrep.deb /tmp/deb

            # - Install fd: https://github.com/sharkdp/fd/releases/latest
            version=$(basename $(curl -si https://github.com/sharkdp/fd/releases/latest | grep ^location | awk '{print $2}' ) | sed 's/[^a-zA-Z0-9\.]//g')
            wget "https://github.com/sharkdp/fd/releases/download/${version}/fd_${version:1}_amd64.deb" -O /tmp/fd.deb
            dpkg -x /tmp/fd.deb /tmp/deb

            # save binary
            cp /tmp/deb/usr/bin/* $SCRIPTPATH/bin && rm -rf /tmp/deb
            chmod +x $SCRIPTPATH/bin/*
        fi
    fi
}

function install_vim_requirements {
    echo "- Install vim requirements"

    if [[ ! -e ~/.local/bin/nvim ]]; then
        install_neovim 'stable'
    fi

    pip_freeze=$(python3 -m pip freeze)
    if [[ $? -ne 0 ]]; then
        if which pacman 2>&1 > /dev/null ; then
            sudo pacman -S --noconfirm python-pip
        elif which apt-get 2>&1 > /dev/null ; then
            sudo apt-get install -y python3-pip
        fi
    fi

    pip_require=(jedi==0.17.2 pynvim==0.4.2 yamllint==1.25.0)
    pip_installed=$(echo "$pip_freeze" | grep -P "(^$(echo ${pip_require[@]} | sed -e 's/ /|^/g'))" | wc -l)

    if [[ ${#pip_require[@]} -ne $pip_installed ]]; then
        python3 -m pip install --user --upgrade --use-feature=2020-resolver \
            pip setuptools \
            ${pip_require[@]}
    fi

    rm -rf ~/.ctags.d && ln -sf $SCRIPTPATH/ctags/ctags.d ~/.ctags.d

    # install local bin
    for bin in $(ls bin); do
        # check ldd
        if [[ $(ldd bin/$bin | grep -c 'not found') -eq 0 ]]; then
            bin_name=$(echo $bin | cut -d. -f1)
            ln -sf $SCRIPTPATH/bin/$bin ~/.local/bin/$bin_name
            [[ $INSTALL_ROOT_BIN -eq 1 ]] && ln -sf $SCRIPTPATH/bin/$bin /usr/local/bin/$bin_name
        fi
    done
}

function install_vim_config {
    echo "- Install vim/neovim"

    ln -sf $SCRIPTPATH/vim/vimrc ~/.vimrc
    rm -rf ~/.config/nvim && ln -sf $SCRIPTPATH/vim ~/.config/nvim
    # vim8 compat
    rm -rf ~/.vim  && ln -sf $SCRIPTPATH/vim ~/.vim

    $HOME/.local/bin/nvim --headless +PlugUpgrade +PlugInstall +PlugUpdate +qall 2> /dev/null
}

function install_shell {
    echo "- Install bash/zsh"
    ln -sf $SCRIPTPATH/shell ~/.shell

    # bash
    ln -sf $SCRIPTPATH/shell/bashrc ~/.bashrc
    ln -sf $SCRIPTPATH/shell/dir_colors ~/.dir_colors
    ln -sf $SCRIPTPATH/shell/agignore ~/.agignore
    echo "source ~/.bashrc" > ~/.bash_profile
    mkdir -p ~/.bash_custom

    # zsh
    _antigen_update
    ln -sf $SCRIPTPATH/shell/zshrc ~/.zshrc
}

function _antigen_update {
    #http://antigen.sharats.me/
    echo '- Get last antigen from git.io/antigen'
    curl -sL git.io/antigen > zsh/antigen.zsh
    # cleanup old antigen install
    rm -rf $HOME/.antigen
}

function install_tmux {
    echo "- Install tmux"
    [[ ! -L ~/.tmux ]] && rm -rf ~/.tmux
    ln -sf $SCRIPTPATH/tmux/tm ~/.local/bin/tm
    rm -f ~/.tmux && ln -sf $SCRIPTPATH/tmux ~/.tmux

    version=$(tmux -V | grep -Po '(\d|\.)+' 2> /dev/null)
    if [[ $version > 2.8 ]]; then
        rm ~/.tmux.conf
        python tmux/tmux-migrate-options.py tmux/tmux.conf > ~/.tmux.conf
    else
        ln -sf $SCRIPTPATH/tmux/tmux.conf ~/.tmux.conf
    fi
}

function install_git {
    echo "- Install git"
    git_username=$(git config --get user.name 2> /dev/null)
    git_mail=$(git config --get user.email 2> /dev/null)
    rm -rf ~/.git && cp -r git ~/.git
    ln -sf ~/.git/gitconfig ~/.gitconfig
    ln -sf ~/.git/gitignore ~/.gitignore
    [[ -z $git_username ]] && read -p 'git username : ' git_username
    [[ -z $git_mail ]] && read -p 'git mail : ' git_mail
    [[ -n $git_username ]] && sed -i "s/USERNAME/$git_username/g" ~/.git/gitconfig
    [[ -n $git_mail ]] && sed -i "s/MAIL/$git_mail/g" ~/.git/gitconfig
}

function install_terminal {
    echo "- Install fonts"
    font_dir="$HOME/.fonts"
    rm -rf $font_dir && ln -sf $SCRIPTPATH/terminal/fonts $font_dir
    if [[ -f $(which fc-cache 2>/dev/null) ]]; then
        echo "  - Resetting font cache..."
        fc-cache -f $font_dir
    fi

    echo "- Install icons"
    icons_dir="$HOME/.icons"
    rm -rf $icons_dir && ln -sf $SCRIPTPATH/terminal/icons $icons_dir

    if which gnome-terminal 2>&1 > /dev/null; then
        echo "- Install gnome-terminal color scheme"
        for theme in $( ls terminal/gnome-terminal ); do
            echo "  - $theme"
            bash terminal/gnome-terminal/$theme
        done
    fi

    if which termite 2>&1 > /dev/null; then
        echo "- Configure termite"
        rm -rf $HOME/.config/termite
        ln -s $SCRIPTPATH/terminal/termite $HOME/.config/termite
    fi
}

function install_config {
    echo '- Install .config'
    mkdir ~/.config.backup

    for cfg in $(ls config); do
        if [[ ! -L $HOME/.config/$cfg ]]; then
            mv $HOME/.config/$cfg $HOME/.config.backup/$cfg.$(date '+%s')
        fi
        rm $HOME/.config/$cfg && ln -sf $SCRIPTPATH/config/$cfg $HOME/.config/$cfg
    done
}

function print_help {
    echo "
    $0 [--vim|--conf|--ui|--help]

    # Require:
        - bash: python-yaml, python-json, jq
        - terminal: gnome-terminal, rxvt-unicode, termite
        - i3: i3-wm i3lock xautolock dunst i3blocks rofi sysstat acpi
        - vim: silversearcher-ag / fd (https://github.com/sharkdp/fd)
    "

    exit
}

function main {
    echo "Install dotfiles for user $USER"

    [[ $# -eq 0 ]] && print_help

    while [[ $# -ne 0 ]]; do
        arg="$1"; shift
        case "$arg" in
            --vim)  [[ $1 =~ ^(stable|nightly)$ ]] && \
                        release=$1 && shift && \
                        install_neovim $release;
                    install_vim_requirements;
                    install_vim_config;;
            --conf) install_shell;
                    install_tmux;
                    install_git;;
            --ui)   install_config;
                    install_terminal ;;
            --help) print_help ;;
            * ) [[ $arg =~ \-+.* ]] && print_help "$arg unknown"
        esac
    done

    echo "Install dotfiles done !"
}

main "$@"
