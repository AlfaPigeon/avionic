#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  hypr-dots installer · Arch Linux + Hyprland desktop
#
#  One line:
#    curl -fsSL https://raw.githubusercontent.com/AlfaPigeon/<repo>/main/install.sh | bash
#  With options:
#    curl -fsSL …/install.sh | bash -s -- --sddm --shell fish
#
#  Options:
#    --no-packages      skip pacman/AUR, only link configs and apply the theme
#    --sddm             install and enable the SDDM display manager
#    --wlogout          also install wlogout (AUR) as the power menu
#    --shell fish|zsh   install that shell and make it your login shell
#    --dry-run          print every action without changing anything
#    -y, --yes          don't ask; accept the defaults
#    -h, --help         show this help
#
#  Safe to re-run: it updates the repo, re-links, and only backs up files it
#  has not linked before.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

# ── Project settings (rename here when the final name is decided) ───────────
NAME="hypr-dots"
REPO_URL="${DOTS_REPO_URL:-https://github.com/AlfaPigeon/hypr-dots.git}"
BRANCH="${DOTS_BRANCH:-main}"

DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/$NAME"
BACKUP_ROOT="$STATE_DIR/backups"

# ── Packages (all from the official repos) ──────────────────────────────────
PKGS_HYPR=(hyprland hyprlock hypridle hyprpaper hyprpicker hyprpolkitagent
           hyprland-guiutils hyprland-qt-support
           xdg-desktop-portal-hyprland xdg-desktop-portal-gtk)
PKGS_SHELL=(waybar rofi swaync swayosd libnotify)
PKGS_APPS=(kitty thunar thunar-volman thunar-archive-plugin tumbler gvfs file-roller
           pavucontrol btop)
PKGS_TOOLS=(grim slurp swappy wl-clipboard cliphist jq playerctl brightnessctl
            xdg-user-dirs xdg-utils polkit git)
PKGS_AUDIO=(pipewire pipewire-pulse pipewire-alsa wireplumber)
PKGS_NET=(networkmanager network-manager-applet bluez bluez-utils blueman)
PKGS_THEME=(qt5-wayland qt6-wayland qt6ct nwg-look adw-gtk-theme papirus-icon-theme
            adwaita-cursors ttf-jetbrains-mono-nerd inter-font noto-fonts noto-fonts-emoji)
# AUR packages, only when a flag asks for them (none are needed by default).
AUR_PKGS=()

# ── Defaults ────────────────────────────────────────────────────────────────
DO_PACKAGES=1
DO_SDDM=0
DO_WLOGOUT=0
LOGIN_SHELL=""
DRY_RUN=0
ASSUME_YES=0
DOTS_DIR=""
BACKUP_DIR=""
TTY_OK=0

# ── Output helpers ──────────────────────────────────────────────────────────
if [[ -t 1 ]]; then
    C_RESET=$'\033[0m' C_BOLD=$'\033[1m' C_DIM=$'\033[2m'
    C_ACC=$'\033[38;5;117m' C_OK=$'\033[32m' C_WARN=$'\033[33m' C_ERR=$'\033[31m'
else
    C_RESET="" C_BOLD="" C_DIM="" C_ACC="" C_OK="" C_WARN="" C_ERR=""
fi
step() { printf '\n%s==>%s %s%s%s\n' "$C_ACC" "$C_RESET" "$C_BOLD" "$*" "$C_RESET"; }
info() { printf '    %s\n' "$*"; }
ok()   { printf '    %s✓%s %s\n' "$C_OK" "$C_RESET" "$*"; }
warn() { printf '    %s!%s %s\n' "$C_WARN" "$C_RESET" "$*" >&2; }
die()  { printf '\n%serror:%s %s\n' "$C_ERR" "$C_RESET" "$*" >&2; exit 1; }

usage() {
    cat <<USAGE
Usage: install.sh [options]      (or: curl -fsSL …/install.sh | bash -s -- [options])

  --no-packages      skip pacman/AUR, only link configs and apply the theme
  --sddm             install and enable the SDDM display manager
  --wlogout          also install wlogout (AUR) as the power menu
  --shell fish|zsh   install that shell and make it your login shell
  --dry-run          print every action without changing anything
  -y, --yes          don't ask; accept the defaults
  -h, --help         show this help

Environment: DOTS_REPO_URL, DOTS_BRANCH (to install from a fork or branch).
USAGE
}

# Run a command, or just print it in --dry-run mode.
run() {
    if ((DRY_RUN)); then
        printf '    %s[dry-run]%s %s\n' "$C_DIM" "$C_RESET" "$*"
        return 0
    fi
    "$@"
}

# Ask a yes/no question on the terminal, even under `curl | bash`.
# ask "Question" y|n   → returns 0 for yes. Without a terminal, uses the default.
ask() {
    local question="$1" default="${2:-y}" reply hint="[Y/n]"
    [[ "$default" == n ]] && hint="[y/N]"
    if ((ASSUME_YES)) || ((!TTY_OK)); then
        [[ "$default" == y ]]; return
    fi
    printf '    %s?%s %s %s ' "$C_ACC" "$C_RESET" "$question" "$hint" >/dev/tty
    read -r reply </dev/tty || reply=""
    reply="${reply:-$default}"
    [[ "${reply,,}" == y* ]]
}

# Commands that may prompt get the real terminal; otherwise no stdin at all,
# so nothing can swallow the rest of a piped script.
interactive() {
    if ((TTY_OK)) && ((!ASSUME_YES)); then run "$@" </dev/tty; else run "$@" </dev/null; fi
}

# ── Steps ───────────────────────────────────────────────────────────────────
parse_args() {
    while (($#)); do
        case "$1" in
            --no-packages) DO_PACKAGES=0 ;;
            --sddm)        DO_SDDM=1 ;;
            --wlogout)     DO_WLOGOUT=1 ;;
            --shell)       LOGIN_SHELL="${2:-}"; shift ;;
            --shell=*)     LOGIN_SHELL="${1#*=}" ;;
            --dry-run)     DRY_RUN=1 ;;
            -y|--yes)      ASSUME_YES=1 ;;
            -h|--help)     usage; exit 0 ;;
            *)             die "unknown option: $1 (try --help)" ;;
        esac
        shift
    done
    case "$LOGIN_SHELL" in ""|fish|zsh) ;; *) die "--shell must be 'fish' or 'zsh'" ;; esac
}

preflight() {
    step "Checking the system"
    ((EUID != 0)) || die "run this as your normal user, not root (it uses sudo when needed)"
    command -v pacman >/dev/null 2>&1 || die "pacman not found: this installer is for Arch Linux"
    [[ -f /etc/arch-release ]] || warn "/etc/arch-release missing: an Arch derivative? continuing"
    command -v sudo >/dev/null 2>&1 || ((!DO_PACKAGES)) || die "sudo is required to install packages"
    if { : </dev/tty; } 2>/dev/null; then TTY_OK=1; fi

    # Use the checkout this script lives in, if run from one (handy for testing);
    # otherwise the standard location.
    local self="${BASH_SOURCE[0]:-}" here
    if [[ -n "$self" && -f "$self" ]]; then
        here="$(cd "$(dirname "$self")" && pwd)"
        [[ -f "$here/theme/palette.sh" && -f "$here/scripts/links.conf" ]] && DOTS_DIR="$here"
    fi
    DOTS_DIR="${DOTS_DIR:-$DATA_HOME/$NAME}"

    if ((DO_WLOGOUT)); then AUR_PKGS+=(wlogout); fi
    if [[ -n "$LOGIN_SHELL" ]]; then PKGS_TOOLS+=("$LOGIN_SHELL"); fi
    if ((DO_SDDM)); then PKGS_TOOLS+=(sddm); fi

    # pipewire-pulse replaces pulseaudio; let pacman ask instead of failing silently.
    if pacman -Qq pulseaudio >/dev/null 2>&1; then
        warn "pulseaudio is installed: pacman will offer to replace it with pipewire-pulse"
    fi
    ok "Arch Linux, user $(id -un)"
}

show_plan() {
    step "Plan"
    local n=0
    item() { n=$((n + 1)); info "$n. $*"; }
    if ((DO_PACKAGES)); then
        item "Install/upgrade packages with pacman (--needed)"
        ((${#AUR_PKGS[@]} == 0)) || info "   + AUR: ${AUR_PKGS[*]} (bootstraps yay if no AUR helper)"
    else
        item "Skip packages (--no-packages)"
    fi
    item "Get the dotfiles in $DOTS_DIR"
    item "Render the theme (scripts/apply-theme.sh)"
    item "Back up existing configs to $BACKUP_ROOT/<timestamp>/ and symlink ours"
    item "Enable PipeWire (user) and NetworkManager + Bluetooth (system)"
    ((!DO_SDDM)) || item "Enable SDDM (takes effect on next boot)"
    [[ -z "$LOGIN_SHELL" ]] || item "Change your login shell to $LOGIN_SHELL"
    ((!DRY_RUN)) || info "${C_WARN}dry run: nothing will be changed${C_RESET}"
    ask "Continue?" y || die "cancelled"
}

install_packages() {
    ((DO_PACKAGES)) || return 0
    step "Installing packages"
    local pkgs=("${PKGS_HYPR[@]}" "${PKGS_SHELL[@]}" "${PKGS_APPS[@]}" "${PKGS_TOOLS[@]}"
                "${PKGS_AUDIO[@]}" "${PKGS_NET[@]}" "${PKGS_THEME[@]}")
    local flags=(-Syu --needed)
    if ((ASSUME_YES)) || ((!TTY_OK)); then flags+=(--noconfirm); fi
    info "${#pkgs[@]} packages; already-installed ones are skipped"
    interactive sudo pacman "${flags[@]}" "${pkgs[@]}"
    ok "pacman packages ready"
    install_aur
}

aur_helper() {
    local h
    for h in paru yay; do command -v "$h" >/dev/null 2>&1 && { echo "$h"; return 0; }; done
    return 1
}

install_aur() {
    ((${#AUR_PKGS[@]} > 0)) || return 0
    local helper
    if ! helper="$(aur_helper)"; then
        step "Bootstrapping yay (AUR helper)"
        interactive sudo pacman -S --needed --noconfirm base-devel git
        local tmp
        tmp="$(mktemp -d)"
        run git clone --depth 1 https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
        if ((DRY_RUN)); then
            info "[dry-run] (cd $tmp/yay-bin && makepkg -si --noconfirm)"
        else
            (cd "$tmp/yay-bin" && makepkg -si --noconfirm </dev/null)
        fi
        rm -rf "$tmp"
        helper="yay"
    fi
    step "Installing AUR packages with $helper"
    interactive "$helper" -S --needed --noconfirm "${AUR_PKGS[@]}"
    ok "AUR: ${AUR_PKGS[*]}"
}

sync_repo() {
    step "Getting the dotfiles"
    if [[ "$DOTS_DIR" != "$DATA_HOME/$NAME" && -f "$DOTS_DIR/scripts/links.conf" ]]; then
        ok "using this checkout: $DOTS_DIR"
        return 0
    fi
    command -v git >/dev/null 2>&1 || ((DRY_RUN)) || die "git is required (install it or drop --no-packages)"
    if [[ -d "$DOTS_DIR/.git" ]]; then
        if [[ -n "$(git -C "$DOTS_DIR" status --porcelain --untracked-files=no)" ]]; then
            warn "local changes in $DOTS_DIR: not pulling (commit or stash them to update)"
        else
            run git -C "$DOTS_DIR" pull --ff-only --quiet </dev/null
            ok "updated $DOTS_DIR"
        fi
    elif [[ -e "$DOTS_DIR" ]]; then
        die "$DOTS_DIR exists but is not a git checkout; move it away and re-run"
    else
        run mkdir -p "$(dirname "$DOTS_DIR")"
        run git clone --quiet --branch "$BRANCH" "$REPO_URL" "$DOTS_DIR" </dev/null
        ok "cloned into $DOTS_DIR"
    fi
}

render_theme() {
    step "Rendering the theme"
    if [[ ! -x "$DOTS_DIR/scripts/apply-theme.sh" ]]; then
        ((DRY_RUN)) && { info "[dry-run] scripts/apply-theme.sh"; return 0; }
        die "missing $DOTS_DIR/scripts/apply-theme.sh"
    fi
    if ((DRY_RUN)); then
        run "$DOTS_DIR/scripts/apply-theme.sh"
        "$DOTS_DIR/scripts/apply-theme.sh" --check | sed 's/^/    /'
    else
        "$DOTS_DIR/scripts/apply-theme.sh" | sed 's/^/    /'
    fi
}

# Move an existing target into this run's backup folder (created on first use).
backup() {
    local target="$1" rel="${1#"$HOME"/}"
    if [[ -z "$BACKUP_DIR" ]]; then
        BACKUP_DIR="$BACKUP_ROOT/$(date +%Y%m%d-%H%M%S)"
        run mkdir -p "$BACKUP_DIR"
    fi
    run mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
    run mv "$target" "$BACKUP_DIR/$rel"
    if ((!DRY_RUN)); then printf '%s\n' "$rel" >>"$BACKUP_DIR/manifest"; fi
    info "backed up ~/$rel"
}

link_configs() {
    step "Linking configs"
    local manifest="$DOTS_DIR/scripts/links.conf" src dst when linked=0
    if [[ ! -f "$manifest" ]]; then
        ((DRY_RUN)) && { info "[dry-run] would link everything listed in scripts/links.conf"; return 0; }
        die "missing $manifest"
    fi
    while read -r src dst when; do
        [[ -z "$src" || "$src" == \#* ]] && continue
        case "$when" in
            always) ;;
            wlogout) ((DO_WLOGOUT)) || continue ;;
            fish) [[ "$LOGIN_SHELL" == fish ]] || continue ;;
            *) warn "links.conf: unknown condition '$when' for $src"; continue ;;
        esac
        src="$DOTS_DIR/$src"
        dst="$HOME/$dst"
        if [[ ! -e "$src" ]]; then
            ((DRY_RUN)) || warn "missing ${src#"$DOTS_DIR"/} (theme not rendered?), skipped"
            continue
        fi
        if [[ -L "$dst" && "$(readlink -f "$dst")" == "$(readlink -f "$src")" ]]; then
            continue                                   # already ours
        fi
        if [[ -e "$dst" || -L "$dst" ]]; then backup "$dst"; fi
        run mkdir -p "$(dirname "$dst")"
        run ln -sfn "$src" "$dst"
        linked=$((linked + 1))
    done <"$manifest"
    ok "$linked new link(s); everything else was already in place"
    [[ -z "$BACKUP_DIR" ]] || ok "previous configs saved in $BACKUP_DIR"
}

enable_services() {
    step "Enabling services"
    if systemctl --user show-environment >/dev/null 2>&1; then
        if run systemctl --user enable --now pipewire.socket pipewire-pulse.socket wireplumber.service; then
            ok "PipeWire + WirePlumber (user)"
        else
            warn "could not enable PipeWire user units"
        fi
    else
        warn "no systemd user session here; PipeWire starts via socket activation on next login"
    fi

    # Don't fight another network manager that is already running.
    local other="" unit
    for unit in systemd-networkd dhcpcd connman netctl; do
        systemctl is-active --quiet "$unit" 2>/dev/null && other="$unit"
    done
    if [[ -n "$other" ]] && ! systemctl is-enabled --quiet NetworkManager 2>/dev/null; then
        warn "$other is active: leaving NetworkManager disabled (enable it yourself if you switch)"
    else
        if run sudo systemctl enable --now NetworkManager.service; then
            ok "NetworkManager"
        else
            warn "could not enable NetworkManager"
        fi
    fi
    if run sudo systemctl enable --now bluetooth.service; then
        ok "Bluetooth"
    else
        warn "bluetooth.service could not start (no adapter?)"
    fi
}

setup_sddm() {
    ((DO_SDDM)) || return 0
    step "Display manager"
    local link=/etc/systemd/system/display-manager.service current=""
    if [[ -L "$link" || -e "$link" ]]; then current="$(readlink -f "$link")"; fi
    if [[ -n "$current" && "$current" != */sddm.service ]]; then
        warn "another display manager is enabled ($(basename "$current")): not switching"
        info "to switch: sudo systemctl disable $(basename "$current") && sudo systemctl enable sddm"
        return 0
    fi
    if run sudo systemctl enable sddm.service; then
        ok "SDDM enabled; pick 'Hyprland' at the login screen"
    else
        warn "could not enable sddm.service"
    fi
}

setup_shell() {
    [[ -n "$LOGIN_SHELL" ]] || return 0
    step "Login shell"
    local path
    path="$(command -v "$LOGIN_SHELL" || echo "/usr/bin/$LOGIN_SHELL")"
    if [[ "$(getent passwd "$(id -un)" | cut -d: -f7)" == "$path" ]]; then
        ok "already using $LOGIN_SHELL"
    else
        if interactive chsh -s "$path"; then
            ok "login shell is now $path (applies at next login)"
        else
            warn "chsh failed; run 'chsh -s $path' yourself"
        fi
    fi
}

finish() {
    step "Finishing touches"
    if command -v xdg-user-dirs-update >/dev/null 2>&1; then run xdg-user-dirs-update; fi
    run mkdir -p "$(xdg-user-dir PICTURES 2>/dev/null || echo "$HOME/Pictures")/Screenshots"
    if ((DRY_RUN)); then
        printf '\n%sDry run complete: nothing was changed.%s\n' "$C_BOLD" "$C_RESET"
        return 0
    fi
    printf '\n%s%s is installed.%s\n' "$C_BOLD" "$NAME" "$C_RESET"
    info "Start Hyprland: log out and choose Hyprland in SDDM, or type 'start-hyprland' on a TTY."
    info "Keybinds: SUPER + F1   ·   Theme: $DOTS_DIR/theme/palette.sh"
    info "Machine-specific settings: ~/.config/hypr/user.lua"
    info "Undo: $DOTS_DIR/uninstall.sh"
}

main() {
    parse_args "$@"
    printf '%s%s%s · Arch Linux + Hyprland desktop\n' "$C_BOLD" "$NAME" "$C_RESET"
    preflight
    show_plan
    install_packages
    sync_repo
    render_theme
    link_configs
    enable_services
    setup_sddm
    setup_shell
    finish
}

# Everything runs from main() so `curl | bash` reads the whole file before acting.
main "$@"
