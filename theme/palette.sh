# shellcheck shell=bash
# shellcheck disable=SC2034  # variables are read by scripts/apply-theme.sh
# ─────────────────────────────────────────────────────────────────────────────
#  AVIONIC — the single source of truth for every color, font and size.
#
#  Cockpit instrument panel: dark graphite, thin rules, one amber readout.
#  Amber (accent) appears only on the active workspace and the focused
#  window border. Everything else stays quiet. After editing, run:
#      scripts/apply-theme.sh --reload
#
#  Colors are 6-digit hex WITHOUT '#'. Templates can use each color as:
#    {{bg}}      -> #0c0e11        (CSS, rasi, kitty, qt)
#    {{bg.hex}}  -> 0c0e11         (Hyprland / hyprlang: rgb({{bg.hex}}))
#    {{bg.rgb}}  -> 12, 14, 17     (CSS rgba({{bg.rgb}}, 0.8))
# ─────────────────────────────────────────────────────────────────────────────

theme_name="Avionic"

# Base layers (darkest -> lightest)
bg="0c0e11"         # background: desktop, lock screen
bg_alt="101317"     # bar and panels (between background and surface)
surface="15191e"    # surface: menus, cards, inputs, hovered rows
overlay="232a31"    # border: every rule and outline, inactive window border

# Text
fg="e8e4da"         # text
fg_dim="b1b4b4"     # secondary text (between text and muted)
muted="7a848f"      # muted: labels, hints, disabled

# Accent
accent="ffb347"     # amber, the one hot color: active workspace + focused border only
accent_alt="7fb7d9" # info: cool secondary, used sparingly (links, auth check)

# Status (warning and urgent share one red)
urgent="f25c54"     # urgent workspace, critical notifications, failed auth
warning="f25c54"    # low battery, caps lock
success="8a9f8c"    # quiet sage: charging, connected (not a hot color)

# Terminal-only ANSI tones, kept muted to sit with the panel
ansi_yellow="c9a46c"  # ochre, quieter than the amber accent
ansi_magenta="a594b5" # dusty violet
ansi_cyan="7fa9a8"    # grey teal

# Typography (fontconfig family names)
font_ui="IBM Plex Sans"               # ttf-ibm-plex
font_mono="JetBrainsMono Nerd Font"   # ttf-jetbrains-mono-nerd: bar, terminal, readouts
font_size="11"                        # base UI size in pt

# Shape & spacing (logical px)
radius="0"          # square everywhere
border="1"          # 1px rules
gaps_in="4"
gaps_out="8"

# Desktop look (names of installed themes)
gtk_theme="adw-gtk3-dark"
icon_theme="Papirus-Dark"
cursor_theme="Adwaita"
cursor_size="24"

# Wallpaper: path relative to the repo root, or absolute
wallpaper="assets/wallpapers/avionic.png"
