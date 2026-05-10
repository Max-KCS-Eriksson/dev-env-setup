#!/usr/bin/env bash

ROOT_DIR=$(dirname "$0")/../../..
source "$ROOT_DIR"/src/helpers/output_labels.sh

# Local server for developing webpages
# https://github.com/tapio/live-server

if command -v live-server &>/dev/null; then
    exit
fi

if ! command -v npm &>/dev/null; then
    warn 'command not found: npm'
    warn 'live-server cannot be built'
    exit 1
fi
npm install -g live-server
