#!/usr/bin/env bash
# install_brew.sh — idempotently installs Homebrew on macOS and Linux.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/detect_os.sh"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/brew_shellenv.sh"

info() { echo -e "\033[0;32m[brew]\033[0m $*"; }
warning() { echo -e "\033[1;33m[brew]\033[0m $*"; }
error() {
  echo -e "\033[0;31m[brew]\033[0m $*" >&2
  exit 1
}

# ── already installed? ────────────────────────────────────────────────────────
if load_brew_shellenv; then
  info "Homebrew already installed at $(brew --prefix), updating..."
  brew update || warning "brew update failed; continuing with the existing Homebrew state"
  exit 0
fi

# ── install ───────────────────────────────────────────────────────────────────
info "Installing Homebrew..."
NONINTERACTIVE=1 /bin/bash -c \
  "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# ── add brew to PATH for the rest of this session ────────────────────────────
load_brew_shellenv || error "Homebrew installed, but brew was not found in a known prefix"

info "Homebrew installed: $(brew --version | sed -n '1p')"
