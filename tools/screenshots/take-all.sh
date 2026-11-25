#!/bin/bash
# Retakes every README screenshot and GIF (docs/images/) by driving the
# examples with shoot.sh. Positions are points relative to each example's
# window, which launch places at a fixed spot; retune them when an example's
# layout changes.
#
# Usage: tools/screenshots/take-all.sh [window|dialogs|settings ...]
#        (no argument: all of them)
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/../.." && pwd)
D="$ROOT/tools/screenshots/shoot.sh"
OUT="$ROOT/docs/images"
export RASK_SHOTS_DIR=${RASK_SHOTS_DIR:-/tmp/rask-shots}
SHOTS=$RASK_SHOTS_DIR/shots
mkdir -p "$OUT"

# The current window's top-left, set by start().
WX=0
WY=0

pause() { osascript -e "delay $1"; }

# Each example's settings domain (QSettings: organization domain + app name),
# whose appearance choice the scenes change and restore.
domain_of() {
    case $1 in
    window) echo "com.com-github-rask-project.Rask Window Example" ;;
    dialogs) echo "com.com-github-rask-project.Rask Dialogs" ;;
    settings) echo "com.com-github-rask-project.Rask Settings" ;;
    esac
}

SAVED_DOMAIN=""
SAVED_SCHEME=""

restore_appearance() {
    [[ -n $SAVED_DOMAIN ]] || return 0
    if [[ -n $SAVED_SCHEME ]]; then
        defaults write "$SAVED_DOMAIN" appearance.colorScheme -int "$SAVED_SCHEME"
    else
        defaults delete "$SAVED_DOMAIN" appearance.colorScheme 2>/dev/null || true
    fi
    SAVED_DOMAIN=""
}

start() {
    SAVED_DOMAIN=$(domain_of "$1")
    SAVED_SCHEME=$(defaults read "$SAVED_DOMAIN" appearance.colorScheme 2>/dev/null || true)
    "$D" launch "$1" "$2" "$3" "$4" "$5"
    WX=$2
    WY=$3
    # Park the pointer outside the window.
    "$D" move $((WX - 20)) $((WY - 20))
}

click() {
    "$D" click $((WX + $1)) $((WY + $2))
    pause "${3:-0.7}"
}

drag() {
    "$D" drag $((WX + $1)) $((WY + $2)) $((WX + $3)) $((WY + $4)) 80
    pause 0.5
}

shot() {
    "$D" shot "$1" >/dev/null
    "$D" png "$SHOTS/$1.png" "$OUT/$1.png" 1200 >/dev/null
    echo "$OUT/$1.png"
}

record() {
    "$D" record "$1" >/dev/null
    pause 0.6
}

gif() {
    "$D" record-stop
    "$D" gif "$SHOTS/$1.mov" "$OUT/$1.gif" >/dev/null
    echo "$OUT/$1.gif"
}

# --- Rask.Window ---------------------------------------------------------

# Appearance ComboBox and its list (the list opens below it).
combo() {
    click 367 92 0.6
    case $1 in
    system) click 360 121 ;;
    light) click 355 148 ;;
    dark) click 355 175 ;;
    esac
}

scene_window() {
    start window 300 150 640 460
    combo dark
    shot window-dark
    combo light
    shot window-light
    combo dark

    record window
    combo light
    pause 0.8
    click 357 188 1.0 # glass bar off
    click 357 188 1.0 # and on
    click 357 138 1.0 # blur off
    click 357 138 1.0 # and on
    drag 379 230 330 230
    drag 330 230 405 230
    pause 0.4
    combo dark
    pause 1.5
    gif window
    "$D" stop
    restore_appearance
}

# --- Rask.Dialogs --------------------------------------------------------

# Near the ComboBox's right edge, which stays put whatever its text.
dialogs_combo() {
    click 420 108 0.7
    case $1 in
    system) click 400 137 ;;
    light) click 400 164 ;;
    dark) click 400 191 ;;
    esac
}

# A PNG of all the example's windows (main window with a panel or alert).
shot_all() {
    "$D" shot-all "$1" >/dev/null
    "$D" png "$SHOTS/$1.png" "$OUT/$1.png" 1200 >/dev/null
    echo "$OUT/$1.png"
}

# Closes the About panel (the front window) with its close button.
close_front() {
    local x y
    read -r x y <<<"$("$D" windows | awk 'NR == 1 { print $2, $3 }')"
    "$D" click $((x + 16)) $((y + 16))
    pause 0.6
}

scene_dialogs() {
    start dialogs 380 140 520 400
    for theme in dark light; do
        dialogs_combo $theme
        click 260 240 1.0 # Save Changes? (sheet)
        shot_all "dialogs-sheet-$theme"
        click 260 298 # Cancel
        click 260 152 1.2 # About…
        shot_all "dialogs-about-$theme"
        close_front
        click 260 196 1.2 # About Qt…
        shot_all "dialogs-about-qt-$theme"
        "$D" key return
        pause 0.6
        click 260 284 1.0 # App-modal Alert
        shot_all "dialogs-alert-$theme"
        "$D" key return
        pause 0.6
    done

    dialogs_combo dark
    "$D" record-rect dialogs 340 95 880 600 >/dev/null
    pause 0.8
    click 260 240 1.4 # the sheet
    click 260 264 1.4 # Don't Save: the result shows below
    click 260 152 1.6 # About…
    close_front
    click 260 196 1.8 # About Qt…
    "$D" key return
    pause 0.6
    dialogs_combo light
    pause 0.6
    click 260 240 1.4 # the sheet, light
    click 260 298 1.2 # Cancel
    click 260 284 1.4 # App-modal Alert
    "$D" key return
    pause 1.0
    gif dialogs
    "$D" stop
    restore_appearance
}

# --- Rask.Controls (settings) ----------------------------------------------

section() {
    case $1 in
    appearance) click 80 74 "${2:-0.7}" ;;
    window) click 80 106 "${2:-0.7}" ;;
    keyboard) click 80 138 "${2:-0.7}" ;;
    security) click 80 170 "${2:-0.7}" ;;
    updates) click 80 202 "${2:-0.7}" ;;
    esac
}

settings_theme() {
    section appearance
    click 608 92 0.7
    case $1 in
    system) click 575 121 ;;
    light) click 568 148 ;;
    dark) click 566 175 ;;
    esac
}

scene_settings() {
    start settings 280 140 720 480
    for theme in dark light; do
        settings_theme $theme
        shot "settings-appearance-$theme"
        section window
        shot "settings-window-$theme"
        section keyboard
        shot "settings-keyboard-$theme"
        section security
        click 450 128 # select the second row
        shot "settings-security-$theme"
        click 450 88
        section updates
        shot "settings-updates-$theme"
    done

    settings_theme dark
    record settings
    section window 1.0
    click 647 95 1.0 # blur off
    click 647 95 1.0 # and on
    drag 650 141 540 141
    drag 540 141 640 141
    section keyboard 1.0
    section security 0.8
    click 450 128 0.8
    click 450 168 0.8
    click 450 88 0.8
    section updates 1.0
    settings_theme light
    pause 0.8
    section window 0.9
    section security 0.9
    section updates 0.9
    section appearance 1.2
    gif settings
    "$D" stop
    restore_appearance
}

# --- run -------------------------------------------------------------------

"$D" setup >/dev/null
"$D" backdrop on
trap '"$D" stop; restore_appearance' EXIT
scenes=("$@")
[[ ${#scenes[@]} -gt 0 ]] || scenes=(window dialogs settings)
for scene in "${scenes[@]}"; do
    "scene_$scene"
done
