#!/bin/bash

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
IS_SSH=$(env | grep -c SSH_TTY)
cd "$SCRIPTPATH" || exit
TMPDIR=$SCRIPTPATH/tmp

if [[ $SCRIPTPATH != $HOME/.dotfiles ]]; then
    echo mv "$SCRIPTPATH" to "$HOME/.dotfiles"
    exit 1
fi

mkdir -p "$TMPDIR"
mkdir -p ~/.config
mkdir -p ~/.local/bin

ln -sf "$SCRIPT" ~/.local/bin/dotfiles

function install_neovim
{
    release=$1
    echo "- Update neovim from $release"
    wget "https://github.com/neovim/neovim/releases/download/$release/nvim-linux-x86_64.appimage" -O "$TMPDIR/nvim.appimage" 2> /dev/null ||
        cp nvim/nvim.appimage "$TMPDIR"
    chmod +x "$TMPDIR/nvim.appimage"
    echo "  - install neovim under ~/.local/bin/nvim"
    (
        cd ~/.local/bin
        rm -f nvim vim
        rm -rf .nvim
        "$TMPDIR/nvim.appimage" --appimage-extract
        mv squashfs-root .nvim

        ln -sf .nvim/usr/bin/nvim .
        ln -sf nvim vim
    ) &> /dev/null
}

function install_vim_requirements
{
    echo "- Install vim requirements"

    if [[ ! -e ~/.local/bin/nvim ]]; then
        install_neovim 'stable'
    fi

    install_local_bin

    rm -rf ~/.ctags.d && ln -sf "$SCRIPTPATH/ctags/ctags.d" ~/.ctags.d

    if ! source ~/.pyenv/versions/nvim/bin/activate; then
        echo "Unable to load 'nvim' pyenv virtualenv. run pyenv.install; pyenv virtualenv nvim"
        exit 1
    fi

    pip_require=(pynvim yamllint pyproject-flake8 black)
    pip_installed=$(echo "$pip_freeze" | grep -P "(^$(echo ${pip_require[@]} | sed -e 's/ /|^/g'))" | wc -l)

    if [[ ${#pip_require[@]} -ne $pip_installed ]]; then
        pip install --upgrade pip setuptools
        pip install --upgrade "${pip_require[@]}"
    fi

    source "$SCRIPTPATH/shell/source/nvm.sh"
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
    ln -sf "$(which npm)" "$HOME/.local/bin/npm"
    ln -sf "$(which node)" "$HOME/.local/bin/node"
}

function install_vim_config
{
    echo "- Install neovim"

    rm -rf ~/.config/nvim && ln -sf "$SCRIPTPATH/neovim" ~/.config/nvim
    "$HOME/.local/bin/.nvim/usr/bin/nvim" --headless +PlugClean! +PlugInstall +PlugUpdate! +qall 2> /dev/null
}

function install_vim_light
{
    rm -rf ~/.vim && ln -sf "$SCRIPTPATH/vim" ~/.vim
    ln -sf ~/.vim/vimrc_lite.vim ~/.vimrc
}

function install_shell
{
    echo "- Install bash/zsh"

    rm -f ~/.shell
    ln -sf "$SCRIPTPATH/shell" ~/.shell

    # global
    ln -sf "$SCRIPTPATH/shell/dir_colors" ~/.dir_colors
    mkdir -p ~/.bash_custom

    # zsh
    ln -sf "$SCRIPTPATH/shell/zshrc" ~/.zshrc

    ln -sf "$SCRIPTPATH/bin/fzf" ~/.local/bin/fzf

    [[ -n $LC_BASTION ]] && bashrc_path=$HOME/.bashrc-$LC_BASTION || bashrc_path=$HOME/.bashrc
    ln -sf "$SCRIPTPATH/shell/bashrc" "$bashrc_path"

    # fzf pass
    mkdir -p ~/.password-store/.extensions/
    ln -sf ~/.shell/fzf/fzf.bash.password-store ~/.password-store/.extensions/fzf.bash
}

function update_bin_from_deb
{
    echo "- Update bin from deb pkg"

    # ctags: compiled from https://github.com/universal-ctags/ctags.git

    # - Install ripgrep: https://github.com/BurntSushi/ripgrep/releases/latest
    version=$(basename $(curl -si https://github.com/BurntSushi/ripgrep/releases/latest | grep ^location | awk '{print $2}') | sed 's/[^a-zA-Z0-9\.]//g')
    wget "https://github.com/BurntSushi/ripgrep/releases/download/$version/ripgrep_${version}-1_amd64.deb" -O "$TMPDIR/ripgrep.deb"
    (
        cd "$TMPDIR"
        ar x "$TMPDIR/ripgrep.deb" && tar xf data.tar.xz
    )

    # - Install fd: https://github.com/sharkdp/fd/releases/latest
    version=$(basename $(curl -si https://github.com/sharkdp/fd/releases/latest | grep ^location | awk '{print $2}') | sed 's/[^a-zA-Z0-9\.]//g')
    wget "https://github.com/sharkdp/fd/releases/download/${version}/fd_${version:1}_amd64.deb" -O $TMPDIR/fd.deb
    (
        cd "$TMPDIR"
        ar x "$TMPDIR/fd.deb" && tar xf data.tar.xz
    )

    # save binary
    cp "$TMPDIR/usr/bin/*" "$SCRIPTPATH/bin" && rm -rf "$TMPDIR/deb"
    chmod +x "$SCRIPTPATH/bin/*"
}

function install_local_bin
{
    echo "- Install ~/.local/bin"

    # install local bin
    for f in bin/*; do
        bin=$(basename "$f")
        [[ $bin = "README.md" ]] && continue
        # check ldd
        echo "  ❭ $bin"
        if [[ $(ldd "bin/$bin" 2>&1 | grep -c 'not found') -eq 0 ]]; then
            bin_name=$(echo "$bin" | cut -d. -f1)
            ln -sf "$SCRIPTPATH/bin/$bin" "$HOME/.local/bin/$bin_name"

            [[ $bin == "bat" ]] && bat cache --build 2>&1 > /dev/null
        fi
    done
}

function install_tmux
{
    echo "- Install tmux"
    [[ ! -L ~/.tmux ]] && rm -rf ~/.tmux
    ln -sf "$SCRIPTPATH/tmux/tm" ~/.local/bin/tm
    rm -f ~/.tmux && ln -sf "$SCRIPTPATH/tmux" ~/.tmux

    version=$(tmux -V | grep -Po '(\d|\.)+' 2> /dev/null)
    if [[ $(echo "$version > 2.8" | bc -l) -eq 1 ]]; then
        rm ~/.tmux.conf
        python3 tmux/tmux-migrate-options.py tmux/tmux.conf > ~/.tmux.conf
    else
        ln -sf "$SCRIPTPATH/tmux/tmux.conf" ~/.tmux.conf
    fi
}

function install_git
{
    echo "- Install git"
    git_username=$(git config --get user.name 2> /dev/null || echo "$GIT_USER")
    git_mail=$(git config --get user.email 2> /dev/null || echo "$GIT_MAIL")
    [[ ! -L ~/.git ]] && rm -rf ~/.git.backup && mv ~/.git ~/.git.backup
    [[ ! -L ~/.git ]] && ln -sf "$SCRIPTPATH/git" ~/.git
    cp ~/.git/gitconfig.template ~/.git/gitconfig
    ln -sf ~/.git/gitignore ~/.gitignore
    ln -sf ~/.git/gitconfig ~/.gitconfig

    if [[ -z $git_username || -z $git_mail ]]; then
        gpg=()
        IFS=$'\n'
        for line in $(gpg -K --with-colons 2> /dev/null | grep ^uid: | cut -d: -f10); do
            gpg+=("$line")
        done

        echo
        PS3="Select user/mail from gpg ❭ "
        select opt in ${gpg[*]}; do
            git_username=$(echo "$opt" | sed -re 's,\s*([^<]+).*,\1,g' )
            git_mail=$(echo "$opt" | sed -re 's,\s*[^<]+<([^>]+)>.*,\1,g' )
            break
        done
        echo
    fi

    [[ -z $git_username ]] && read -p 'enter username ❭ ' git_username
    [[ -z $git_mail ]] && read -p 'enter mail ❭ ' git_mail
    [[ -z $git_username || -z $git_mail ]] && echo "Need to provide user/mail" && return

    git_username_branch=$(echo "$git_username" | tr -s ' ' '.' | tr -s [:upper:] [:lower:])
    sed -i "s/__USERNAME__/$git_username/g" ~/.git/gitconfig
    sed -i "s/__USERNAME_BRANCH__/$git_username_branch/g" ~/.git/gitconfig
    sed -i "s/__MAIL__/$git_mail/g" ~/.git/gitconfig

    if gpg -K "$git_username <$git_mail>" &> /dev/null; then
        git config --global commit.gpgsign true
        echo
        echo "  * gpg signing enabled."
        echo
        echo "    Default sign key will be used, to select a subkey: "
        echo "      ❭ git config --global user.signingkey SUBKEYID!"
        echo "      ❭ gpg --keyid-format long -K | grep '\[.*S.*\]'"
        echo
    fi

}

function install_fonts
{
    [[ $IS_SSH -eq 1 ]] && return
    echo "- Install fonts"
    font_dir="$HOME/.fonts"
    rm -rf "$font_dir" && ln -sf "$SCRIPTPATH/fonts" "$font_dir"
    if [[ -f $(which fc-cache 2> /dev/null) ]]; then
        echo "  ❭ Resetting font cache..."
        fc-cache -f "$font_dir"
    fi
}

function install_config
{
    target=${1:-common}
    echo "- Install .config from config.${target}"
    mkdir -p "$HOME/.config.${target}.backup"

    for cfg in $(ls "config.${target}"); do
        # to replace only a single file in a subdir,
        # handle renamed file path with '\' instead of '/''
        targetcfg=$(echo "$cfg" | sed -e 's/\\/\//g')
        if [[ ! -L "$HOME/.config/$targetcfg" ]]; then
            mv "$HOME/.config/$targetcfg" "$HOME/.config.${target}.backup/$cfg.$(date '+%s')" 2> /dev/null
        fi
        rm -f "$HOME/.config/$targetcfg" 2> /dev/null && ln -sf "$SCRIPTPATH/config.${target}/$cfg" "$HOME/.config/$targetcfg"
    done

    if [[ $target = X11 ]]; then
        # build i3 config
        if which i3 &> /dev/null; then
            echo "  ❭ build i3 conf"
            "$HOME/.config/i3/i3_build_conf.sh" > /dev/null
            ln -sf "$HOME/.config/i3/scripts/i3lock_blur.sh" "$HOME/.local/bin/lockscreen"
        fi

        for app in $(ls $SCRIPTPATH/config.${target}/applications/*.desktop); do
            ln -sf $app "$HOME/.local/share/applications/$(basename $app)"
        done

        for file in $(ls $SCRIPTPATH/config.${target}/dotfiles); do
            ln -sf "$SCRIPTPATH/config.${target}/dotfiles/$file" "$HOME/.$file"
        done
    fi
}

function uninstall
{
    echo "- Uninstall"
    set -x
    rm -rf "$HOME/.local/bin/.nvim"
    rm -rf "$HOME/.zsh"
    for dir in "$HOME" "$HOME/.config" "$HOME/.local/bin"; do
        find "$dir" -maxdepth 1 -lname '*dotfiles*' -delete
        find "$dir" -maxdepth 1 -xtype l -delete
    done
    set +x
}

function print_help
{

    [[ $# -ne 0 ]] && echo "$(tput setaf 1)[ERROR] $*"

    echo "
    Options:

$(declare -f main |
        grep -P '(help=|--|-[a-z]\))' |
        xargs |
        sed -e 's/; /\n/g' -e 's/help=/#/g' |
        column -t -s '#')"

    exit
}

function main
{
    [[ $# -eq 0 ]] && print_help

    echo "Install dotfiles for user $USER"

    while [[ $# -ne 0 ]]; do
        arg="$1"
        shift
        case "$arg" in
            --minimal | -m)
                help="Vim config without plugins, shell (bash+zsh), .local/bin, tmux"
                install_vim_light
                install_shell
                install_tmux
                ;;

            --conf | -c)
                help="shell (bash+zsh), tmux, git, .local/bin"
                install_shell
                install_tmux
                install_git
                install_config common
                install_local_bin
                ;;

            --ui | -x)
                help="i3 cfg, icons, fonts"
                install_fonts
                install_config X11
                ;;

            --nvim | --neovim | -v)
                help="Neovim (optional: stable|nightly|v[0-9])"
                [[ $1 =~ ^(stable|nightly|v[0-9]) ]] &&
                    release=$1 && shift &&
                    install_neovim "$release"
                install_vim_requirements
                install_vim_config
                ;;

            --updatebin | -u)
                help="update bin (pull from github)"
                update_bin_from_deb
                ;;

            --uninstall | -d)
                help="uninstall dotfiles"
                uninstall
                ;;

            --help | -h)
                help="this"
                print_help
                ;;

            *)
                [[ $arg =~ \-+.* ]] && print_help "$arg unknown"
                ;;
        esac
    done

    [[ -d $TMPDIR ]] && rm -rf "$TMPDIR"

    echo "Install dotfiles done !"
}

main "$@"
