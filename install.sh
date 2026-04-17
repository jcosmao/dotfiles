#!/usr/bin/env bash

# --- Strict Mode Configuration ---
set -euo pipefail

# --- Global Variables ---
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
IS_SSH=${SSH_TTY:-""}
TMPDIR=$SCRIPTPATH/tmp
DOTFILES_DIR="$HOME/.dotfiles"

# UI Colors
GR=$(tput setaf 2)
YL=$(tput setaf 3)
RE=$(tput setaf 1)
NC=$(tput sgr0)

# --- Helpers ---
log() { echo -e "${GR}❭${NC} $1"; }
warn() { echo -e "${YL}❭${NC} $1"; }
error() { echo -e "${RE}[ERROR]${NC} $1"; exit 1; }

# --- Integrity Check ---
cd "$SCRIPTPATH" || exit
if [[ "$SCRIPTPATH" != "$DOTFILES_DIR" ]]; then
    error "The script must be executed from $DOTFILES_DIR"
fi

mkdir -p "$TMPDIR" ~/.config ~/.local/bin ~/.config.backup

# --- Core Functions ---

function safe_link() {
    local src=$1
    local dest=$2
    mkdir -p "$(dirname "$dest")"
    ln -sfn "$src" "$dest"
}

function install_neovim {
    local release=${1:-stable}
    log "Updating Neovim ($release)..."
    local url="https://github.com/neovim/neovim/releases/download/$release/nvim-linux-x86_64.appimage"

    curl -fLo "$TMPDIR/nvim.appimage" "$url" 2>/dev/null || cp nvim/nvim.appimage "$TMPDIR" 2>/dev/null
    chmod +x "$TMPDIR/nvim.appimage"

    (
        cd ~/.local/bin
        rm -rf .nvim
        "$TMPDIR/nvim.appimage" --appimage-extract > /dev/null
        mv squashfs-root .nvim
        safe_link "$HOME/.local/bin/.nvim/usr/bin/nvim" "$HOME/.local/bin/nvim"
        safe_link "nvim" "$HOME/.local/bin/vim"
    )
}

function install_vim_requirements {
    log "Installing Vim requirements (uv + treesitter)..."
    [[ ! -e ~/.local/bin/nvim ]] && install_neovim 'stable'
    safe_link "$SCRIPTPATH/ctags/ctags.d" ~/.ctags.d

    if [[ ! -d ~/.venvs/nvim ]]; then
        uv venv ~/.venvs/nvim
    fi
    source ~/.venvs/nvim/bin/activate
    uv pip install --upgrade pynvim yamllint pyproject-flake8 black

    if ! command -v tree-sitter &> /dev/null; then
        warn "tree-sitter-cli not detected. Install it with: cargo install tree-sitter-cli"
    fi
}

function install_vim_config {
    log "Linking Neovim configuration..."
    safe_link "$SCRIPTPATH/neovim" ~/.config/nvim
    ~/.local/bin/nvim --headless +qall 2> /dev/null || true
}

function install_vim_light {
    log "Installing Vim-Lite..."
    rm -rf ~/.vim && safe_link "$SCRIPTPATH/vim" ~/.vim
    rm -f ~/.local/bin/vim
    safe_link ~/.vim/vimrc_lite.vim ~/.vimrc
}

function install_shell {
    log "Installing Shell (Bash/Zsh)..."
    safe_link "$SCRIPTPATH/shell" ~/.shell
    safe_link "$SCRIPTPATH/shell/dir_colors" ~/.dir_colors
    mkdir -p ~/.bash_custom
    safe_link "$SCRIPTPATH/shell/zshrc" ~/.zshrc
    safe_link "$SCRIPTPATH/bin/fzf" ~/.local/bin/fzf

    local bashrc_path=$HOME/.bashrc
    [[ -n ${LC_BASTION:-""} ]] && bashrc_path=$HOME/.bashrc-$LC_BASTION
    safe_link "$SCRIPTPATH/shell/bashrc" "$bashrc_path"
}

function update_bin_from_deb {
    log "Fetching latest ripgrep and fd binaries..."
    # Ripgrep
    local rg_v=$(curl -sI https://github.com/BurntSushi/ripgrep/releases/latest | grep -i location | grep -oE "[0-9.]+" | head -1)
    curl -fLo "$TMPDIR/rg.deb" "https://github.com/BurntSushi/ripgrep/releases/download/$rg_v/ripgrep_${rg_v}-1_amd64.deb"

    # FD
    local fd_v=$(curl -sI https://github.com/sharkdp/fd/releases/latest | grep -i location | grep -oE "v[0-9.]+" | head -1)
    curl -fLo "$TMPDIR/fd.deb" "https://github.com/sharkdp/fd/releases/download/$fd_v/fd_${fd_v#v}_amd64.deb"

    (
        cd "$TMPDIR"
        ar x rg.deb && tar xf data.tar.xz && cp usr/bin/rg "$SCRIPTPATH/bin/"
        rm -rf usr data.tar.xz control.tar.gz debian-binary
        ar x fd.deb && tar xf data.tar.xz && cp usr/bin/fd "$SCRIPTPATH/bin/"
    )
    chmod +x "$SCRIPTPATH/bin/"*
}

function install_local_bin {
    log "Linking binaries to ~/.local/bin..."
    for f in bin/*; do
        local bin_file=$(basename "$f")
        [[ "$bin_file" == "README.md" ]] && continue
        # Verify if binary is compatible with architecture (ldd)
        if [[ $(ldd "$f" 2>&1 | grep -c 'not found') -eq 0 ]]; then
            log "  install $bin_file"
            safe_link "$SCRIPTPATH/$f" "$HOME/.local/bin/${bin_file%.*}"
            [[ "$bin_file" == "bat" ]] && bat cache --build &> /dev/null || true
        fi
    done
}

function install_tmux {
    log "Configuring Tmux..."
    safe_link "$SCRIPTPATH/tmux/tm" ~/.local/bin/tm
    safe_link "$SCRIPTPATH/tmux" ~/.tmux
    safe_link "$SCRIPTPATH/tmux/tmux.conf" ~/.tmux.conf
}

function install_git {
    log "Configuring Git..."
    local user=$(git config --get user.name || echo "${GIT_USER:-}")
    local mail=$(git config --get user.email || echo "${GIT_MAIL:-}")

    safe_link "$SCRIPTPATH/git" ~/.git
    cp ~/.git/gitconfig.template ~/.git/gitconfig
    safe_link ~/.git/gitconfig ~/.gitconfig
    safe_link ~/.git/gitignore ~/.gitignore

    if [[ -z "$user" || -z "$mail" ]]; then
        read -p "Git Username: " user
        read -p "Git Email: " mail
    fi

    user_branch=$(echo "$user" | tr -s ' ' '.' | tr -s [:upper:] [:lower:])
    sed -i "s/__USERNAME_BRANCH__/$user_branch/g" ~/.git/gitconfig

    if gpg -K "$user <$mail>" &> /dev/null; then
        git config --global commit.gpgsign true
        echo
        echo "  * gpg signing enabled."
        echo
        echo "    Default sign key will be used, to select a subkey: "
        echo "      ❭ git config --global user.signingkey SUBKEYID!"
        echo "      ❭ gpg --keyid-format long -K | grep '\[.*S.*\]'"
        echo
    fi

    sed -i "s/__USERNAME__/$user/g" ~/.git/gitconfig
    sed -i "s/__MAIL__/$mail/g" ~/.git/gitconfig
}

function install_fonts {
    [[ -n "$IS_SSH" ]] && return
    log "Installing fonts..."
    safe_link "$SCRIPTPATH/fonts" ~/.fonts
    command -v fc-cache &>/dev/null && fc-cache -f ~/.fonts || true
}

function install_config {
    local label=${1:-"common"}
    log "Installing .config folders ($label)..."
    for cfg in $(ls "config"); do
        local target=$(echo "$cfg" | sed 's/\\/\//g')
        safe_link "$SCRIPTPATH/config/$cfg" "$HOME/.config/$target"
    done
}

function install_x_conf {
    log "Installing X11 / i3 environment..."
    for cfg in $(ls "X/config"); do
        local target=$(echo "$cfg" | sed 's/\\/\//g')
        safe_link "$SCRIPTPATH/X/config/$cfg" "$HOME/.config/$target"
    done
    for f in X/bin/*; do
        [[ $(basename "$f") == "README.md" ]] && continue
        safe_link "$SCRIPTPATH/$f" "$HOME/.local/bin/$(basename "$f")"
    done
}

function uninstall {
    warn "Uninstalling: removing symlinks pointing to $DOTFILES_DIR..."
    find "$HOME" -maxdepth 1 -lname "*$DOTFILES_DIR*" -delete
    find "$HOME/.config" -maxdepth 1 -lname "*$DOTFILES_DIR*" -delete
    find "$HOME/.local/bin" -maxdepth 1 -lname "*$DOTFILES_DIR*" -delete
}

function print_help {
    [[ $# -ne 0 ]] && echo -e "${RE}[ERROR] $*${NC}"
    echo -e "\n${GR}Usage:${NC} ./dotfiles [options]\n"
    echo "Options:"
    local opts=(
        "-m, --minimal#Minimal install: Vim-lite, Shell, .local/bin and Tmux."
        "-c, --conf#Full CLI install: Shell, Tmux, Git, .local/bin and .config."
        "-n, --nvim [ver]#Neovim + deps. Optional version: stable, nightly, v0.11.x."
        "-x, --ui#GUI environment: i3, fonts, icons and X11 scripts."
        "-u, --updatebin#Downloads latest binaries (ripgrep, fd) from GitHub."
        "-d, --uninstall#Clean up all symlinks in your \$HOME."
        "-h, --help#Display this help menu."
    )
    printf "%s\n" "${opts[@]}" | column -t -s '#' | sed 's/^/  /'
    echo -e "\n${YL}Note:${NC} Option -n uses 'stable' by default."
    exit 0
}

# --- Main Entry Point ---

function main {
    [[ $# -eq 0 ]] && print_help
    log "Starting dotfiles installation for $USER"

    while [[ $# -ne 0 ]]; do
        arg="$1"; shift
        case "$arg" in
            --minimal | -m)
                install_vim_light
                install_shell
                install_local_bin
                install_tmux
                ;;
            --conf | -c)
                install_shell
                install_tmux
                install_git
                install_config "common"
                install_local_bin
                ;;
            --ui | -x)
                install_fonts
                install_x_conf
                ;;
            --nvim | --neovim | -n)
                local release="stable"
                if [[ ${1:-} =~ ^(stable|nightly|v[0-9]) ]]; then
                    release="$1"; shift
                fi
                install_neovim "$release"
                install_vim_requirements
                install_local_bin
                install_vim_config
                ;;
            --updatebin | -u)
                update_bin_from_deb
                ;;
            --uninstall | -d)
                uninstall
                exit 0
                ;;
            --help | -h)
                print_help
                ;;
            *)
                [[ "$arg" =~ ^-+ ]] && print_help "Unknown option: $arg"
                ;;
        esac
    done

    [[ -d "$TMPDIR" ]] && rm -rf "$TMPDIR"
    log "Installation completed successfully!"
}

main "$@"
