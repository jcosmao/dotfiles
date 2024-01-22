#!/bin/bash

SCRIPT=$(readlink -f $0)
SCRIPTPATH=$(dirname $SCRIPT)
IS_SSH=$(env | grep -c SSH_TTY)
cd $SCRIPTPATH
TMPDIR=$SCRIPTPATH/tmp

if [[ $SCRIPTPATH != $HOME/.dotfiles ]]; then
    echo mv $SCRIPTPATH to $HOME/.dotfiles
    exit 1
fi

mkdir -p $TMPDIR
mkdir -p ~/.config
mkdir -p ~/.local/bin

ln -sf $SCRIPT ~/.local/bin/dotfiles

function install_neovim {
    release=$1
    echo "- Update neovim from $release"
    wget https://github.com/neovim/neovim/releases/download/$release/nvim.appimage -O $TMPDIR/nvim.appimage 2>/dev/null || \
        cp nvim/nvim.appimage $TMPDIR
    chmod +x $TMPDIR/nvim.appimage
    echo "  - install neovim under ~/.local/bin/nvim"
    (
        cd ~/.local/bin
        rm -f nvim vim
        rm -rf .nvim
        $TMPDIR/nvim.appimage --appimage-extract
        mv squashfs-root .nvim

        ln -sf .nvim/usr/bin/nvim .
        ln -sf nvim vim
    ) &> /dev/null
}

function install_vim_requirements {
    echo "- Install vim requirements"

    if [[ ! -e ~/.local/bin/nvim ]]; then
        install_neovim 'stable'
    fi

    install_local_bin

    rm -rf ~/.ctags.d && ln -sf $SCRIPTPATH/ctags/ctags.d ~/.ctags.d

    source ~/.pyenv/versions/nvim/bin/activate
    [[ $? -ne 0 ]] && echo "Unable to load 'nvim' pyenv virtualenv. run pyenv.install; pyenv virtualenv nvim" && exit 1

    pip_require=(pynvim yamllint pyproject-flake8 black)
    pip_installed=$(echo "$pip_freeze" | grep -P "(^$(echo ${pip_require[@]} | sed -e 's/ /|^/g'))" | wc -l)

    if [[ ${#pip_require[@]} -ne $pip_installed ]]; then
        pip install --upgrade pip setuptools
        pip install --upgrade ${pip_require[@]}
    fi

    source $SCRIPTPATH/shell/source/nvm.sh
    nodejs.load
    which npm 2> /dev/null
    [[ $? -ne 0 ]] && echo "Node JS not available; run nodejs.install" && exit 1

    if [[ $(lsb_release -rs) == "18.04" ]]; then
        # npm tree-sitter deps (>0.19 require glibc > ubuntu18)
        nvm install 16.17.0
        nvm use 16.17.0
        nvm alias default v16.17.0
        npm install --location=global tree-sitter@0.19 tree-sitter-cli@0.19.0
    else
        npm install --global tree-sitter tree-sitter-cli
    fi

    # Path used in vim config
    ln -sf $(which npm) $HOME/.local/bin/npm
    ln -sf $(which node) $HOME/.local/bin/node
}

function install_vim_config {
    echo "- Install neovim"

    rm -rf ~/.config/nvim && ln -sf $SCRIPTPATH/neovim ~/.config/nvim
    $HOME/.local/bin/.nvim/usr/bin/nvim --headless +PlugUpgrade +PlugClean! +PlugInstall +PlugUpdate! +qall 2> /dev/null
}

function install_vim_light {
    rm -rf ~/.vim && ln -sf $SCRIPTPATH/vim ~/.vim
    ln -sf ~/.vim/vimrc_lite.vim ~/.vimrc
}

function install_shell {
    echo "- Install bash/zsh"

    rm -f ~/.shell
    ln -sf $SCRIPTPATH/shell ~/.shell

    # global
    ln -sf $SCRIPTPATH/shell/dir_colors ~/.dir_colors
    mkdir -p ~/.bash_custom

    # zsh
    ln -sf $SCRIPTPATH/shell/zshrc ~/.zshrc

    [[ -n $LC_BASTION ]] && bashrc_path=$HOME/.bashrc-$LC_BASTION || bashrc_path=$HOME/.bashrc
    ln -sf $SCRIPTPATH/shell/bashrc $bashrc_path

    # fzf pass
    mkdir -p ~/.password-store/.extensions/
    ln -sf ~/.shell/fzf/fzf.bash.password-store ~/.password-store/.extensions/fzf.bash
}

function update_bin_from_deb {
    echo "- Update bin from deb pkg"

    # fzf: deb from debian 11
    # rofi: ubuntu 22.04
    # ctags: compiled from https://github.com/universal-ctags/ctags.git

    # - Install ripgrep: https://github.com/BurntSushi/ripgrep/releases/latest
    version=$(basename $(curl -si https://github.com/BurntSushi/ripgrep/releases/latest | grep ^location | awk '{print $2}' ) | sed 's/[^a-zA-Z0-9\.]//g')
    wget "https://github.com/BurntSushi/ripgrep/releases/download/$version/ripgrep_${version}_amd64.deb" -O $TMPDIR/ripgrep.deb
    (cd $TMPDIR; ar x $TMPDIR/ripgrep.deb && tar xf data.tar.xz)

    # - Install fd: https://github.com/sharkdp/fd/releases/latest
    version=$(basename $(curl -si https://github.com/sharkdp/fd/releases/latest | grep ^location | awk '{print $2}' ) | sed 's/[^a-zA-Z0-9\.]//g')
    wget "https://github.com/sharkdp/fd/releases/download/${version}/fd_${version:1}_amd64.deb" -O $TMPDIR/fd.deb
    (cd $TMPDIR; ar x $TMPDIR/fd.deb && tar xf data.tar.xz)

    # save binary
    cp $TMPDIR/usr/bin/* $SCRIPTPATH/bin && rm -rf $TMPDIR/deb
    chmod +x $SCRIPTPATH/bin/*
}

function install_local_bin {
    echo "- Install ~/.local/bin"

    # install local bin
    for bin in $(ls bin | grep -v README.md); do
        # check ldd
        echo "    > $bin"
        if [[ $(ldd bin/$bin 2>&1 |grep -c 'not found') -eq 0 ]]; then
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
        python3 tmux/tmux-migrate-options.py tmux/tmux.conf > ~/.tmux.conf
    else
        ln -sf $SCRIPTPATH/tmux/tmux.conf ~/.tmux.conf
    fi
}

function install_git {
    echo "- Install git"
    git_username=$(git config --get user.name 2> /dev/null || echo $GIT_USER)
    git_mail=$(git config --get user.email 2> /dev/null || echo $GIT_MAIL)
    [[ ! -L ~/.git ]] && rm -rf ~/.git.backup && mv ~/.git ~/.git.backup
    [[ ! -L ~/.git ]] && ln -sf $SCRIPTPATH/git ~/.git
    cp ~/.git/gitconfig.template ~/.git/gitconfig
    ln -sf ~/.git/gitignore ~/.gitignore
    ln -sf ~/.git/gitconfig ~/.gitconfig
    [[ -z $git_username ]] && read -p 'git username : ' git_username
    [[ -z $git_mail ]] && read -p 'git mail : ' git_mail
    [[ -n $git_username ]] && sed -i "s/USERNAME/$git_username/g" ~/.git/gitconfig
    [[ -n $git_mail ]] && sed -i "s/MAIL/$git_mail/g" ~/.git/gitconfig
}

function install_fonts {
    [[ $IS_SSH -eq 1 ]] && return
    echo "- Install fonts"
    font_dir="$HOME/.fonts"
    rm -rf $font_dir && ln -sf $SCRIPTPATH/fonts $font_dir
    if [[ -f $(which fc-cache 2>/dev/null) ]]; then
        echo "    > Resetting font cache..."
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
    mkdir -p ~/.config.backup

    for cfg in $(ls config); do
        if [[ ! -L $HOME/.config/$cfg ]]; then
            mv $HOME/.config/$cfg $HOME/.config.backup/$cfg.$(date '+%s')
        fi
        rm -f $HOME/.config/$cfg && ln -sf $SCRIPTPATH/config/$cfg $HOME/.config/$cfg
    done

    [[ $IS_SSH -eq 1 ]] && return

    # build i3 config
    if which i3 2>&1 > /dev/null ; then
        echo "    > build i3 conf"
        $HOME/.config/i3/i3_build_conf.sh > /dev/null
    fi
}

function uninstall {
    echo "- Uninstall"; set -x
    rm -rf $HOME/.local/bin/.nvim
    rm -rf $HOME/.zsh
    for dir in $HOME $HOME/.config $HOME/.local/bin; do
        find $dir -maxdepth 1 -lname '*dotfiles*' -delete
        find $dir -maxdepth 1 -xtype l -delete
    done
    set +x
}

function print_help {

    [[ $# -ne 0 ]] && echo "$(tput setaf 1)[ERROR] $*"

    echo "
    Options:

$(declare -f main | \
    grep -P '(help=|--|-[a-z]\))' | \
    xargs | \
    sed -e 's/; /\n/g' -e 's/help=/#/g' | \
    column -t -s '#')"

    exit
}

function main {
    [[ $# -eq 0 ]] && print_help

    echo "Install dotfiles for user $USER"

    while [[ $# -ne 0 ]]; do
        arg="$1"; shift
        case "$arg" in
            --minimal|-m)
                help="Vim 8 config without plugin, shell (bash+zsh), bin, tmux"
                install_vim_light;
                install_shell;
                install_tmux;
                install_local_bin ;;

            --nvim|--neovim|-v)
                help="Neovim (optional: stable|nightly|v[0-9])"
                [[ $1 =~ ^(stable|nightly|v[0-9]) ]] && \
                    release=$1 && shift && \
                    install_neovim $release;
                install_vim_requirements;
                install_vim_config;;

            --conf|-c)
                help="shell (bash+zsh), tmux, git, i3 cfg, bin, icons, fonts"
                install_shell;
                install_tmux;
                install_git;
                install_config;
                install_local_bin;
                install_icons ;
                install_fonts ;;

            --updatebin|-u)
                help="update bin (pull from github)"
                update_bin_from_deb;;

            --uninstall|-d)
                help="uninstall dotfiles"
                uninstall;;

            --help|-h)
                help="this"
                print_help ;;

            *)
                [[ $arg =~ \-+.* ]] && print_help "$arg unknown"
        esac
    done

    [[ -d $TMPDIR ]] && rm -rf $TMPDIR

    echo "Install dotfiles done !"
}

main "$@"
