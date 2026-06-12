#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_step() {
  local title="$1"
  shift
  echo "==> ${title}"
  "$@"
}

run_step "Bootstrap Fedora packages" \
  "${REPO_ROOT}/scripts/bootstrap-fedora.sh" --with-flatpak

run_step "Install Nerd Fonts" "${REPO_ROOT}/scripts/install-fonts.sh"
run_step "Install VS Code and extensions" "${REPO_ROOT}/scripts/install-vscode.sh"
run_step "Install OpenCode" "${REPO_ROOT}/scripts/install-opencode.sh"
run_step "Install Orchis/Tela themes and wallpaper" "${REPO_ROOT}/scripts/install-themes.sh"
run_step "Install GNOME extensions" "${REPO_ROOT}/scripts/install-gnome-extensions.sh"

run_step "Apply stow modules" \
  stow -d "${REPO_ROOT}/stow" -t "${HOME}" zsh tmux git vscode opencode gnome

run_step "Import GNOME dconf profile" "${REPO_ROOT}/scripts/gnome-dconf-import.sh"

echo "Installation complete. Re-login to apply shell and GNOME changes."
