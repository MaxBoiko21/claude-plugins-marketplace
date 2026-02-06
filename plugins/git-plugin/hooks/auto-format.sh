#!/bin/bash

# PostToolUse hook: auto-format files after Write/Edit
# Receives tool_input JSON via stdin, file_path extracted from it

set -euo pipefail

INPUT=$(cat)

TOOL_NAME="${TOOL_NAME:-}"
if [[ "$TOOL_NAME" != "Write" && "$TOOL_NAME" != "Edit" ]]; then
  exit 0
fi

FILE_PATH=$(echo "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"//;s/"$//')

if [[ -z "$FILE_PATH" || ! -f "$FILE_PATH" ]]; then
  exit 0
fi

EXT="${FILE_PATH##*.}"
DIR=$(dirname "$FILE_PATH")

format_php() {
  # Walk up to find vendor/bin/pint
  local dir="$DIR"
  while [[ "$dir" != "/" ]]; do
    if [[ -x "$dir/vendor/bin/pint" ]]; then
      "$dir/vendor/bin/pint" "$FILE_PATH" --quiet 2>/dev/null
      return
    fi
    dir=$(dirname "$dir")
  done
}

format_js() {
  # Walk up to find node_modules/.bin/prettier
  local dir="$DIR"
  while [[ "$dir" != "/" ]]; do
    if [[ -x "$dir/node_modules/.bin/prettier" ]]; then
      "$dir/node_modules/.bin/prettier" --write "$FILE_PATH" 2>/dev/null
      return
    fi
    dir=$(dirname "$dir")
  done
}

format_go() {
  if command -v gofmt &>/dev/null; then
    gofmt -w "$FILE_PATH" 2>/dev/null
  fi
}

case "$EXT" in
  php)
    format_php
    ;;
  js|ts|jsx|tsx)
    format_js
    ;;
  go)
    format_go
    ;;
esac

exit 0
