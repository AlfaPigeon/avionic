#!/usr/bin/env bash
# Searchable list of every bind that has a description (see hyprland.lua).
set -euo pipefail

hyprctl binds -j | jq -r '
    def mods:
        [ (if . % 128 >= 64 then "SUPER" else empty end),
          (if . % 8   >= 4  then "CTRL"  else empty end),
          (if . % 16  >= 8  then "ALT"   else empty end),
          (if . % 2   >= 1  then "SHIFT" else empty end) ] | join(" + ");
    .[]
    | select(.has_description and .submap == "")
    | ((.modmask | mods) as $m
       | (if $m == "" then .key else $m + " + " + .key end)) as $combo
    | "\($combo)\t\(.description)"
' | column -t -s $'\t' | rofi -dmenu -i -p "keybinds" -theme-str 'window { width: 760px; }' >/dev/null || true
