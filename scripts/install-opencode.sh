#!/usr/bin/env bash

set -euo pipefail

if [[ "${EUID}" -eq 0 ]]; then
  echo "Do not run as root." >&2
  exit 1
fi

if command -v opencode >/dev/null 2>&1; then
  echo "OpenCode is already installed."
else
  curl -fsSL "https://opencode.ai/install" | sh
fi

if command -v opencode >/dev/null 2>&1; then
  opencode --version
  echo "OpenCode CLI is ready."
else
  echo "OpenCode install finished but command was not found in PATH." >&2
  exit 1
fi
