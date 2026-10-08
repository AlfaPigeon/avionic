#!/usr/bin/env bash
# Clipboard history (cliphist) in rofi. Enter copies the entry back.
set -euo pipefail

choice="$(cliphist list | rofi -dmenu -i -p "clipboard" -display-columns 2)" || exit 0
[[ -n "$choice" ]] || exit 0
cliphist decode <<<"$choice" | wl-copy
