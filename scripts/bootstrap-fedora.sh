#!/usr/bin/env bash

set -euo pipefail

WITH_EXTRA_LANGS=false
WITH_FLATPAK=false
APPLY_STOW=false
STOW_ADOPT=false
STOW_MODULES=(zsh tmux git vscode opencode gnome)

usage() {
  cat <<'EOF'
Usage: ./scripts/bootstrap-fedora.sh [options]

Options:
  --with-extra-langs       Install optional language runtimes (Go, Rust, Java 17)
  --with-flatpak           Ensure Flatpak is installed and Flathub is configured
  --apply-stow             Apply stow modules after package setup
  --stow-adopt             Use stow --adopt instead of backing up conflicts
  --stow-modules "..."      Space-separated stow module list
  -h, --help               Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --with-extra-langs)
      WITH_EXTRA_LANGS=true
      shift
      ;;
    --with-flatpak)
      WITH_FLATPAK=true
      shift
      ;;
    --apply-stow)
      APPLY_STOW=true
      shift
      ;;
    --stow-adopt)
      STOW_ADOPT=true
      shift
      ;;
    --stow-modules)
      IFS=' ' read -r -a STOW_MODULES <<< "${2:-}"
      shift 2
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

if [[ "${EUID}" -eq 0 ]]; then
  echo "Do not run this script as root." >&2
  exit 1
fi

if [[ ! -f /etc/os-release ]]; then
  echo "Unable to detect operating system." >&2
  exit 1
fi

# shellcheck disable=SC1091
source /etc/os-release

if [[ "${ID:-}" != "fedora" ]]; then
  echo "This script only supports Fedora." >&2
  exit 1
fi

if [[ "${VERSION_ID:-}" != "44" ]]; then
  echo "Expected Fedora 44, got Fedora ${VERSION_ID:-unknown}." >&2
  exit 1
fi

if ! command -v sudo >/dev/null 2>&1; then
  echo "sudo is required but not installed." >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
LOCAL_BIN_DIR="${HOME}/.local/bin"
BREW_BIN=""
SUDO_KEEPALIVE_PID=""

ensure_local_bin_dir() {
  mkdir -p "${LOCAL_BIN_DIR}"

  case ":${PATH}:" in
    *":${LOCAL_BIN_DIR}:"*) ;;
    *)
      export PATH="${LOCAL_BIN_DIR}:${PATH}"
      ;;
  esac
}

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

init_brew_env() {
  if [[ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
    BREW_BIN="/home/linuxbrew/.linuxbrew/bin/brew"
  elif [[ -x "${HOME}/.linuxbrew/bin/brew" ]]; then
    BREW_BIN="${HOME}/.linuxbrew/bin/brew"
  else
    return 1
  fi

  # shellcheck disable=SC1090
  eval "$("${BREW_BIN}" shellenv)"
  return 0
}

ensure_linuxbrew() {
  if init_brew_env; then
    return 0
  fi

  echo "Installing Linuxbrew for package fallback..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  init_brew_env
}

brew_formula_for_pkg() {
  case "$1" in
    python3) echo "python" ;;
    python3-pip) echo "python" ;;
    nodejs) echo "node" ;;
    npm) echo "node" ;;
    awscli) echo "awscli" ;;
    postgresql) echo "libpq" ;;
    fd-find) echo "fd" ;;
    ripgrep) echo "ripgrep" ;;
    nmap-ncat) echo "netcat" ;;
    fluxcd) echo "fluxcd/tap/flux" ;;
    kubeseal) echo "bitnami/tap/kubeseal" ;;
    kubens) echo "kubectx" ;;
    bind-utils) echo "bind" ;;
    *)
      # Most package names match formula names directly.
      echo "$1"
      ;;
  esac
}

supports_brew_fallback() {
  case "$1" in
    curl|wget|unzip|tar|gnupg|rsync|tree|which|jq|yq|fzf|ripgrep|fd-find|bat|eza|ncdu|nmap|traceroute|mtr|nmap-ncat|zsh|tmux|python3|python3-pip|pipx|nodejs|npm|awscli|kubectl|helm|kustomize|k9s|fluxcd|kubectx|kubens|stern|sops|age|kubeseal|redis|postgresql|stow|bind-utils)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

install_with_brew_fallback() {
  local pkg
  local formula
  local failed=()

  if ! ensure_linuxbrew; then
    echo "Linuxbrew installation failed; skipping brew fallback." >&2
    return 1
  fi

  for pkg in "$@"; do
    if ! supports_brew_fallback "$pkg"; then
      failed+=("$pkg")
      continue
    fi

    formula="$(brew_formula_for_pkg "$pkg")"
    if "${BREW_BIN}" list --formula "$formula" >/dev/null 2>&1; then
      echo "Skipping ${pkg}; brew formula ${formula} is already installed."
      continue
    fi

    if ! "${BREW_BIN}" install "$formula"; then
      failed+=("$pkg")
    fi
  done

  if [[ ${#failed[@]} -gt 0 ]]; then
    echo "Still unavailable after brew fallback: ${failed[*]}" >&2
    return 1
  fi

  return 0
}

package_command_hint() {
  case "$1" in
    fd-find) echo "fd" ;;
    nmap-ncat) echo "nc" ;;
    bind-utils) echo "dig" ;;
    python3-pip) echo "pip3" ;;
    pkgconf-pkg-config) echo "pkg-config" ;;
    gcc-c++) echo "g++" ;;
    java-17-openjdk) echo "java" ;;
    java-17-openjdk-devel) echo "javac" ;;
    nodejs) echo "node" ;;
    awscli|awscli2) echo "aws" ;;
    moby-engine) echo "docker" ;;
    docker-compose-plugin) echo "docker" ;;
    postgresql) echo "psql" ;;
    redis) echo "redis-cli" ;;
    fluxcd) echo "flux" ;;
    *)
      echo "$1"
      ;;
  esac
}

is_package_satisfied() {
  local pkg="$1"
  local cmd

  if rpm -q "$pkg" >/dev/null 2>&1; then
    return 0
  fi

  cmd="$(package_command_hint "$pkg")"
  if command -v "$cmd" >/dev/null 2>&1; then
    return 0
  fi

  return 1
}

machine_arch() {
  case "$(uname -m)" in
    x86_64)
      echo "amd64"
      ;;
    aarch64|arm64)
      echo "arm64"
      ;;
    *)
      echo "Unsupported architecture: $(uname -m)" >&2
      return 1
      ;;
  esac
}

latest_github_tag() {
  local repo="$1"
  curl -fsSL "https://api.github.com/repos/${repo}/releases/latest" \
    | sed -n 's/.*"tag_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' \
    | head -n 1
}

install_binary_from_tarball() {
  local url="$1"
  local binary_name="$2"
  local tmp_dir
  local archive
  local archive_entry

  tmp_dir="$(mktemp -d)"
  archive="${tmp_dir}/archive.tar.gz"
  trap 'rm -rf "${tmp_dir}"' RETURN

  curl -fsSL "$url" -o "$archive"
  archive_entry="$(tar -tzf "$archive" | grep -E "(^|/)${binary_name}$" | head -n 1 || true)"

  if [[ -z "${archive_entry}" ]]; then
    echo "Could not locate ${binary_name} in ${url}" >&2
    return 1
  fi

  tar -xzf "$archive" -C "$tmp_dir" "$archive_entry"
  install -m 0755 "${tmp_dir}/${archive_entry}" "${LOCAL_BIN_DIR}/${binary_name}"
}

install_tool_fallbacks() {
  local arch
  local tag
  arch="$(machine_arch)"
  ensure_local_bin_dir

  if ! command -v k9s >/dev/null 2>&1; then
    tag="$(latest_github_tag "derailed/k9s")"
    if [[ -n "${tag}" ]]; then
      install_binary_from_tarball "https://github.com/derailed/k9s/releases/download/${tag}/k9s_Linux_${arch}.tar.gz" "k9s" || true
    fi
  fi

  if ! command -v flux >/dev/null 2>&1; then
    tag="$(latest_github_tag "fluxcd/flux2")"
    if [[ -n "${tag}" ]]; then
      install_binary_from_tarball "https://github.com/fluxcd/flux2/releases/download/${tag}/flux_${tag#v}_linux_${arch}.tar.gz" "flux" || true
    fi
  fi

  if ! command -v kubeseal >/dev/null 2>&1; then
    tag="$(latest_github_tag "bitnami-labs/sealed-secrets")"
    if [[ -n "${tag}" ]]; then
      install_binary_from_tarball "https://github.com/bitnami-labs/sealed-secrets/releases/download/${tag}/kubeseal-${tag#v}-linux-${arch}.tar.gz" "kubeseal" || true
    fi
  fi

  if ! command -v stern >/dev/null 2>&1; then
    tag="$(latest_github_tag "stern/stern")"
    if [[ -n "${tag}" ]]; then
      install_binary_from_tarball "https://github.com/stern/stern/releases/download/${tag}/stern_${tag#v}_linux_${arch}.tar.gz" "stern" || true
    fi
  fi
}

install_packages_best_effort() {
  local pkg
  local failed=()

  for pkg in "$@"; do
    if is_package_satisfied "$pkg"; then
      echo "Skipping ${pkg}; already available."
      continue
    fi

    if ! sudo dnf install -y "$pkg"; then
      failed+=("$pkg")
    fi
  done

  if [[ ${#failed[@]} -gt 0 ]]; then
    echo "DNF could not install: ${failed[*]}"
    install_with_brew_fallback "${failed[@]}" || true
  fi
}

install_dev_tools_group() {
  local group_name
  local candidates=("Development Tools" "development-tools")

  for group_name in "${candidates[@]}"; do
    if sudo dnf group install -y "${group_name}"; then
      return 0
    fi

    if sudo dnf install -y "@${group_name}"; then
      return 0
    fi
  done

  echo "Could not install Development Tools group; continuing with explicit build packages." >&2
  return 0
}

backup_stow_conflicts() {
  local backup_root
  local module
  local src_root
  local src
  local rel
  local target

  backup_root="${HOME}/.dotfiles-pre-stow-backup/$(date +%Y%m%d-%H%M%S)"
  shopt -s globstar nullglob dotglob

  for module in "${STOW_MODULES[@]}"; do
    src_root="${REPO_ROOT}/stow/${module}"
    [[ -d "${src_root}" ]] || continue

    for src in "${src_root}"/**; do
      [[ -f "${src}" || -L "${src}" ]] || continue

      rel="${src#${src_root}/}"
      target="${HOME}/${rel}"

      if [[ -e "${target}" && ! -L "${target}" ]]; then
        mkdir -p "${backup_root}/$(dirname "${rel}")"
        mv "${target}" "${backup_root}/${rel}"
      fi
    done
  done

  shopt -u globstar nullglob dotglob

  if [[ -d "${backup_root}" ]]; then
    echo "Backed up conflicting dotfiles to ${backup_root}"
  fi
}

install_brave_and_replace_firefox() {
  echo "==> Installing Brave and removing Firefox"

  if [[ ! -f /etc/yum.repos.d/brave-browser.repo ]]; then
    sudo rpm --import "https://brave-browser-rpm-release.s3.brave.com/brave-core.asc"
    sudo tee /etc/yum.repos.d/brave-browser.repo >/dev/null <<'EOF'
[brave-browser]
name=Brave Browser
baseurl=https://brave-browser-rpm-release.s3.brave.com/$basearch
enabled=1
gpgcheck=1
gpgkey=https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
EOF
  fi

  if ! command -v brave-browser >/dev/null 2>&1; then
    sudo dnf install -y brave-browser
  else
    echo "Skipping brave-browser install; already available."
  fi

  if rpm -q firefox >/dev/null 2>&1; then
    sudo dnf remove -y firefox
  else
    echo "Skipping Firefox removal; package not installed."
  fi

  if command -v xdg-settings >/dev/null 2>&1; then
    xdg-settings set default-web-browser brave-browser.desktop || true
  fi

  if command -v gio >/dev/null 2>&1; then
    gio mime x-scheme-handler/http brave-browser.desktop >/dev/null 2>&1 || true
    gio mime x-scheme-handler/https brave-browser.desktop >/dev/null 2>&1 || true
    gio mime text/html brave-browser.desktop >/dev/null 2>&1 || true
  fi
}

install_password_manager() {
  echo "==> Installing password manager"

  if command -v flatpak >/dev/null 2>&1; then
    sudo flatpak remote-add --if-not-exists flathub "https://flathub.org/repo/flathub.flatpakrepo"

    if flatpak info org.keepassxc.KeePassXC >/dev/null 2>&1; then
      echo "Skipping KeePassXC Flatpak install; already installed."
    else
      flatpak install -y flathub org.keepassxc.KeePassXC
    fi
    return 0
  fi

  if ! command -v keepassxc >/dev/null 2>&1; then
    sudo dnf install -y keepassxc
  else
    echo "Skipping KeePassXC install; already installed."
  fi
}

trap stop_sudo_session EXIT
start_sudo_session

echo "==> Updating system"
sudo dnf upgrade --refresh -y

echo "==> Installing core packages"
install_dev_tools_group
install_packages_best_effort \
  git curl wget unzip tar gnupg rsync tree which \
  gcc gcc-c++ make cmake pkgconf-pkg-config openssl-devel sassc \
  htop btop lsof sysstat

echo "==> Installing CLI productivity packages"
install_packages_best_effort \
  zsh tmux fzf ripgrep fd-find bat eza ncdu \
  jq yq \
  bind-utils nmap traceroute mtr nmap-ncat iproute

echo "==> Installing language runtimes"
install_packages_best_effort python3 python3-pip pipx

curl -fsSL "https://rpm.nodesource.com/setup_22.x" | sudo bash -
install_packages_best_effort nodejs npm

if [[ "${WITH_EXTRA_LANGS}" == true ]]; then
  install_packages_best_effort golang rust cargo java-17-openjdk java-17-openjdk-devel
fi

echo "==> Installing cloud and infra tooling"
if ! sudo dnf install -y awscli2; then
  install_packages_best_effort awscli
fi

python3 -m pipx ensurepath >/dev/null 2>&1 || true
if command -v pipx >/dev/null 2>&1; then
  pipx install aws-sso-util || true
fi

install_packages_best_effort \
  kubectl helm kustomize kubectx kubens \
  sops age \
  moby-engine docker-compose-plugin \
  redis postgresql

if ! command -v k9s >/dev/null 2>&1; then
  install_packages_best_effort k9s
fi

if ! command -v flux >/dev/null 2>&1; then
  install_packages_best_effort fluxcd
fi

if ! command -v kubeseal >/dev/null 2>&1; then
  install_packages_best_effort kubeseal
fi

if ! command -v stern >/dev/null 2>&1; then
  install_packages_best_effort stern
fi

install_tool_fallbacks

echo "==> Enabling Docker service"
sudo systemctl enable --now docker || true

echo "==> Installing desktop tools"
install_packages_best_effort gnome-tweaks gnome-extensions-app dconf-editor stow
install_brave_and_replace_firefox

if [[ "${WITH_FLATPAK}" == true ]]; then
  install_packages_best_effort flatpak
  sudo flatpak remote-add --if-not-exists flathub "https://flathub.org/repo/flathub.flatpakrepo"
fi

install_password_manager

echo "==> Installing Oh My Zsh"
if [[ ! -d "${HOME}/.oh-my-zsh" ]]; then
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}"
if [[ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ]]; then
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
fi
if [[ ! -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ]]; then
  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
fi
if [[ ! -d "${ZSH_CUSTOM}/plugins/zsh-completions" ]]; then
  git clone --depth=1 https://github.com/zsh-users/zsh-completions "${ZSH_CUSTOM}/plugins/zsh-completions"
fi

echo "==> Configuring login shell"
if [[ "${SHELL}" != "/usr/bin/zsh" ]]; then
  sudo usermod --shell /usr/bin/zsh "${USER}" || true
fi

if [[ "${APPLY_STOW}" == true ]]; then
  echo "==> Applying stow modules"
  if [[ "${STOW_ADOPT}" == true ]]; then
    stow --adopt -d "${REPO_ROOT}/stow" -t "${HOME}" "${STOW_MODULES[@]}"
  else
    backup_stow_conflicts
    stow -d "${REPO_ROOT}/stow" -t "${HOME}" "${STOW_MODULES[@]}"
  fi
fi

echo "Bootstrap finished. Re-login to fully apply shell changes."
