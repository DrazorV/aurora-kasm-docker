#!/usr/bin/env bash
set -Eeuo pipefail

curl -kfsS https://127.0.0.1:8444/ >/dev/null
pgrep -f '/usr/bin/Xvnc :1' >/dev/null
pgrep -f 'Aurora Builder.exe' >/dev/null
