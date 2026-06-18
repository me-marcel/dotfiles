#!/usr/bin/env bash

set -euo pipefail

EXTENSION_ID="blur-my-shell@aunetx"
SUDO_KEEPALIVE_PID=""

start_sudo_session() {
  echo "==> Requesting sudo privileges"
  if ! sudo -n -v >/dev/null 2>&1; then
    sudo -v
  fi
  export DOTFILES_SUDO_ACTIVE=1

  (
    while true; do
      sudo -n -v >/dev/null 2>&1 || exit 0
      sleep 45
    done
  ) &
  SUDO_KEEPALIVE_PID="$!"
}

stop_sudo_session() {
  if [[ -n "${SUDO_KEEPALIVE_PID}" ]]; then
    kill "${SUDO_KEEPALIVE_PID}" >/dev/null 2>&1 || true
  fi
}

if [[ "${EUID}" -eq 0 ]]; then
  echo "Do not run as root." >&2
  exit 1
fi

trap stop_sudo_session EXIT
start_sudo_session

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

if command -v gsettings >/dev/null 2>&1; then
  gsettings set org.gnome.shell.extensions.blur-my-shell.panel blur true || true
fi

echo "GNOME extension setup complete. Log out and back in if the extension does not appear."
