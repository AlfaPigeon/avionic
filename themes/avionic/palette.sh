# shellcheck shell=bash
# shellcheck disable=SC2034  # variables are read by scripts/apply-theme.sh
# ─────────────────────────────────────────────────────────────────────────────
#  AVIONIC — every color, font and size of the Avionic theme.
#
#  Cockpit instrument panel: dark graphite, thin rules, one amber readout.
#  Amber (accent) appears only on the active workspace and the focused
#  window border. Everything else stays quiet. After editing, run:
#      scripts/theme.sh avionic        (or scripts/apply-theme.sh --reload)
#
#  Colors are 6-digit hex WITHOUT '#'. Templates can use each color as:
#    {{bg}}      -> #0c0e11        (CSS, rasi, kitty, qt)
#    {{bg.hex}}  -> 0c0e11         (Hyprland / hyprlang: rgb({{bg.hex}}))
#    {{bg.rgb}}  -> 12, 14, 17     (CSS rgba({{bg.rgb}}, 0.8))
# ─────────────────────────────────────────────────────────────────────────────

theme_name="Avionic"
bar="avionic"       # Quickshell bar layout: config/quickshell/themes/<bar>/Bar.qml

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
danger="f25c54"     # destructive actions (shutdown button hover)

# Data ramp, low to high (graphite). Avionic's bar doesn't use it.
ramp_0="232a31"
ramp_1="3b434c"
ramp_2="5a646e"
ramp_3="7a848f"
ramp_4="b1b4b4"
ramp_5="e8e4da"

# Terminal 16-color ANSI palette, kept muted to sit with the panel
ansi_0="15191e"     # black (surface)
ansi_1="f25c54"     # red
ansi_2="8a9f8c"     # green (sage)
ansi_3="c9a46c"     # yellow: ochre, quieter than the amber accent
ansi_4="7fb7d9"     # blue
ansi_5="a594b5"     # magenta: dusty violet
ansi_6="7fa9a8"     # cyan: grey teal
ansi_7="b1b4b4"     # white
ansi_8="7a848f"     # bright black
ansi_9="f25c54"
ansi_10="8a9f8c"
ansi_11="c9a46c"
ansi_12="7fb7d9"
ansi_13="a594b5"
ansi_14="7fa9a8"
ansi_15="e8e4da"

# Typography (fontconfig family names)
font_ui="IBM Plex Sans"               # ttf-ibm-plex
font_mono="JetBrainsMono Nerd Font"   # ttf-jetbrains-mono-nerd: bar, readouts
font_term="JetBrainsMono Nerd Font"   # kitty
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

# Lock screen date line (shell command run by hyprlock)
lock_date="date +\"%a %d %b %Y\" | tr '[:lower:]' '[:upper:]'"

# Wallpaper: path relative to this file, or absolute
wallpaper="wallpaper.png"
