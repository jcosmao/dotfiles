#!/usr/bin/env bash
#
# Download latest upstream release of binaries not tracked in git.
# jlog (homemade), ctags/cscope (compiled locally) are NOT handled here.
#
# Usage: ./download.sh [--missing] [tool...]   (default: all)
#   --missing   only download tools not already present in bin/
#
# Robustness:
#   - latest tag resolved via github.com redirect (no API rate limit)
#   - curl retries + timeouts
#   - binary is checked (--version) before replacing the existing one
#   - a failing tool does not stop the others; exit 1 if any failed

set -uo pipefail

BINDIR=$(dirname "$(readlink -f "$0")")
TOOLS=(stern plik jq rg fzf fd bat)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"; rm -f "$BINDIR"/.*.new' EXIT

CURL=(curl -fSL --retry 3 --retry-delay 2 --connect-timeout 10)

function latest_tag {
    local url
    url=$("${CURL[@]}" -s -o /dev/null -w '%{url_effective}' "https://github.com/$1/releases/latest") || return 1
    url=${url##*/}
    [[ -n "$url" && "$url" != "latest" ]] || return 1
    echo "$url"
}

function fetch {
    local url=$1 dest=$2
    echo "-> $url"
    "${CURL[@]}" -s -o "$dest" "$url"
}

# fetch_tar <url> <binary-path-inside-archive> <dest-file>
function fetch_tar {
    local url=$1 member=$2 dest=$3 tmp
    tmp=$(mktemp -d -p "$TMP")
    fetch "$url" "$tmp/archive.tgz" || return 1
    tar -xzf "$tmp/archive.tgz" -C "$tmp" "$member" || return 1
    mv "$tmp/$member" "$dest"
}

# Each download_<tool> writes the binary to $1

function download_stern {
    local tag
    tag=$(latest_tag stern/stern) || return 1         # v1.34.0
    fetch_tar "https://github.com/stern/stern/releases/download/$tag/stern_${tag#v}_linux_amd64.tar.gz" \
        stern "$1"
}

function download_plik {
    local tag
    tag=$(latest_tag root-gg/plik) || return 1        # 1.4.2
    fetch "https://github.com/root-gg/plik/releases/download/$tag/plik-$tag-linux-amd64" "$1"
}

function download_jq {
    local tag
    tag=$(latest_tag jqlang/jq) || return 1           # jq-1.8.2
    fetch "https://github.com/jqlang/jq/releases/download/$tag/jq-linux-amd64" "$1"
}

function download_rg {
    local tag
    tag=$(latest_tag BurntSushi/ripgrep) || return 1  # 15.2.0
    fetch_tar "https://github.com/BurntSushi/ripgrep/releases/download/$tag/ripgrep-$tag-x86_64-unknown-linux-musl.tar.gz" \
        "ripgrep-$tag-x86_64-unknown-linux-musl/rg" "$1"
}

function download_fzf {
    local tag
    tag=$(latest_tag junegunn/fzf) || return 1        # v0.74.3
    fetch_tar "https://github.com/junegunn/fzf/releases/download/$tag/fzf-${tag#v}-linux_amd64.tar.gz" \
        fzf "$1"
}

function download_fd {
    local tag
    tag=$(latest_tag sharkdp/fd) || return 1          # v10.4.2
    fetch_tar "https://github.com/sharkdp/fd/releases/download/$tag/fd-$tag-x86_64-unknown-linux-musl.tar.gz" \
        "fd-$tag-x86_64-unknown-linux-musl/fd" "$1"
}

function download_bat {
    local tag
    tag=$(latest_tag sharkdp/bat) || return 1         # v0.26.1
    fetch_tar "https://github.com/sharkdp/bat/releases/download/$tag/bat-$tag-x86_64-unknown-linux-musl.tar.gz" \
        "bat-$tag-x86_64-unknown-linux-musl/bat" "$1"
}

# Download into bin/.<tool>.new (not in $TMP: /tmp may be noexec),
# check it runs, then atomically replace bin/<tool>.
function install_tool {
    local tool=$1 new="$BINDIR/.$1.new"
    declare -F "download_$tool" > /dev/null || { echo "unknown tool: $tool"; return 1; }
    "download_$tool" "$new" || return 1
    chmod 755 "$new"
    "$new" --version > /dev/null 2>&1 || { echo "$tool: downloaded binary does not run"; return 1; }
    mv -f "$new" "$BINDIR/$tool"
    "$BINDIR/$tool" --version 2>&1 | head -1
}

MISSING_ONLY=0
if [[ ${1:-} == "--missing" ]]; then
    MISSING_ONLY=1; shift
fi

if [[ $(uname -m) != "x86_64" ]]; then
    echo "Unsupported arch $(uname -m): only x86_64 binaries are handled" >&2
    exit 1
fi

failed=()
for tool in "${@:-${TOOLS[@]}}"; do
    if [[ $MISSING_ONLY -eq 1 && -x "$BINDIR/$tool" ]]; then
        continue
    fi
    echo "### $tool"
    install_tool "$tool" || failed+=("$tool")
done

if [[ ${#failed[@]} -ne 0 ]]; then
    echo "FAILED: ${failed[*]}" >&2
    exit 1
fi
