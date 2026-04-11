#!/usr/bin/env bash
# install_brew.sh — idempotently installs Homebrew on macOS and Linux.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/detect_os.sh"

info() { echo -e "\033[0;32m[brew]\033[0m $*"; }

# ── already installed? ────────────────────────────────────────────────────────
if command -v brew &>/dev/null; then
  info "Homebrew already installed at $(brew --prefix), updating..."
  brew update
  exit 0
fi

# ── install ───────────────────────────────────────────────────────────────────
info "Installing Homebrew..."
NONINTERACTIVE=1 /bin/bash -c \
  "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# ── add brew to PATH for the rest of this session ────────────────────────────
case "$OS" in
  macos)
    # Apple Silicon vs Intel
    if [[ -f /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
    ;;
  ubuntu | fedora)
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    ;;
esac

info "Homebrew installed: $(brew --version | head -1)"
