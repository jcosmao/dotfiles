#!/usr/bin/env bash
#
# Download latest upstream release of binaries not tracked in git.
# jlog (homemade), ctags/cscope (compiled locally) are NOT handled here.
# Usage: ./download.sh [tool...]   (default: all)

set -euo pipefail

BINDIR=$(dirname "$(readlink -f "$0")")
TOOLS=(stern plik jq rg fzf fd bat)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

function latest_tag {
    curl -fsSL "https://api.github.com/repos/$1/releases/latest" |
        grep -oP '"tag_name": "\K[^"]+'
}

function fetch {
    local url=$1 dest=$2
    echo "-> $url"
    curl -fSL --progress-bar -o "$dest" "$url"
}

# fetch_tar <url> <binary-path-inside-archive> <dest-name>
function fetch_tar {
    local url=$1 member=$2 dest=$3 tmp
    tmp=$(mktemp -d -p "$TMP")
    fetch "$url" "$tmp/archive.tgz"
    tar -xzf "$tmp/archive.tgz" -C "$tmp" "$member"
    install -m 755 "$tmp/$member" "$BINDIR/$dest"
}

function download_stern {
    local tag ver
    tag=$(latest_tag stern/stern)          # v1.34.0
    ver=${tag#v}
    fetch_tar "https://github.com/stern/stern/releases/download/$tag/stern_${ver}_linux_amd64.tar.gz" \
        stern stern
}

function download_plik {
    local tag
    tag=$(latest_tag root-gg/plik)         # 1.4.2
    fetch "https://github.com/root-gg/plik/releases/download/$tag/plik-$tag-linux-amd64" "$BINDIR/plik"
    chmod 755 "$BINDIR/plik"
}

function download_jq {
    local tag
    tag=$(latest_tag jqlang/jq)            # jq-1.8.2
    fetch "https://github.com/jqlang/jq/releases/download/$tag/jq-linux-amd64" "$BINDIR/jq"
    chmod 755 "$BINDIR/jq"
}

function download_rg {
    local tag
    tag=$(latest_tag BurntSushi/ripgrep)   # 15.2.0
    fetch_tar "https://github.com/BurntSushi/ripgrep/releases/download/$tag/ripgrep-$tag-x86_64-unknown-linux-musl.tar.gz" \
        "ripgrep-$tag-x86_64-unknown-linux-musl/rg" rg
}

function download_fzf {
    local tag ver
    tag=$(latest_tag junegunn/fzf)         # v0.74.3
    ver=${tag#v}
    fetch_tar "https://github.com/junegunn/fzf/releases/download/$tag/fzf-$ver-linux_amd64.tar.gz" \
        fzf fzf
}

function download_fd {
    local tag
    tag=$(latest_tag sharkdp/fd)           # v10.4.2
    fetch_tar "https://github.com/sharkdp/fd/releases/download/$tag/fd-$tag-x86_64-unknown-linux-musl.tar.gz" \
        "fd-$tag-x86_64-unknown-linux-musl/fd" fd
}

function download_bat {
    local tag
    tag=$(latest_tag sharkdp/bat)          # v0.26.1
    fetch_tar "https://github.com/sharkdp/bat/releases/download/$tag/bat-$tag-x86_64-unknown-linux-musl.tar.gz" \
        "bat-$tag-x86_64-unknown-linux-musl/bat" bat
}

for tool in "${@:-${TOOLS[@]}}"; do
    echo "### $tool"
    "download_$tool"
    "$BINDIR/$tool" --version
done
