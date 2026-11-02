#!/usr/bin/env bash

set -euo pipefail

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
IS_SSH=${SSH_TTY:-""}
TMPDIR=$SCRIPTPATH/tmp
DOTFILES_DIR="$HOME/.dotfiles"
export CARGO_HOME=${CARGO_HOME:-$HOME/.cargo}
export RUSTUP_HOME=${RUSTUP_HOME:-$HOME/.rustup}
export PATH="$HOME/.local/bin:$CARGO_HOME/bin:$PATH"

GR=$(tput setaf 2)
YL=$(tput setaf 3)
RE=$(tput setaf 1)
NC=$(tput sgr0)

log() { echo -e "${GR}❭${NC} $1"; }
warn() { echo -e "${YL}❭${NC} $1"; }
error() { echo -e "${RE}[ERROR]${NC} $1"; exit 1; }

cd "$SCRIPTPATH" || exit
if [[ "$SCRIPTPATH" != "$DOTFILES_DIR" ]]; then
    error "The script must be executed from $DOTFILES_DIR"
fi

mkdir -p "$TMPDIR" ~/.config ~/.local/bin ~/.config.backup

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
    local nvim_share="$HOME/.local/share/nvim"

    curl -fLo "$TMPDIR/nvim.appimage" "$url" 2>/dev/null || cp nvim/nvim.appimage "$TMPDIR" 2>/dev/null
    chmod +x "$TMPDIR/nvim.appimage"

    # Clean up old non-standard location
    [[ -d "$HOME/.local/bin/.nvim" ]] && rm -rf "$HOME/.local/bin/.nvim"

    mkdir -p "$nvim_share"
    (
        cd "$nvim_share"
        rm -rf squashfs-root
        "$TMPDIR/nvim.appimage" --appimage-extract > /dev/null
        mv squashfs-root appimage
        safe_link "$nvim_share/appimage/usr/bin/nvim" "$HOME/.local/bin/nvim"
        safe_link "nvim" "$HOME/.local/bin/vim"
        safe_link "$SCRIPTPATH/neovim" "$HOME/.config/nvim"
    )
}

function install_vim_requirements {
    log "Installing Vim requirements (uv + cargo + tree-sitter-cli)..."
    [[ ! -e ~/.local/bin/nvim ]] && install_neovim 'stable'
    command -v uv &> /dev/null || install_uv
    safe_link "$SCRIPTPATH/ctags/ctags.d" ~/.ctags.d

    if [[ ! -d ~/.venvs/nvim ]]; then
        uv venv ~/.venvs/nvim
    fi
    source ~/.venvs/nvim/bin/activate
    uv pip install --upgrade pynvim yamllint pyproject-flake8 black

    command -v cargo &> /dev/null || install_cargo
    if command -v tree-sitter &> /dev/null; then
        log "  $(tree-sitter --version) already installed"
    elif ! command -v cargo &> /dev/null; then
        warn "cargo not available: tree-sitter-cli not installed"
    elif ! command -v cc &> /dev/null; then
        warn "No C compiler (cc): install build-essential, then: cargo install --locked tree-sitter-cli"
    else
        log "  cargo install tree-sitter-cli..."
        cargo install --locked tree-sitter-cli || warn "tree-sitter-cli install failed"
    fi
}

function install_cargo {
    if command -v rustup &> /dev/null; then
        log "Updating Rust toolchain (rustup)..."
        rustup update stable &> /dev/null || warn "rustup update failed"
        return 0
    fi
    log "Installing Rust toolchain (rustup + cargo)..."
    curl -fsSL --proto '=https' --tlsv1.2 --retry 3 --connect-timeout 10 https://sh.rustup.rs |
        TMPDIR="$TMPDIR" sh -s -- -y --no-modify-path --profile minimal --default-toolchain stable ||
        warn "rustup install failed"
}

function install_alacritty {
    log "Installing Alacritty (cargo)..."
    command -v cargo &> /dev/null || install_cargo
    if ! command -v cargo &> /dev/null; then
        warn "cargo not available: alacritty not installed"; return 0
    fi

    # build deps (xkbcommon/xcb are dlopen'ed at runtime, no -dev needed)
    local missing=()
    command -v cc &> /dev/null || missing+=(build-essential)
    command -v cmake &> /dev/null || missing+=(cmake)
    if ! command -v pkg-config &> /dev/null; then
        missing+=(pkg-config)
    else
        local lib
        for lib in fontconfig:libfontconfig1-dev freetype2:libfreetype6-dev; do
            pkg-config --exists "${lib%%:*}" || missing+=("${lib#*:}")
        done
    fi
    if [[ ${#missing[@]} -ne 0 ]]; then
        warn "Missing alacritty build deps: sudo apt install ${missing[*]}"
        return 0
    fi

    # no-op if already up to date
    if cargo install --locked alacritty; then
        safe_link "$CARGO_HOME/bin/alacritty" ~/.local/bin/alacritty
    else
        warn "alacritty install failed"
    fi
}

function install_enpass {
    # Enpass ships 2 builds: apt suite "stable" = Wayland, suite "x11" = X11
    local variant=${1:-}
    if [[ -z "$variant" ]]; then
        if [[ -n "${WAYLAND_DISPLAY:-}" || "${XDG_SESSION_TYPE:-}" == "wayland" ]]; then
            variant=wayland
        else
            variant=x11
        fi
    fi
    local suite
    case "$variant" in
        wayland) suite=stable ;;
        x11) suite=x11 ;;
        *) warn "Unknown enpass variant: $variant (x11|wayland)"; return 0 ;;
    esac
    log "Installing Enpass $variant (.deb, extracted without root)..."
    local repo="https://apt.enpass.io"

    # latest "enpass" package from the official apt repo index: "<version> <filename> <sha256>"
    local latest
    latest=$(curl -fsSL --retry 3 --connect-timeout 10 "$repo/dists/$suite/main/binary-amd64/Packages" |
        awk -v RS= '/(^|\n)Package: enpass\n/ {
            for (i = 1; i <= split($0, l, "\n"); i++) {
                split(l[i], kv, ": ")
                if (kv[1] == "Version") v = kv[2]
                if (kv[1] == "Filename") f = kv[2]
                if (kv[1] == "SHA256") h = kv[2]
            }
            print v, f, h
        }' | sort -V | tail -1) || latest=""
    local version filename sha256
    read -r version filename sha256 <<< "$latest"
    if [[ -z "$filename" || -z "$sha256" ]]; then
        warn "Unable to fetch enpass package index"; return 0
    fi

    # no root: extract the .deb in ~/.local/opt/enpass instead of apt install
    local dest="$HOME/.local/opt/enpass"
    if [[ "$(cat "$dest/.version" 2>/dev/null)" == "$version $variant" ]]; then
        log "  enpass $version ($variant) already installed"; return 0
    fi

    local deb="$TMPDIR/$(basename "$filename")" root="$TMPDIR/enpass-root"
    if ! curl -fSL --retry 3 --connect-timeout 10 -o "$deb" "$repo/$filename"; then
        warn "enpass download failed"; return 0
    fi
    if ! echo "$sha256  $deb" | sha256sum -c --quiet -; then
        warn "enpass .deb checksum mismatch"; return 0
    fi

    rm -rf "$root" && mkdir -p "$root"
    if command -v dpkg-deb &> /dev/null; then
        dpkg-deb -x "$deb" "$root"
    else
        local data
        data=$(ar t "$deb" | grep '^data\.tar') &&
            (cd "$root" && ar x "$deb" "$data" && tar -xf "$data" && rm -f "$data")
    fi || { warn "enpass .deb extraction failed"; return 0; }
    [[ -x "$root/opt/enpass/Enpass" ]] || { warn "enpass binary not found in .deb"; return 0; }

    mkdir -p "$(dirname "$dest")"
    rm -rf "$dest" && mv "$root/opt/enpass" "$dest"
    echo "$version $variant" > "$dest/.version"
    safe_link "$dest/Enpass" ~/.local/bin/enpass

    # desktop integration (launcher, icons, enpass:// handlers)
    local share="$HOME/.local/share"
    mkdir -p "$share/applications" "$share/icons" "$share/mime/packages"
    sed "s|/opt/enpass/Enpass|$dest/Enpass|" "$root/usr/share/applications/enpass.desktop" \
        > "$share/applications/enpass.desktop"
    cp -r "$root/usr/share/icons/hicolor" "$share/icons/"
    cp "$root/usr/share/mime/packages/"*.xml "$share/mime/packages/"
    command -v update-desktop-database &> /dev/null && update-desktop-database "$share/applications" || true
    command -v update-mime-database &> /dev/null && update-mime-database "$share/mime" &> /dev/null || true
    command -v gtk-update-icon-cache &> /dev/null && gtk-update-icon-cache -q "$share/icons/hicolor" &> /dev/null || true

    # Wayland build: browser autofill relies on a GNOME Shell extension (user-level install)
    local ext_uuid="enpass-assistant@enpass.io" ext_src="$root/usr/share/enpass/gnome-extension"
    local ext_dest="$share/gnome-shell/extensions/$ext_uuid"
    rm -rf "$ext_dest"
    if [[ -d "$ext_src" ]] && command -v gnome-shell &> /dev/null; then
        local major
        major=$(gnome-shell --version 2>/dev/null | grep -oE '[0-9]+' | head -1)
        if [[ -n "$major" ]]; then
            [[ $major -ge 45 ]] && ext_src+=/modern || ext_src+=/legacy
            mkdir -p "$ext_dest" && cp "$ext_src/"* "$ext_dest/"
            command -v gnome-extensions &> /dev/null && gnome-extensions enable "$ext_uuid" &> /dev/null ||
                warn "  GNOME extension installed, enable it after re-login: gnome-extensions enable $ext_uuid"
        fi
    fi

    rm -rf "$root" "$deb"
    log "  enpass $version ($variant) installed in $dest"
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
    safe_link "$SCRIPTPATH/shell/zshenv" ~/.zshenv

    local bashrc_path=$HOME/.bashrc
    [[ -n ${LC_BASTION:-""} ]] && bashrc_path=$HOME/.bashrc-$LC_BASTION
    safe_link "$SCRIPTPATH/shell/bashrc" "$bashrc_path"

    # bashrc execs zsh when ~/.force_zsh exists
    if command -v zsh &> /dev/null; then
        log "  zsh detected: force zsh as default shell (~/.force_zsh)"
        touch ~/.force_zsh
    fi
}

function install_uv {
    if command -v uv &> /dev/null; then
        log "Updating uv..."
        uv self update &> /dev/null || warn "uv self update failed (not installed via standalone installer?)"
        return
    fi
    log "Installing uv..."
    curl -fLsS --retry 3 --connect-timeout 10 https://astral.sh/uv/install.sh |
        env TMPDIR="$TMPDIR" UV_NO_MODIFY_PATH=1 UV_INSTALL_DIR="$HOME/.local/bin" sh ||
        warn "uv install failed"
}

function install_restic {
    log "Installing restic..."
    local v
    v=$(curl -fsSL --retry 3 --connect-timeout 10 -o /dev/null -w '%{url_effective}' \
        https://github.com/restic/restic/releases/latest) || v=""
    v=${v##*/}
    if [[ ! "$v" =~ ^v[0-9] ]]; then
        warn "Unable to fetch restic latest version"; return 0
    fi
    if command -v restic &> /dev/null && [[ "$(restic version 2>/dev/null)" == "restic ${v#v} "* ]]; then
        log "  restic $v already installed"; return 0
    fi
    if curl -fsSL --retry 3 --connect-timeout 10 -o "$TMPDIR/restic.bz2" \
            "https://github.com/restic/restic/releases/download/$v/restic_${v#v}_linux_amd64.bz2" &&
        bunzip2 -f "$TMPDIR/restic.bz2" &&
        install -m 755 "$TMPDIR/restic" ~/.local/bin/restic; then
        log "  $(restic version)"
    else
        warn "restic install failed"
    fi
}

function update_bin {
    log "Downloading latest binaries (bin/download.sh)..."
    "$SCRIPTPATH/bin/download.sh" "$@" || warn "Some binaries failed to download (see above)"
}

function install_local_bin {
    # untracked upstream binaries (rg, fzf, fd, bat...): fetch the missing ones
    update_bin --missing

    log "Linking binaries to ~/.local/bin..."
    for f in bin/*; do
        local bin_file=$(basename "$f")
        [[ "$bin_file" == "README.md" ]] && continue
        # Verify if binary is compatible with architecture (ldd)
        if [[ $(ldd "$f" 2>&1 | grep -c 'not found') -eq 0 ]]; then
            log "  install $bin_file"
            safe_link "$SCRIPTPATH/$f" "$HOME/.local/bin/${bin_file%%.*}"
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
    local signingkey=$(git config --get user.signingkey || echo "")

    safe_link "$SCRIPTPATH/git" ~/.git
    cp ~/.git/gitconfig.template ~/.git/gitconfig
    safe_link ~/.git/gitconfig ~/.gitconfig
    safe_link ~/.git/gitignore ~/.gitignore

    if [[ -z "$user" || -z "$mail" ]]; then
        read -p "Git Username: " user
        read -p "Git Email: " mail
    fi

    sed -i "s/__USERNAME__/$user/g" ~/.git/gitconfig
    sed -i "s/__MAIL__/$mail/g" ~/.git/gitconfig

    # dev branches use login truncated to 8 chars: dev/<login8>/<branch>
    user_branch=$(echo "${USER}" | cut -c1-8)
    sed -i "s/__USERNAME_BRANCH__/$user_branch/g" ~/.git/gitconfig

    if gpg -K "$user <$mail>" &> /dev/null; then
        git config --global commit.gpgsign true
        echo
        echo "  * gpg signing enabled."
        echo
        echo "    To select a specific signing key: "
        echo "      ❭ git config --global user.signingkey SUBKEYID!"
        echo "      ❭ gpg --keyid-format long -K | grep '\[.*S.*\]'"
        echo
    fi

    if [[ -n "$signingkey" ]]; then
        git config --global user.signingkey "$signingkey"
    fi
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
        [[ "$cfg" == "dotfiles" ]] && continue
        local target=$(echo "$cfg" | sed 's/\\/\//g')
        safe_link "$SCRIPTPATH/X/config/$cfg" "$HOME/.config/$target"
    done
    # X/config/dotfiles/* are home dotfiles: Xresources -> ~/.Xresources, ...
    for f in X/config/dotfiles/*; do
        safe_link "$SCRIPTPATH/$f" "$HOME/.$(basename "$f")"
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
        "-c, --conf#Full CLI install: Shell, Tmux, Git, .local/bin, .config, uv and restic."
        "-n, --nvim [ver]#Neovim + deps (uv, cargo, tree-sitter-cli). Optional version: stable, nightly, v0.11.x."
        "-x, --ui#GUI environment: i3, fonts, icons, X11 scripts and alacritty."
        "-e, --enpass [x11|wayland]#Enpass .deb extracted in ~/.local/opt (no root). Default: current session type."
        "-u, --updatebin#Download latest binaries (rg, fzf, fd, bat, jq, stern, plik) from GitHub."
        "-d, --uninstall#Clean up all symlinks in your \$HOME."
        "-h, --help#Display this help menu."
    )
    printf "%s\n" "${opts[@]}" | column -t -s '#' | sed 's/^/  /'
    echo -e "\n${YL}Note:${NC} Option -n uses 'stable' by default."
    exit 0
}

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
                install_uv
                install_restic
                ;;
            --ui | -x)
                install_fonts
                install_x_conf
                install_alacritty
                ;;
            --nvim | --neovim | -n)
                local release="stable"
                if [[ ${1:-} =~ ^(stable|nightly|v[0-9]) ]]; then
                    release="$1"; shift
                fi
                install_neovim "$release"
                install_vim_requirements
                install_local_bin
                ;;
            --enpass | -e)
                local variant=""
                if [[ ${1:-} =~ ^(x11|wayland)$ ]]; then
                    variant="$1"; shift
                fi
                install_enpass "$variant"
                ;;
            --updatebin | -u)
                update_bin
                install_local_bin
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
