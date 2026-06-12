#!/usr/bin/env bash

set -euo pipefail

EXTENSION_ID="blur-my-shell@aunetx"

if [[ "${EUID}" -eq 0 ]]; then
  echo "Do not run as root." >&2
  exit 1
fi

echo "==> Installing Blur My Shell extension package"
if command -v gnome-extensions >/dev/null 2>&1 && gnome-extensions info "${EXTENSION_ID}" >/dev/null 2>&1; then
  echo "Blur My Shell is already installed."
else
  if ! sudo dnf install -y gnome-shell-extension-blur-my-shell; then
    echo "Could not install Blur My Shell from Fedora packages." >&2
    echo "Install it manually from extensions.gnome.org if needed." >&2
  fi
fi

if command -v gnome-extensions >/dev/null 2>&1; then
  if gnome-extensions list --enabled | grep -Fxq "${EXTENSION_ID}"; then
    echo "Blur My Shell is already enabled."
  else
    gnome-extensions enable "${EXTENSION_ID}" || true
  fi
fi

echo "GNOME extension setup complete. Log out and back in if the extension does not appear."
