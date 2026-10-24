#!/bin/bash
# Print the clipboard as plain text, or as HTML when plain text is missing.
# The first line tells the panel which kind it is.

set -euo pipefail

read_type() {
  wl-paste --no-newline -t "$1" 2>/dev/null || true
}

has_text() {
  [[ -n ${1//[[:space:]]/} ]]
}

plain=$(read_type text/plain)
if ! has_text "$plain"; then
  plain=$(read_type "text/plain;charset=utf-8")
fi
if has_text "$plain"; then
  printf 'omarchy-uniform\tplain\n%s' "$plain"
  exit 0
fi

html=$(read_type text/html)
if ! has_text "$html"; then
  html=$(read_type "text/html;charset=utf-8")
fi
if has_text "$html"; then
  printf 'omarchy-uniform\thtml\n%s' "$html"
  exit 0
fi

exit 1
