#!/usr/bin/env bash

set -euo pipefail

if [[ "${EUID}" -eq 0 ]]; then
  echo "Do not run as root." >&2
  exit 1
fi

add_to_path() {
  local dir="$1"
  if [[ -d "${dir}" ]]; then
    case ":${PATH}:" in
      *":${dir}:"*) ;;
      *) export PATH="${dir}:${PATH}" ;;
    esac
  fi
}

ensure_path_file_entry() {
  local file="$1"
  local line='export PATH="$HOME/.local/bin:$PATH"'

  touch "${file}"
  if ! grep -Fq "$line" "${file}"; then
    printf '\n%s\n' "$line" >> "${file}"
  fi
}

add_to_path "${HOME}/.local/bin"
add_to_path "${HOME}/.opencode/bin"
add_to_path "${HOME}/.local/share/opencode/bin"

if command -v opencode >/dev/null 2>&1; then
  echo "OpenCode is already installed."
else
  curl -fsSL "https://opencode.ai/install" | sh
fi

if ! command -v opencode >/dev/null 2>&1; then
  candidates=(
    "${HOME}/.local/bin/opencode"
    "${HOME}/.opencode/bin/opencode"
    "${HOME}/.local/share/opencode/bin/opencode"
  )

  for candidate in "${candidates[@]}"; do
    if [[ -x "${candidate}" ]]; then
      mkdir -p "${HOME}/.local/bin"
      ln -sf "${candidate}" "${HOME}/.local/bin/opencode"
      add_to_path "${HOME}/.local/bin"
      break
    fi
  done
fi

if command -v opencode >/dev/null 2>&1; then
  ensure_path_file_entry "${HOME}/.profile"
  ensure_path_file_entry "${HOME}/.zprofile"
  opencode --version
  echo "OpenCode CLI is ready."
else
  echo "OpenCode install finished but command was not found in PATH." >&2
  echo "Try locating it with: ls ~/.local/bin ~/.opencode/bin ~/.local/share/opencode/bin" >&2
  echo "Then symlink it to ~/.local/bin/opencode and re-run this script." >&2
  exit 1
fi
