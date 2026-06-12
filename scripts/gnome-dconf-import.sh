#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
INPUT_FILE="${REPO_ROOT}/stow/gnome/dconf/gnome-profile.dconf"

if [[ ! -f "${INPUT_FILE}" ]]; then
  echo "dconf profile file not found: ${INPUT_FILE}" >&2
  exit 1
fi

dconf load / < "${INPUT_FILE}"
echo "Imported GNOME profile from ${INPUT_FILE}"
