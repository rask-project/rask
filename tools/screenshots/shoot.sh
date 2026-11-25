#!/bin/bash
# Takes the README screenshots and GIFs of the examples (docs/images/).
#
# Usage: tools/screenshots/shoot.sh COMMAND [ARGS...]
#
#   setup                     compile the Swift helpers (ctl, backdrop)
#   backdrop on [light] | off full-screen background behind the examples:
#                             colour blobs, so blur and glass show and nothing
#                             else on your desktop does
#   launch EXAMPLE [X Y W H]  start an example (window, dialogs, settings) at a
#                             position on the main display (default 300,150)
#   front                     bring the running example forward
#   windows                   its on-screen windows: "ID X Y W H LAYER TITLE"
#   click X Y [COUNT] | drag X1 Y1 X2 Y2 | move X Y
#                             mouse input (needs Accessibility)
#   key KEY [MODIFIERS]       a key press: return, escape, tab, or a letter;
#                             MODIFIERS like "command,shift" (needs Accessibility)
#   shot NAME [MARGIN]        PNG of the example's front window (main window,
#                             sheet, panel or alert) plus a margin
#   shot-all NAME [MARGIN]    PNG of all its windows together plus a margin
#   shot-rect NAME X Y W H    PNG of a rectangle
#   record NAME [MARGIN]      start recording the front window plus a margin
#                             (ffmpeg, in the background)
#   record-rect NAME X Y W H  start recording a rectangle
#   record-stop               stop it and finish the file
#   gif IN.mov OUT.gif [START DURATION [WIDTH]]   12 fps palette GIF
#   png IN.png OUT.png [MAX_WIDTH]              optimized PNG (256 colours)
#   stop                      quit the example and the backdrop
#
# Coordinates are points, (0,0) at the top-left of the display with the menu
# bar. Raw shots go to $RASK_SHOTS_DIR (default /tmp/rask-shots).
#
# Needs: the examples built (build/Qt_6_12_0_for_macOS_Debug, or $RASK_BUILD),
# Xcode command-line tools, ffmpeg, and for the terminal running it Screen
# Recording (captures) and Accessibility (clicks) in System Settings ▸
# Privacy & Security.
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/../.." && pwd)
BUILD=${RASK_BUILD:-$ROOT/build/Qt_6_12_0_for_macOS_Debug}
DIR=${RASK_SHOTS_DIR:-/tmp/rask-shots}
BIN=$DIR/bin
mkdir -p "$DIR/shots"

die() {
    echo "shoot.sh: $*" >&2
    exit 1
}

pid_of() { [[ -f $DIR/$1.pid ]] && cat "$DIR/$1.pid"; }

app_pid() {
    local pid
    pid=$(pid_of app || true)
    [[ -n $pid ]] && kill -0 "$pid" 2>/dev/null || die "no example running (launch one)"
    echo "$pid"
}

ctl() {
    [[ -x $BIN/ctl ]] || die "run setup first"
    "$BIN/ctl" "$@"
}

out_path() {
    if [[ $1 == */* ]]; then echo "$1"; else echo "$DIR/shots/$1.$2"; fi
}

# X Y W H of the example's front window (any level: sheets, panels and
# alerts float above the main window).
front_bounds() {
    ctl windows "$(app_pid)" | awk '$4 > 40 && $5 > 40 { print $2, $3, $4, $5; exit }'
}

# X Y W H of the box around all its windows.
all_bounds() {
    ctl windows "$(app_pid)" | awk '$4 > 40 && $5 > 40 {
        if (!n++ || $2 < x0) x0 = $2; if (n == 1 || $3 < y0) y0 = $3
        if ($2 + $4 > x1) x1 = $2 + $4; if ($3 + $5 > y1) y1 = $3 + $5
    } END { if (n) print x0, y0, x1 - x0, y1 - y0 }'
}

cmd_setup() {
    mkdir -p "$BIN"
    swiftc -O -o "$BIN/ctl" "$ROOT/tools/screenshots/ctl.swift"
    swiftc -O -o "$BIN/backdrop" "$ROOT/tools/screenshots/backdrop.swift"
    echo "helpers in $BIN"
}

stop_pid() {
    local pid
    pid=$(pid_of "$1" || true)
    [[ -n $pid ]] && kill "$pid" 2>/dev/null || true
    rm -f "$DIR/$1.pid"
}

cmd_backdrop() {
    stop_pid backdrop
    [[ ${1:-on} == off ]] && return
    [[ -x $BIN/backdrop ]] || die "run setup first"
    nohup "$BIN/backdrop" ${2:-} >/dev/null 2>&1 &
    echo $! >"$DIR/backdrop.pid"
    sleep 0.5
}

cmd_launch() {
    [[ $# -eq 1 || $# -eq 5 ]] || die "usage: launch EXAMPLE [X Y W H]"
    local name
    case $1 in
    window) name="Rask Window" ;;
    dialogs) name="Rask Dialogs" ;;
    settings) name="Rask Settings" ;;
    *) die "unknown example: $1" ;;
    esac
    local app="$BUILD/examples/$1/$name.app/Contents/MacOS/$name"
    [[ -x $app ]] || die "not built: $app"
    stop_pid app
    local geometry=()
    # Qt places the first window from -qwindowgeometry: no Accessibility needed.
    [[ $# -eq 5 ]] && geometry=(-qwindowgeometry "${4}x${5}+${2}+${3}")
    [[ $# -eq 1 ]] && geometry=(-qwindowgeometry "+300+150")
    nohup "$app" "${geometry[@]}" >"$DIR/app.log" 2>&1 &
    echo $! >"$DIR/app.pid"
    sleep 2.5
    cmd_front
    sleep 0.8
}

cmd_front() {
    osascript -e "tell application \"System Events\" to set frontmost of (first process whose unix id is $(app_pid)) to true" >/dev/null
}

cmd_shot_rect() {
    [[ $# -eq 5 ]] || die "usage: shot-rect NAME X Y W H"
    local out
    out=$(out_path "$1" png)
    screencapture -x -R "$2,$3,$4,$5" "$out"
    echo "$out"
}

cmd_shot() {
    [[ $# -ge 1 ]] || die "usage: shot NAME [MARGIN]"
    local margin=${2:-28} x y w h
    read -r x y w h <<<"$(front_bounds)"
    [[ -n ${h:-} ]] || die "no window to capture"
    cmd_shot_rect "$1" $((x - margin)) $((y - margin)) $((w + 2 * margin)) $((h + 2 * margin))
}

cmd_shot_all() {
    [[ $# -ge 1 ]] || die "usage: shot-all NAME [MARGIN]"
    local margin=${2:-28} x y w h
    read -r x y w h <<<"$(all_bounds)"
    [[ -n ${h:-} ]] || die "no window to capture"
    cmd_shot_rect "$1" $((x - margin)) $((y - margin)) $((w + 2 * margin)) $((h + 2 * margin))
}

cmd_key() {
    [[ $# -ge 1 ]] || die "usage: key KEY [MODIFIERS]"
    local press
    case $1 in
    return) press="key code 36" ;;
    escape) press="key code 53" ;;
    tab) press="key code 48" ;;
    *) press="keystroke \"$1\"" ;;
    esac
    if [[ -n ${2:-} ]]; then
        press+=" using {$(sed -E 's/([a-z]+)/\1 down/g' <<<"$2")}"
    fi
    osascript -e "tell application \"System Events\" to $press" >/dev/null
}

cmd_record() {
    [[ $# -ge 1 ]] || die "usage: record NAME [MARGIN]"
    local margin=${2:-28} x y w h
    read -r x y w h <<<"$(front_bounds)"
    cmd_record_rect "$1" $((x - margin)) $((y - margin)) $((w + 2 * margin)) $((h + 2 * margin))
}

cmd_record_rect() {
    [[ $# -eq 5 ]] || die "usage: record-rect NAME X Y W H"
    local out x=$2 y=$3 w=$4 h=$5 scale
    out=$(out_path "$1" mov)
    scale=$(ctl scale)
    rm -f "$out"
    # avfoundation captures the whole display in pixels; crop to the window.
    nohup ffmpeg -loglevel error -y -f avfoundation -capture_cursor 1 -framerate 30 -pixel_format bgr0 \
        -i "Capture screen 0:none" \
        -vf "crop=$((w * scale)):$((h * scale)):$((x * scale)):$((y * scale))" \
        -c:v libx264 -preset ultrafast -crf 16 "$out" </dev/null >"$DIR/record.log" 2>&1 &
    echo $! >"$DIR/record.pid"
    sleep 1.2 # ffmpeg takes a moment to start
    echo "$out"
}

cmd_record_stop() {
    local pid
    pid=$(pid_of record || true)
    [[ -z $pid ]] && return
    kill -INT "$pid" 2>/dev/null || true
    while kill -0 "$pid" 2>/dev/null; do sleep 0.2; done
    rm -f "$DIR/record.pid"
}

cmd_gif() {
    [[ $# -eq 2 || $# -ge 4 ]] || die "usage: gif IN OUT [START DURATION [WIDTH]]"
    local trim=()
    [[ $# -ge 4 ]] && trim=(-ss "$3" -t "$4")
    ffmpeg -loglevel error -y ${trim[@]+"${trim[@]}"} -i "$1" -vf \
        "fps=12,scale=${5:-760}:-1:flags=lanczos,split[a][b];[a]palettegen=stats_mode=diff:max_colors=128[p];[b][p]paletteuse=dither=bayer:bayer_scale=5:diff_mode=rectangle" \
        -loop 0 "$2"
    ls -lh "$2"
}

cmd_png() {
    [[ $# -ge 2 ]] || die "usage: png IN OUT [MAX_WIDTH]"
    ffmpeg -loglevel error -y -i "$1" -vf \
        "scale='min(${3:-1400},iw)':-1:flags=lanczos,split[a][b];[a]palettegen=max_colors=256:stats_mode=full[p];[b][p]paletteuse=dither=sierra2_4a" \
        "$2"
    ls -lh "$2"
}

cmd_stop() {
    cmd_record_stop
    stop_pid app
    stop_pid backdrop
}

command=${1:-}
[[ -n $command ]] || {
    sed -n '2,/^set -euo/p' "$0" | sed '$d; s/^# \{0,1\}//'
    exit 0
}
shift
case $command in
setup) cmd_setup ;;
backdrop) cmd_backdrop "$@" ;;
launch) cmd_launch "$@" ;;
front) cmd_front ;;
windows) ctl windows "$(app_pid)" ;;
click | drag | move) ctl "$command" "$@" ;;
shot) cmd_shot "$@" ;;
shot-all) cmd_shot_all "$@" ;;
key) cmd_key "$@" ;;
record-rect) cmd_record_rect "$@" ;;
shot-rect) cmd_shot_rect "$@" ;;
record) cmd_record "$@" ;;
record-stop) cmd_record_stop ;;
gif) cmd_gif "$@" ;;
png) cmd_png "$@" ;;
stop) cmd_stop ;;
*) die "unknown command: $command" ;;
esac
