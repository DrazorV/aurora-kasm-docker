#!/usr/bin/env bash
set -Eeuo pipefail

readonly TEMPLATE="/opt/aurora/wine-template"
readonly PREFIX="/config/wineprefix"
readonly DATA_DIR="/data/aurora"
readonly DOCUMENTS="${PREFIX}/drive_c/users/aurora/Documents/5e Character Builder"

if [[ ! -r "${DATA_DIR}" || ! -w "${DATA_DIR}" ]]; then
    echo "ERROR: /data/aurora must be readable and writable by UID/GID 1000." >&2
    exit 1
fi

install -d -m 0755 -o aurora -g aurora /config /config/logs

if [[ ! -f "${PREFIX}/system.reg" ]]; then
    echo "Creating the persistent Wine prefix from the image template..."
    cp -a "${TEMPLATE}" "${PREFIX}"
    chown -R aurora:aurora "${PREFIX}"
fi

if [[ ! -f "${PREFIX}/drive_c/Program Files/Aurora/Aurora Character Builder/Aurora Builder.exe" ]]; then
    echo "ERROR: Persistent Wine prefix is incomplete: ${PREFIX}" >&2
    exit 1
fi

ln -sfn "${DATA_DIR}" "${PREFIX}/dosdevices/d:"

if [[ -L "${DOCUMENTS}" ]]; then
    ln -sfn "${DATA_DIR}" "${DOCUMENTS}"
elif [[ -d "${DOCUMENTS}" ]]; then
    if find "${DOCUMENTS}" -mindepth 1 -print -quit | grep -q .; then
        echo "ERROR: Refusing to replace non-empty directory: ${DOCUMENTS}" >&2
        exit 1
    fi

    rmdir "${DOCUMENTS}"
    ln -s "${DATA_DIR}" "${DOCUMENTS}"
elif [[ ! -e "${DOCUMENTS}" ]]; then
    install -d -m 0755 -o aurora -g aurora "$(dirname "${DOCUMENTS}")"
    ln -s "${DATA_DIR}" "${DOCUMENTS}"
else
    echo "ERROR: Unexpected file at Windows Documents mapping: ${DOCUMENTS}" >&2
    exit 1
fi

chown -h aurora:aurora \
    "${PREFIX}/dosdevices/d:" \
    "${DOCUMENTS}"

exec /usr/bin/tini -- /usr/sbin/gosu aurora /usr/local/bin/start-session.sh
