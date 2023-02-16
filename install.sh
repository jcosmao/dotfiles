#!/bin/bash
set -x

SCRIPT=$(readlink -f $0)
SCRIPTPATH=$(dirname $SCRIPT)
IS_SSH=$(env | grep -c SSH_TTY)
cd $SCRIPTPATH
TMPDIR=$SCRIPTPATH/tmp

mkdir $TMPDIR
mkdir -p ~/.config
mkdir -p ~/.local/bin

if [[ $(id -u) -eq 0 && $(echo $PATH | grep -c "$HOME/.local/bin") -eq 0 ]]; then
    INSTALL_ROOT_BIN=1
fi

if [[ $(hostname -s) =~ ^admin ]]; then
    INSTALL_ROOT_BIN=0
    INSTALL_PIP=0
fi

function install_vim_lite {
    rm -rf ~/.vim && ln -sf $SCRIPTPATH/vim ~/.vim
    ln -sf ~/.vim/vimrc_lite.vim ~/.vimrc
}

function install_neovim {
    release=$1
    echo "- Update neovim from $release"
    wget https://github.com/neovim/neovim/releases/download/$release/nvim.appimage -O $TMPDIR/nvim.appimage 2>/dev/null || \
        cp nvim/nvim.appimage $TMPDIR
    chmod +x $TMPDIR/nvim.appimage
    echo "  - install neovim under ~/.local/bin/nvim"
    (
        cd ~/.local/bin
        rm -rf .nvim
        $TMPDIR/nvim.appimage --appimage-extract
        mv squashfs-root .nvim
        ln -s ~/.local/bin/.nvim/usr/bin/nvim ~/.local/bin/nvim
        ln -s ~/.local/bin/.nvim/usr/bin/nvim ~/.local/bin/vim
        [[ $INSTALL_ROOT_BIN -eq 1 ]] && ln -sf ~/.local/bin/.nvim/usr/bin/nvim /usr/local/bin/vim && \
                                         ln -sf /usr/local/bin/vim /usr/local/bin/vi
    ) &> /dev/null

    if which apt-get 2>&1 > /dev/null ; then
        if [[ $IS_SSH -eq 0 ]]; then
            # - Install ripgrep: https://github.com/BurntSushi/ripgrep/releases/latest
            version=$(basename $(curl -si https://github.com/BurntSushi/ripgrep/releases/latest | grep ^location | awk '{print $2}' ) | sed 's/[^a-zA-Z0-9\.]//g')
            wget "https://github.com/BurntSushi/ripgrep/releases/download/$version/ripgrep_${version}_amd64.deb" -O $TMPDIR/ripgrep.deb
            dpkg -x $TMPDIR/ripgrep.deb $TMPDIR/deb

            # - Install fd: https://github.com/sharkdp/fd/releases/latest
            version=$(basename $(curl -si https://github.com/sharkdp/fd/releases/latest | grep ^location | awk '{print $2}' ) | sed 's/[^a-zA-Z0-9\.]//g')
            wget "https://github.com/sharkdp/fd/releases/download/${version}/fd_${version:1}_amd64.deb" -O $TMPDIR/fd.deb
            dpkg -x $TMPDIR/fd.deb $TMPDIR/deb

            # save binary
            cp $TMPDIR/deb/usr/bin/* $SCRIPTPATH/bin && rm -rf $TMPDIR/deb
            chmod +x $SCRIPTPATH/bin/*
        fi
    fi
}

function install_vim_requirements {
    echo "- Install vim requirements"

    if [[ ! -e ~/.local/bin/nvim ]]; then
        install_neovim 'stable'
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

    source ~/.pyenv/versions/nvim/bin/activate || return
    which npm 2> /dev/null || return

    pip_require=(pynvim yamllint pyproject-flake8 black)
    pip_installed=$(echo "$pip_freeze" | grep -P "(^$(echo ${pip_require[@]} | sed -e 's/ /|^/g'))" | wc -l)

    if [[ ${#pip_require[@]} -ne $pip_installed ]]; then
        pip install --upgrade pip setuptools
        pip install --upgrade ${pip_require[@]}
    fi

    # npm tree-sitter deps (>0.19 require glibc > ubuntu18)
    # npm install --location=global tree-sitter@0.19 tree-sitter-cli@0.19.0
    npm install --location=global tree-sitter tree-sitter-cli
}

function install_vim_config {
    echo "- Install neovim"

    rm -rf ~/.config/nvim && ln -sf $SCRIPTPATH/neovim ~/.config/nvim
    [[ $RESET -eq 1 ]] && rm -rf ~/.config/nvim/plug
    $HOME/.local/bin/nvim --headless +PlugUpgrade +PlugClean! +PlugInstall +PlugUpdate! +qall 2> /dev/null
}

function install_shell {
    version=${1:-full}

    echo "- Install bash/zsh"
    rm -f ~/.shell
    ln -sf $SCRIPTPATH/shell ~/.shell

    # global
    ln -sf $SCRIPTPATH/shell/dir_colors ~/.dir_colors
    mkdir -p ~/.bash_custom

    # zsh
    if [[ $version == 'light' ]]; then
        ln -sf $SCRIPTPATH/shell/zshrc.lite ~/.zshrc
    else
        ln -sf $SCRIPTPATH/shell/zshrc ~/.zshrc
    fi
}

function install_local_bin {
    # install local bin
    for bin in $(ls bin); do
        # check ldd
        if [[ $(ldd bin/$bin | grep -c 'not found') -eq 0 ]]; then
            bin_name=$(echo $bin | cut -d. -f1)
            ln -sf $SCRIPTPATH/bin/$bin ~/.local/bin/$bin_name
        fi
    done
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
    git_username=$(git config --get user.name 2> /dev/null || echo $GIT_USER)
    git_mail=$(git config --get user.email 2> /dev/null || echo $GIT_MAIL)
    rm -rf ~/.git && cp -r git ~/.git
    ln -sf ~/.git/gitconfig ~/.gitconfig
    ln -sf ~/.git/gitignore ~/.gitignore
    [[ -z $git_username ]] && read -p 'git username : ' git_username
    [[ -z $git_mail ]] && read -p 'git mail : ' git_mail
    [[ -n $git_username ]] && sed -i "s/USERNAME/$git_username/g" ~/.git/gitconfig
    [[ -n $git_mail ]] && sed -i "s/MAIL/$git_mail/g" ~/.git/gitconfig
    # Do not duplicate --signoff - config file ?
    git config --global trailer.sign.ifexists replace
}

function install_fonts {
    echo "- Install fonts"
    font_dir="$HOME/.fonts"
    rm -rf $font_dir && ln -sf $SCRIPTPATH/fonts $font_dir
    if [[ -f $(which fc-cache 2>/dev/null) ]]; then
        echo "  - Resetting font cache..."
        fc-cache -f $font_dir
    fi
}

function install_icons {
    [[ $IS_SSH -eq 1 ]] && return
    echo "- Install icons"
    icons_dir="$HOME/.icons"
    rm -rf $icons_dir && ln -sf $SCRIPTPATH/icons $icons_dir
}

function install_config {
    echo '- Install .config'
    mkdir ~/.config.backup

    for cfg in $(ls config); do
        if [[ ! -L $HOME/.config/$cfg ]]; then
            mv $HOME/.config/$cfg $HOME/.config.backup/$cfg.$(date '+%s')
        fi
        rm -f $HOME/.config/$cfg && ln -sf $SCRIPTPATH/config/$cfg $HOME/.config/$cfg
    done

    [[ $IS_SSH -eq 1 ]] && return

    cp $HOME/.config/termite/config.base $HOME/.config/termite/config
    cp $HOME/.config/alacritty/alacritty.base.yml $HOME/.config/alacritty/alacritty.yml

    # build i3 config
    if which i3 2>&1 > /dev/null ; then
        $HOME/.config/i3/i3_build_conf.sh
    fi
}

function print_help {
    echo "
    $0 [--minimal|--nvim|--conf|--help]
    "

    exit
}

function main {
    echo "Install dotfiles for user $USER"

    [[ $# -eq 0 ]] && print_help

    while [[ $# -ne 0 ]]; do
        arg="$1"; shift
        case "$arg" in
            --reset) export RESET=1;;
            --minimal) install_vim_light;
                       install_shell light;
                       install_tmux;
                       install_local_bin ;;
            --nvim)  [[ $1 =~ ^(stable|nightly|v) ]] && \
                        release=$1 && shift && \
                        install_neovim $release;
                    install_vim_requirements;
                    install_vim_config;;
            --conf) install_shell;
                    install_tmux;
                    install_git;
                    install_config;
                    install_icons ;
                    install_fonts ;;
            --help) print_help ;;
            * ) [[ $arg =~ \-+.* ]] && print_help "$arg unknown"
        esac
    done

    [[ -d $TMPDIR ]] && rm -rf $TMPDIR

    echo "Install dotfiles done !"
}

main "$@"
