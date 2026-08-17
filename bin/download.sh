#!/usr/bin/env bash
#
# Download latest upstream release of binaries not tracked in git (too big).
# Usage: ./download.sh [tool...]   (default: all)

set -euo pipefail

BINDIR=$(dirname "$(readlink -f "$0")")
TOOLS=(stern plik jq)

function latest_tag {
    curl -fsSL "https://api.github.com/repos/$1/releases/latest" |
        grep -oP '"tag_name": "\K[^"]+'
}

function fetch {
    local url=$1 dest=$2
    echo "-> $url"
    curl -fSL --progress-bar -o "$dest" "$url"
}

function download_stern {
    local tag ver tmp
    tag=$(latest_tag stern/stern)          # v1.34.0
    ver=${tag#v}
    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' RETURN
    fetch "https://github.com/stern/stern/releases/download/$tag/stern_${ver}_linux_amd64.tar.gz" "$tmp/stern.tgz"
    tar -xzf "$tmp/stern.tgz" -C "$tmp" stern
    install -m 755 "$tmp/stern" "$BINDIR/stern"
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

for tool in "${@:-${TOOLS[@]}}"; do
    echo "### $tool"
    "download_$tool"
    "$BINDIR/$tool" --version
done
