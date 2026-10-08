# shellcheck shell=bash
# shellcheck disable=SC2034  # variables are read by scripts/apply-theme.sh
# ─────────────────────────────────────────────────────────────────────────────
#  THEME — the single source of truth for every color, font and size.
#
#  PLACEHOLDER PALETTE: "graphite" (dark graphite base + one cool accent).
#  Designer's palette will replace the values below. Keep the key names;
#  only change the values. Then run:  scripts/apply-theme.sh --reload
#
#  Colors are 6-digit hex WITHOUT '#'. Templates can use each color as:
#    {{bg}}      -> #0f1115        (CSS, rasi, kitty, qt)
#    {{bg.hex}}  -> 0f1115         (Hyprland / hyprlang: rgb({{bg.hex}}))
#    {{bg.rgb}}  -> 15, 17, 21     (CSS rgba({{bg.rgb}}, 0.8))
# ─────────────────────────────────────────────────────────────────────────────

theme_name="graphite-placeholder"

# Base layers (darkest -> lightest)
bg="0f1115"         # desktop / window background
bg_alt="15181e"     # bars, panels
surface="1c2028"    # cards, inputs, hovered rows
overlay="2a303b"    # borders, separators, inactive outlines

# Text
fg="dde3ec"         # primary text
fg_dim="9aa4b4"     # secondary text
muted="5d6676"      # disabled / hints

# Accent (one cool accent, plus a deeper shade for gradients)
accent="6ec8f2"     # focus, active workspace, selection
accent_alt="3b8bb5" # gradient partner / pressed state

# Status
urgent="e5646e"     # errors, critical, urgent workspace
warning="e8b75c"    # warnings, low battery
success="7fcf9c"    # charging, connected

# Terminal-only extras (ANSI magenta/cyan in kitty; not used by the UI)
ansi_magenta="b39cf0"
ansi_cyan="6fd6c8"

# Typography
font_ui="Inter"
font_mono="JetBrainsMono Nerd Font"
font_size="11"            # base UI size in pt

# Shape & spacing (logical px)
radius="10"
border="2"
gaps_in="4"
gaps_out="10"

# Desktop look (names of installed themes)
gtk_theme="adw-gtk3-dark"
icon_theme="Papirus-Dark"
cursor_theme="Adwaita"
cursor_size="24"

# Wallpaper: path relative to the repo root, or absolute
wallpaper="assets/wallpapers/default.png"
