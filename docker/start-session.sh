#!/usr/bin/env bash
set -Eeuo pipefail

export HOME=/home/aurora
export USER=aurora
export LOGNAME=aurora
export DISPLAY=:1
export WINEARCH=win32
export WINEDEBUG="${WINEDEBUG:--all}"
export WINEPREFIX=/config/wineprefix
export FREETYPE_PROPERTIES="${FREETYPE_PROPERTIES:-truetype:interpreter-version=35}"

readonly XVNC_LOG="/config/logs/xvnc.log"
readonly SESSION_LOG="/config/logs/session.log"

cleanup() {
    local status=$?

    if [[ -n "${SESSION_PID:-}" ]]; then
        kill "${SESSION_PID}" 2>/dev/null || true
    fi

    if [[ -n "${XVNC_PID:-}" ]]; then
        kill "${XVNC_PID}" 2>/dev/null || true
    fi

    wineserver -k 2>/dev/null || true
    wait 2>/dev/null || true
    exit "${status}"
}

trap cleanup EXIT INT TERM

rm -f /tmp/.X1-lock /tmp/.X11-unix/X1
install -d -m 0700 "${HOME}/.vnc"

/usr/bin/Xvnc :1 \
    -interface 0.0.0.0 \
    -websocketPort 8444 \
    -rfbport 5901 \
    -httpd /usr/share/kasmvnc/www \
    -cert /etc/ssl/certs/ssl-cert-snakeoil.pem \
    -key /etc/ssl/private/ssl-cert-snakeoil.key \
    -sslOnly 1 \
    -disableBasicAuth \
    -SecurityTypes None \
    -geometry 1920x1080 \
    -depth 24 \
    -desktop "Aurora Character Builder" \
    -AcceptSetDesktopSize 1 \
    -FrameRate 30 \
    -MaxVideoResolution 1920x1080 \
    -VideoScaling 2 \
    -IdleTimeout 0 \
    -MaxIdleTime 0 \
    -MaxConnectionTime 0 \
    -MaxDisconnectionTime 0 \
    -SendCutText 1 \
    -AcceptCutText 1 \
    -ac \
    -nolisten tcp \
    -Log '*:stdout:30' \
    >>"${XVNC_LOG}" 2>&1 &
XVNC_PID=$!

for _ in {1..60}; do
    if ! kill -0 "${XVNC_PID}" 2>/dev/null; then
        echo "Xvnc exited during startup." >&2
        tail -n 100 "${XVNC_LOG}" >&2
        exit 1
    fi

    if curl -kfsS https://127.0.0.1:8444/ >/dev/null 2>&1; then
        break
    fi

    sleep 1
done

dbus-run-session -- /usr/local/bin/start-aurora.sh \
    >>"${SESSION_LOG}" 2>&1 &
SESSION_PID=$!

wait "${SESSION_PID}"
