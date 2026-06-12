#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SRC_DIR="${HOME}/.local/src"
THEMES_DIR="${HOME}/.local/share/themes"
ICONS_DIR="${HOME}/.local/share/icons"
BACKGROUND_DIR="${HOME}/.local/share/backgrounds"
WALLPAPER_SOURCE="${REPO_ROOT}/assets/wallpapers/orange-sunset.jpg"
WALLPAPER_TARGET="${BACKGROUND_DIR}/orange-sunset.jpg"

mkdir -p "${SRC_DIR}" "${THEMES_DIR}" "${ICONS_DIR}" "${BACKGROUND_DIR}"

clone_or_update() {
  local repo_url="$1"
  local target_dir="$2"

  if [[ -d "${target_dir}/.git" ]]; then
    git -C "${target_dir}" pull --ff-only
  else
    git clone "${repo_url}" "${target_dir}"
  fi
}

echo "==> Installing Orchis theme"
clone_or_update "https://github.com/vinceliuice/orchis-theme" "${SRC_DIR}/orchis-theme"
bash "${SRC_DIR}/orchis-theme/install.sh" -c dark -t orange --tweaks solid macos

echo "==> Installing Tela icons"
clone_or_update "https://github.com/vinceliuice/Tela-icon-theme" "${SRC_DIR}/tela-icon-theme"
bash "${SRC_DIR}/tela-icon-theme/install.sh" -c orange

GTK_THEME="$(ls -1 "${THEMES_DIR}" 2>/dev/null | grep -E '^Orchis.*(Dark|dark).*(Orange|orange)' | head -n 1 || true)"
ICON_THEME="$(ls -1 "${ICONS_DIR}" 2>/dev/null | grep -E '^Tela.*(orange|Orange)' | head -n 1 || true)"

if [[ -n "${GTK_THEME}" ]]; then
  gsettings set org.gnome.desktop.interface gtk-theme "${GTK_THEME}"
  gsettings set org.gnome.desktop.wm.preferences theme "${GTK_THEME}"
  gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:'
  gsettings set org.gnome.shell.extensions.user-theme name "${GTK_THEME}" || true
fi

if [[ -n "${ICON_THEME}" ]]; then
  gsettings set org.gnome.desktop.interface icon-theme "${ICON_THEME}"
fi

if [[ -f "${WALLPAPER_SOURCE}" ]]; then
  cp -f "${WALLPAPER_SOURCE}" "${WALLPAPER_TARGET}"
  gsettings set org.gnome.desktop.background picture-uri "file://${WALLPAPER_TARGET}"
  gsettings set org.gnome.desktop.background picture-uri-dark "file://${WALLPAPER_TARGET}"
  gsettings set org.gnome.desktop.screensaver picture-uri "file://${WALLPAPER_TARGET}"
else
  echo "Wallpaper not found at ${WALLPAPER_SOURCE}. Add your image and rerun this script." >&2
fi

echo "Theme installation completed."
