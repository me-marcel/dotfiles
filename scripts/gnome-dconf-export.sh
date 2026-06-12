#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
OUTPUT_FILE="${REPO_ROOT}/stow/gnome/dconf/gnome-profile.dconf"

TMP_FILE="$(mktemp)"
trap 'rm -f "${TMP_FILE}"' EXIT

for path in \
  /org/gnome/desktop/interface/ \
  /org/gnome/desktop/background/ \
  /org/gnome/desktop/screensaver/ \
  /org/gnome/desktop/wm/preferences/ \
  /org/gnome/shell/extensions/blur-my-shell/; do
  dconf dump "${path}" >> "${TMP_FILE}"
done

mv "${TMP_FILE}" "${OUTPUT_FILE}"
echo "Exported GNOME profile to ${OUTPUT_FILE}"
