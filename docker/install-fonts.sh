#!/usr/bin/env bash
set -Eeuo pipefail

readonly SOURCE_DIR="/tmp/aurora-assets/fonts"
readonly PREFIX="/opt/aurora/wine-template"
readonly WINE_FONT_DIR="${PREFIX}/drive_c/windows/Fonts"
readonly SYSTEM_FONT_DIR="/usr/local/share/fonts/aurora-microsoft"

declare -A FONT_NAMES=(
    [segoeui.ttf]="Segoe UI (TrueType)"
    [segoeuib.ttf]="Segoe UI Bold (TrueType)"
    [segoeuil.ttf]="Segoe UI Light (TrueType)"
    [seguisb.ttf]="Segoe UI Semibold (TrueType)"
    [segoeuisl.ttf]="Segoe UI Semilight (TrueType)"
    [seguisym.ttf]="Segoe UI Symbol (TrueType)"
)

if [[ ! -d "${SOURCE_DIR}" ]]; then
    exit 0
fi

install -d -m 0755 "${SYSTEM_FONT_DIR}"
install -d -m 0755 -o aurora -g aurora "${WINE_FONT_DIR}"

installed=0

for font_path in "${SOURCE_DIR}"/*.ttf; do
    [[ -e "${font_path}" ]] || continue

    font_file="$(basename "${font_path}")"

    if ! fc-scan "${font_path}" >/dev/null 2>&1; then
        echo "ERROR: Invalid font file: ${font_path}" >&2
        exit 1
    fi

    install -m 0644 "${font_path}" "${SYSTEM_FONT_DIR}/${font_file}"
    install -m 0644 -o aurora -g aurora \
        "${font_path}" "${WINE_FONT_DIR}/${font_file}"

    font_name="${FONT_NAMES[${font_file}]:-}"

    if [[ -n "${font_name}" ]]; then
        runuser -u aurora -- env \
            HOME=/home/aurora \
            WINEARCH=win32 \
            WINEDEBUG=-all \
            WINEPREFIX="${PREFIX}" \
            wine reg add \
                'HKLM\Software\Microsoft\Windows NT\CurrentVersion\Fonts' \
                /v "${font_name}" \
                /t REG_SZ \
                /d "${font_file}" \
                /f >/dev/null
    fi

    installed=$((installed + 1))
done

if (( installed > 0 )); then
    fc-cache -f
fi
