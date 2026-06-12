#!/usr/bin/env bash

set -euo pipefail

WITH_EXTRA_LANGS=false
WITH_FLATPAK=false
APPLY_STOW=false
STOW_MODULES=(zsh tmux git vscode opencode gnome)

usage() {
  cat <<'EOF'
Usage: ./scripts/bootstrap-fedora.sh [options]

Options:
  --with-extra-langs       Install optional language runtimes (Go, Rust, Java 17)
  --with-flatpak           Ensure Flatpak is installed and Flathub is configured
  --apply-stow             Apply stow modules after package setup
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

ensure_local_bin_dir() {
  mkdir -p "${LOCAL_BIN_DIR}"

  case ":${PATH}:" in
    *":${LOCAL_BIN_DIR}:"*) ;;
    *)
      export PATH="${LOCAL_BIN_DIR}:${PATH}"
      ;;
  esac
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
    if ! sudo dnf install -y "$pkg"; then
      failed+=("$pkg")
    fi
  done

  if [[ ${#failed[@]} -gt 0 ]]; then
    echo "Skipped unavailable packages: ${failed[*]}" >&2
  fi
}

echo "==> Updating system"
sudo dnf upgrade --refresh -y

echo "==> Installing core packages"
if ! sudo dnf group install -y "Development Tools"; then
  sudo dnf groupinstall -y "Development Tools"
fi
install_packages_best_effort \
  git curl wget unzip tar gnupg rsync tree which \
  gcc gcc-c++ make cmake pkgconf-pkg-config openssl-devel \
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

if [[ "${WITH_FLATPAK}" == true ]]; then
  install_packages_best_effort flatpak
  sudo flatpak remote-add --if-not-exists flathub "https://flathub.org/repo/flathub.flatpakrepo"
fi

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
  chsh -s /usr/bin/zsh "${USER}"
fi

if [[ "${APPLY_STOW}" == true ]]; then
  echo "==> Applying stow modules"
  stow -d "${REPO_ROOT}/stow" -t "${HOME}" "${STOW_MODULES[@]}"
fi

echo "Bootstrap finished. Re-login to fully apply shell changes."
