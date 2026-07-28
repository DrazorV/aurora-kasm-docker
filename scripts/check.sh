#!/usr/bin/env bash
set -Eeuo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${repo_root}"

shell_files=(
    docker/entrypoint.sh
    docker/healthcheck.sh
    docker/install-aurora.sh
    docker/install-fonts.sh
    docker/start-aurora.sh
    docker/start-session.sh
    scripts/check.sh
)

for file in "${shell_files[@]}"; do
    bash -n "${file}"
done

if command -v shellcheck >/dev/null 2>&1; then
    shellcheck "${shell_files[@]}"
else
    echo "shellcheck is not installed; syntax checks completed."
fi

if command -v docker >/dev/null 2>&1; then
    AURORA_DATA_PATH=/tmp/aurora-data docker compose config --quiet
else
    echo "docker is not installed; Compose validation skipped."
fi

echo "Repository checks completed."
