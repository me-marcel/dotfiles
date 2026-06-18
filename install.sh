#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUDO_KEEPALIVE_PID=""

refresh_docker_group_session() {
  if [[ ! -t 0 ]]; then
    return 0
  fi

  if ! getent group docker >/dev/null 2>&1; then
    return 0
  fi

  if ! getent group docker | grep -Eq "(^|:)docker:[^:]*:.*(^|,)${USER}(,|$)"; then
    return 0
  fi

  if id -nG "${USER}" | grep -qw docker; then
    return 0
  fi

  if command -v newgrp >/dev/null 2>&1; then
    echo "==> Refreshing shell groups for Docker access"
    echo "A new shell will start with docker group permissions."
    exec newgrp docker
  fi
}

start_sudo_session() {
  if ! command -v sudo >/dev/null 2>&1; then
    return 0
  fi

  echo "==> Requesting sudo once at start"
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

trap stop_sudo_session EXIT

run_step() {
  local title="$1"
  shift
  echo "==> ${title}"
  "$@"
}

start_sudo_session

run_step "Bootstrap Fedora packages" \
  env DOTFILES_IN_INSTALL_SH=1 "${REPO_ROOT}/scripts/bootstrap-fedora.sh" --with-flatpak

run_step "Install Nerd Fonts" "${REPO_ROOT}/scripts/install-fonts.sh"
run_step "Install VS Code and extensions" "${REPO_ROOT}/scripts/install-vscode.sh"
run_step "Install OpenCode" "${REPO_ROOT}/scripts/install-opencode.sh"
run_step "Install Orchis/Tela themes and wallpaper" "${REPO_ROOT}/scripts/install-themes.sh"
run_step "Install GNOME extensions" "${REPO_ROOT}/scripts/install-gnome-extensions.sh"

run_step "Apply stow modules" \
  stow -d "${REPO_ROOT}/stow" -t "${HOME}" zsh tmux git vscode opencode gnome

run_step "Import GNOME dconf profile" "${REPO_ROOT}/scripts/gnome-dconf-import.sh"

refresh_docker_group_session

echo "Installation complete. Re-login to apply shell and GNOME changes."
