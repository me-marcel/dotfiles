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
ORCHIS_REPO_URL="https://github.com/vinceliuice/Orchis-theme"
ORCHIS_FIX_BRANCH="fix-gnome50-sidebar"
ORCHIS_FIX_FORK_URL="https://github.com/tristanmsct/Orchis-theme"

mkdir -p "${SRC_DIR}" "${THEMES_DIR}" "${ICONS_DIR}" "${BACKGROUND_DIR}"

apply_libadwaita_patch_if_supported() {
  local install_script="$1"

  if bash "${install_script}" --help 2>/dev/null | grep -q -- '--libadwaita'; then
    bash "${install_script}" -c dark -t orange --tweaks solid --libadwaita
    return 0
  fi

  bash "${install_script}" -c dark -t orange --tweaks solid
}

apply_gtk4_theme_files() {
  local theme_name="$1"
  local theme_gtk4_dir="${THEMES_DIR}/${theme_name}/gtk-4.0"

  if [[ ! -d "${theme_gtk4_dir}" ]]; then
    return 0
  fi

  mkdir -p "${HOME}/.config/gtk-4.0"
  ln -sfn "${theme_gtk4_dir}/gtk.css" "${HOME}/.config/gtk-4.0/theme.css"

  if [[ -f "${theme_gtk4_dir}/gtk-dark.css" ]]; then
    ln -sfn "${theme_gtk4_dir}/gtk-dark.css" "${HOME}/.config/gtk-4.0/theme-dark.css"
  fi

  if [[ -d "${theme_gtk4_dir}/assets" ]]; then
    ln -sfn "${theme_gtk4_dir}/assets" "${HOME}/.config/gtk-4.0/assets"
  fi

  cat > "${HOME}/.config/gtk-4.0/gtk.css" <<'EOF'
@import url("theme.css");

window,
window.background,
.background {
  background-color: rgba(24, 24, 24, 0.94);
}

decoration {
  border: 1px solid transparent;
}

decoration:focus {
  border-color: rgba(255, 159, 28, 0.9);
  box-shadow: 0 0 0 1px rgba(255, 159, 28, 0.9);
}

decoration:backdrop {
  border-color: transparent;
  box-shadow: none;
}
EOF

  if [[ -L "${HOME}/.config/gtk-4.0/theme-dark.css" || -f "${HOME}/.config/gtk-4.0/theme-dark.css" ]]; then
    cat > "${HOME}/.config/gtk-4.0/gtk-dark.css" <<'EOF'
@import url("theme-dark.css");

window,
window.background,
.background {
  background-color: rgba(24, 24, 24, 0.94);
}

decoration {
  border: 1px solid transparent;
}

decoration:focus {
  border-color: rgba(255, 159, 28, 0.9);
  box-shadow: 0 0 0 1px rgba(255, 159, 28, 0.9);
}

decoration:backdrop {
  border-color: transparent;
  box-shadow: none;
}
EOF
  fi
}

apply_gtk3_transparency_override() {
  mkdir -p "${HOME}/.config/gtk-3.0"

  cat > "${HOME}/.config/gtk-3.0/gtk.css" <<'EOF'
window,
.background {
  background-color: rgba(24, 24, 24, 0.94);
}

decoration {
  border: 1px solid transparent;
}

decoration:focus {
  border-color: rgba(255, 159, 28, 0.9);
  box-shadow: 0 0 0 1px rgba(255, 159, 28, 0.9);
}

decoration:backdrop {
  border-color: transparent;
  box-shadow: none;
}
EOF
}

enable_flatpak_theme_access() {
  if command -v flatpak >/dev/null 2>&1; then
    flatpak override --user --filesystem=xdg-data/themes >/dev/null 2>&1 || true
  fi
}

clone_or_update() {
  local repo_url="$1"
  local target_dir="$2"

  if [[ -d "${target_dir}/.git" ]]; then
    git -C "${target_dir}" pull --ff-only
  else
    git clone "${repo_url}" "${target_dir}"
  fi
}

ensure_orchis_fix_branch() {
  local repo_dir="$1"
  local has_origin_fix=false
  local has_fork_fix=false

  if git -C "${repo_dir}" ls-remote --exit-code --heads origin "${ORCHIS_FIX_BRANCH}" >/dev/null 2>&1; then
    has_origin_fix=true
  fi

  if [[ "${has_origin_fix}" == true ]]; then
    git -C "${repo_dir}" fetch origin "${ORCHIS_FIX_BRANCH}" >/dev/null 2>&1
    git -C "${repo_dir}" checkout "${ORCHIS_FIX_BRANCH}" >/dev/null 2>&1
    git -C "${repo_dir}" pull --ff-only origin "${ORCHIS_FIX_BRANCH}" >/dev/null 2>&1 || true
    echo "Using Orchis branch ${ORCHIS_FIX_BRANCH} from origin"
    return 0
  fi

  if git ls-remote --exit-code --heads "${ORCHIS_FIX_FORK_URL}" "${ORCHIS_FIX_BRANCH}" >/dev/null 2>&1; then
    has_fork_fix=true
  fi

  if [[ "${has_fork_fix}" == true ]]; then
    if git -C "${repo_dir}" remote get-url orchis-fix >/dev/null 2>&1; then
      git -C "${repo_dir}" remote set-url orchis-fix "${ORCHIS_FIX_FORK_URL}" >/dev/null 2>&1
    else
      git -C "${repo_dir}" remote add orchis-fix "${ORCHIS_FIX_FORK_URL}" >/dev/null 2>&1
    fi

    git -C "${repo_dir}" fetch orchis-fix "${ORCHIS_FIX_BRANCH}" >/dev/null 2>&1
    git -C "${repo_dir}" checkout -B "${ORCHIS_FIX_BRANCH}" "orchis-fix/${ORCHIS_FIX_BRANCH}" >/dev/null 2>&1
    echo "Using Orchis branch ${ORCHIS_FIX_BRANCH} from tristanmsct fork"
    return 0
  fi

  echo "Could not find ${ORCHIS_FIX_BRANCH}; continuing with default Orchis branch." >&2
}

echo "==> Installing Orchis theme"
clone_or_update "${ORCHIS_REPO_URL}" "${SRC_DIR}/orchis-theme"
ensure_orchis_fix_branch "${SRC_DIR}/orchis-theme"
apply_libadwaita_patch_if_supported "${SRC_DIR}/orchis-theme/install.sh"

echo "==> Installing Tela icons"
clone_or_update "https://github.com/vinceliuice/Tela-icon-theme" "${SRC_DIR}/tela-icon-theme"
bash "${SRC_DIR}/tela-icon-theme/install.sh" -c orange

GTK_THEME="$(ls -1 "${THEMES_DIR}" 2>/dev/null | grep -E '^Orchis.*(Dark|dark).*(Orange|orange)' | head -n 1 || true)"
ICON_THEME="$(ls -1 "${ICONS_DIR}" 2>/dev/null | grep -E '^Tela.*(orange|Orange)' | head -n 1 || true)"

if [[ -n "${GTK_THEME}" ]]; then
  gsettings set org.gnome.desktop.interface gtk-theme "${GTK_THEME}"
  gsettings set org.gnome.desktop.interface accent-color 'orange' || true
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
  gsettings set org.gnome.desktop.wm.preferences theme "${GTK_THEME}"
  gsettings set org.gnome.desktop.wm.preferences button-layout ':minimize,maximize,close'
  gsettings set org.gnome.shell.extensions.user-theme name "${GTK_THEME}" || true
  apply_gtk4_theme_files "${GTK_THEME}"
  apply_gtk3_transparency_override
  enable_flatpak_theme_access
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
