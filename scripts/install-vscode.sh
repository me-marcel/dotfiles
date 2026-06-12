#!/usr/bin/env bash

set -euo pipefail

USE_FLATPAK=false
SUDO_KEEPALIVE_PID=""

start_sudo_session() {
  if ! command -v sudo >/dev/null 2>&1; then
    return 0
  fi

  echo "==> Requesting sudo privileges"
  sudo -v
  (
    while true; do
      sudo -n true >/dev/null 2>&1 || exit 0
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

usage() {
  cat <<'EOF'
Usage: ./scripts/install-vscode.sh [--flatpak]

Options:
  --flatpak   Install Visual Studio Code from Flathub
  -h, --help  Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --flatpak)
      USE_FLATPAK=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

trap stop_sudo_session EXIT
start_sudo_session

extensions=(
  flaviodelgrosso.orange-juice-theme
  dbaeumer.vscode-eslint
  esbenp.prettier-vscode
  ms-azuretools.vscode-docker
  ms-kubernetes-tools.vscode-kubernetes-tools
  redhat.vscode-yaml
  eamodio.gitlens
  nrwl.angular-console
  angular.ng-template
  denoland.vscode-deno
)

install_extensions_with_code() {
  local installed
  local ext
  installed="$(code --list-extensions 2>/dev/null || true)"

  for ext in "${extensions[@]}"; do
    if printf '%s\n' "$installed" | grep -Fxq "$ext"; then
      echo "Skipping VS Code extension ${ext}; already installed."
    else
      code --install-extension "$ext" --force || true
    fi
  done
}

install_extensions_with_flatpak() {
  local installed
  local ext
  installed="$(flatpak run com.visualstudio.code --list-extensions 2>/dev/null || true)"

  for ext in "${extensions[@]}"; do
    if printf '%s\n' "$installed" | grep -Fxq "$ext"; then
      echo "Skipping VS Code extension ${ext}; already installed."
    else
      flatpak run com.visualstudio.code --install-extension "$ext" --force || true
    fi
  done
}

if [[ "${USE_FLATPAK}" == true ]]; then
  if ! command -v flatpak >/dev/null 2>&1; then
    sudo dnf install -y flatpak
  fi
  sudo flatpak remote-add --if-not-exists flathub "https://flathub.org/repo/flathub.flatpakrepo"
  if ! flatpak info com.visualstudio.code >/dev/null 2>&1; then
    flatpak install -y flathub com.visualstudio.code
  else
    echo "Skipping Visual Studio Code Flatpak; already installed."
  fi
  install_extensions_with_flatpak
else
  if [[ ! -f /etc/yum.repos.d/vscode.repo ]]; then
    sudo rpm --import "https://packages.microsoft.com/keys/microsoft.asc"
    sudo sh -c 'cat > /etc/yum.repos.d/vscode.repo <<"EOF"
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF'
  fi
  if ! command -v code >/dev/null 2>&1; then
    sudo dnf check-update || true
    sudo dnf install -y code
  else
    echo "Skipping Visual Studio Code RPM install; code is already available."
  fi
  install_extensions_with_code
fi

echo "VS Code installation complete."
