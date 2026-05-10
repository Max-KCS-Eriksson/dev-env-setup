#!/usr/bin/env bash

ROOT_DIR=$(dirname "$0")/../../..
source "$ROOT_DIR"/src/helpers/output_labels.sh

# GitHub CLI
# https://github.com/cli/cli

if command -v gh &>/dev/null; then
    exit
fi

if ! command -v tar &>/dev/null; then
    warn 'command not found: tar'
    warn 'gh cannot be installed without extracting the release archive'
    exit 1
fi

machine=$(uname -m)

case "$machine" in
x86_64)
    arch='amd64'
    ;;
aarch64 | arm64)
    arch='arm64'
    ;;
armv6l | armv6*)
    arch='armv6'
    ;;
i386 | i686)
    arch='386'
    ;;
*)
    warn "unsupported architecture: $machine"
    exit 1
    ;;
esac

if command -v curl &>/dev/null; then
    fetch() {
        curl -fsSL "$1"
    }
    download() {
        curl -fsSL "$1" -o "$2"
    }
elif command -v wget &>/dev/null; then
    fetch() {
        wget -qO- "$1"
    }
    download() {
        wget -qO "$2" "$1"
    }
else
    warn 'command not found: curl or wget'
    warn 'gh cannot be installed without downloading the release archive'
    exit 1
fi

release_json=$(fetch https://api.github.com/repos/cli/cli/releases/latest) || exit 1
version=$(printf '%s\n' "$release_json" | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p')

if [[ -z "$version" ]]; then
    warn 'could not determine the latest gh release version'
    exit 1
fi

archive_name="gh_${version#v}_linux_${arch}.tar.gz"
archive_url="https://github.com/cli/cli/releases/download/${version}/${archive_name}"
install_dir="$HOME/.local/bin"
tmp_dir=$(mktemp -d)

mkdir -p "$install_dir"

cleanup() {
    rm -rf "$tmp_dir"
}

trap cleanup EXIT

download "$archive_url" "$tmp_dir/$archive_name" || exit 1
tar -xzf "$tmp_dir/$archive_name" -C "$tmp_dir" || exit 1
install -m 755 "$tmp_dir"/gh_*/bin/gh "$install_dir/gh"
