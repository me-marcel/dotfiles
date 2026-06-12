#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
INPUT_FILE="${REPO_ROOT}/stow/gnome/dconf/gnome-profile.dconf"

if ! command -v dconf >/dev/null 2>&1; then
  echo "Skipping dconf import; dconf command is not installed."
  exit 0
fi

if [[ ! -f "${INPUT_FILE}" ]]; then
  echo "Skipping dconf import; profile file not found: ${INPUT_FILE}" >&2
  exit 0
fi

dconf load / < "${INPUT_FILE}"
echo "Imported GNOME profile from ${INPUT_FILE}"
