#!/usr/bin/env bash
set -Eeuo pipefail

readonly APP="${WINEPREFIX}/drive_c/Program Files/Aurora/Aurora Character Builder/Aurora Builder.exe"
readonly OPENBOX_CONFIG="/opt/aurora/openbox/rc.xml"

cleanup() {
    local status=$?

    if [[ -n "${WINE_PID:-}" ]]; then
        kill "${WINE_PID}" 2>/dev/null || true
    fi

    if [[ -n "${OPENBOX_PID:-}" ]]; then
        kill "${OPENBOX_PID}" 2>/dev/null || true
    fi

    wineserver -k 2>/dev/null || true
    wait 2>/dev/null || true
    exit "${status}"
}

trap cleanup EXIT INT TERM

xsetroot -solid '#111827'

openbox --config-file "${OPENBOX_CONFIG}" &
OPENBOX_PID=$!

wine "${APP}" &
WINE_PID=$!

for _ in {1..120}; do
    if ! kill -0 "${WINE_PID}" 2>/dev/null; then
        wait "${WINE_PID}"
    fi

    window_id="$(
        wmctrl -lx 2>/dev/null |
            awk '
                BEGIN { IGNORECASE=1 }
                /aurora builder\.exe/ && !/GlowWindow/ && !/Hidden Window/ {
                    print $1
                    exit
                }
            '
    )"

    if [[ -n "${window_id}" ]]; then
        wmctrl -i -r "${window_id}" -b add,maximized_vert,maximized_horz || true
        break
    fi

    sleep 1
done

wait "${WINE_PID}"
