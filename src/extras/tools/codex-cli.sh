#!/usr/bin/env bash

ROOT_DIR=$(dirname "$0")/../../..
source "$ROOT_DIR"/src/helpers/output_labels.sh

if command -v codex &>/dev/null; then
    exit
fi

if ! command -v npm &>/dev/null; then
    warn 'command not found: npm'
    warn 'codex-cli cannot be built'
    exit 1
fi
npm install -g @openai/codex
