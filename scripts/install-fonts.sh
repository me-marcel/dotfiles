#!/usr/bin/env bash

set -euo pipefail

FONT_NAME="JetBrainsMono"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
FONT_DIR="${HOME}/.local/share/fonts/${FONT_NAME}NerdFont"
TMP_DIR="$(mktemp -d)"
ARCHIVE="${TMP_DIR}/${FONT_NAME}.zip"
FORCE_INSTALL=false

if [[ "${1:-}" == "--force" ]]; then
  FORCE_INSTALL=true
fi

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

if ! command -v curl >/dev/null 2>&1; then
  echo "curl is required." >&2
  exit 1
fi

if ! command -v unzip >/dev/null 2>&1; then
  echo "unzip is required." >&2
  exit 1
fi

mkdir -p "${FONT_DIR}"

if [[ "${FORCE_INSTALL}" != true ]] && find "${FONT_DIR}" -maxdepth 1 -type f \( -name "*.ttf" -o -name "*.otf" \) | grep -q .; then
  echo "${FONT_NAME} Nerd Font already installed at ${FONT_DIR}; skipping."
  exit 0
fi

echo "==> Downloading ${FONT_NAME} Nerd Font"
curl -fsSL "${FONT_URL}" -o "${ARCHIVE}"

echo "==> Installing font files"
unzip -oq "${ARCHIVE}" -d "${FONT_DIR}"

find "${FONT_DIR}" -type f \( -name "*Windows Compatible*" -o -name "*.txt" -o -name "*.md" \) -delete

if command -v fc-cache >/dev/null 2>&1; then
  echo "==> Refreshing font cache"
  fc-cache -f "${HOME}/.local/share/fonts"
fi

echo "Installed ${FONT_NAME} Nerd Font into ${FONT_DIR}"
