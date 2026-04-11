#!/usr/bin/env bash
# install_packages.sh — installs core system packages via native package manager.
# Homebrew handles dev tooling; this handles the essentials only.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/detect_os.sh"

info() { echo -e "\033[0;32m[packages]\033[0m $*"; }

# ── package lists ─────────────────────────────────────────────────────────────
# Keep this intentionally minimal — dev tools belong in the Brewfile
COMMON_PACKAGES=(
  git
  curl
  wget
  zsh
  vim
  tmux
  stow          # GNU stow for symlinking
  unzip
  tree
  htop
)

UBUNTU_EXTRA=(
  build-essential
  ca-certificates
  gnupg
  software-properties-common
)

FEDORA_EXTRA=(
  gcc
  gcc-c++
  make
  ca-certificates
  gnupg2
)

MACOS_EXTRA=()  # Handled by xcode-select in bootstrap + Brewfile

# ── install ───────────────────────────────────────────────────────────────────
case "$OS" in
  ubuntu)
    info "Updating apt..."
    sudo apt-get update -qq
    info "Installing packages..."
    sudo apt-get install -y "${COMMON_PACKAGES[@]}" "${UBUNTU_EXTRA[@]}"
    ;;
  fedora)
    info "Updating dnf..."
    sudo dnf check-update -q || true   # dnf returns 100 if updates available — not an error
    info "Installing packages..."
    sudo dnf install -y "${COMMON_PACKAGES[@]}" "${FEDORA_EXTRA[@]}"
    ;;
  macos)
    # On macOS, most of COMMON_PACKAGES come via Homebrew (Brewfile).
    # We only ensure xcode CLI tools are present here.
    if ! xcode-select -p &>/dev/null; then
      info "Installing Xcode Command Line Tools..."
      xcode-select --install
      until xcode-select -p &>/dev/null; do sleep 5; done
    else
      info "Xcode CLI tools already installed"
    fi
    ;;
esac

info "Core packages done"
