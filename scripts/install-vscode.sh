#!/usr/bin/env bash

set -euo pipefail

USE_FLATPAK=false

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
  local ext
  for ext in "${extensions[@]}"; do
    code --install-extension "$ext" --force || true
  done
}

install_extensions_with_flatpak() {
  local ext
  for ext in "${extensions[@]}"; do
    flatpak run com.visualstudio.code --install-extension "$ext" --force || true
  done
}

if [[ "${USE_FLATPAK}" == true ]]; then
  sudo dnf install -y flatpak
  sudo flatpak remote-add --if-not-exists flathub "https://flathub.org/repo/flathub.flatpakrepo"
  flatpak install -y flathub com.visualstudio.code
  install_extensions_with_flatpak
else
  sudo rpm --import "https://packages.microsoft.com/keys/microsoft.asc"
  sudo sh -c 'cat > /etc/yum.repos.d/vscode.repo <<"EOF"
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF'
  sudo dnf check-update || true
  sudo dnf install -y code
  install_extensions_with_code
fi

echo "VS Code installation complete."
