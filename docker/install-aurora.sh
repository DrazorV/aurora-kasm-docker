#!/usr/bin/env bash
set -Eeuo pipefail

readonly INSTALLER="/tmp/aurora-assets/Aurora Setup.msi"
readonly PREFIX="/opt/aurora/wine-template"
readonly APP="${PREFIX}/drive_c/Program Files/Aurora/Aurora Character Builder/Aurora Builder.exe"
readonly BUILD_LOG="/tmp/aurora-build.log"

if [[ ! -r "${INSTALLER}" ]]; then
    cat >&2 <<'EOF'
ERROR: assets/Aurora Setup.msi is missing.

Download Aurora from its official website and place the installer at:
  assets/Aurora Setup.msi

The installer is intentionally excluded from this repository.
EOF
    exit 1
fi

install -d -m 0755 -o aurora -g aurora "${PREFIX}"
touch "${BUILD_LOG}"
chown aurora:aurora "${BUILD_LOG}"

run_wine() {
    runuser -u aurora -- env \
        HOME=/home/aurora \
        USER=aurora \
        LOGNAME=aurora \
        WINEARCH=win32 \
        WINEDEBUG=-all \
        WINEPREFIX="${PREFIX}" \
        bash -c 'cd /home/aurora && exec xvfb-run -a "$@"' bash "$@" \
        >>"${BUILD_LOG}" 2>&1
}

run_wine wineboot --init
run_wine winetricks -q remove_mono
run_wine winetricks -q --force dotnet452 vcrun2010 corefonts calibri
run_wine wine msiexec /i "Z:${INSTALLER//\//\\}" /qn /norestart
run_wine winetricks -q win7
run_wine wineserver -w

if [[ ! -f "${APP}" ]]; then
    echo "ERROR: Aurora installation did not create the expected executable." >&2
    tail -n 100 "${BUILD_LOG}" >&2
    exit 1
fi

rm -f "${PREFIX}/dosdevices/z:"
