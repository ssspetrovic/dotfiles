#!/usr/bin/env bash
# install_packages.sh — installs core system packages via native package manager.
# Homebrew handles dev tooling; this handles the essentials only.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/detect_os.sh"

info() { echo -e "\033[0;32m[packages]\033[0m $*"; }
error() {
  echo -e "\033[0;31m[packages]\033[0m $*" >&2
  exit 1
}

as_root() {
  if [[ $(id -u) -eq 0 ]]; then
    "$@"
  elif command -v sudo &>/dev/null; then
    sudo "$@"
  else
    error "This step requires root privileges, but sudo is not installed"
  fi
}

wait_for_xcode_cli_tools() {
  local max_wait_seconds="${1:-600}"
  local waited=0

  while ! xcode-select -p &>/dev/null; do
    if (( waited >= max_wait_seconds )); then
      error "Xcode Command Line Tools did not finish within ${max_wait_seconds}s; complete the install manually and re-run install.sh"
    fi
    sleep 5
    waited=$((waited + 5))
  done
}

# ── package lists ─────────────────────────────────────────────────────────────
# Keep this intentionally minimal — dev tools belong in the Brewfile
COMMON_PACKAGES=(
  git
  curl
  wget
  zsh
  vim
  tmux
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
  wl-clipboard
  xclip
)

ARCH_EXTRA=(
  base-devel
  ca-certificates
  gnupg
)

OPENSUSE_EXTRA=(
  patterns-devel-base-devel_basis
  ca-certificates
  gpg2
)

# ── install ───────────────────────────────────────────────────────────────────
case "$OS" in
  ubuntu)
    info "Updating apt..."
    as_root apt-get update -qq
    info "Installing packages..."
    as_root apt-get install -y "${COMMON_PACKAGES[@]}" "${UBUNTU_EXTRA[@]}"
    ;;
  fedora)
    info "Updating dnf..."
    as_root dnf check-update -q || true # dnf returns 100 if updates available — not an error
    info "Installing packages..."
    as_root dnf install -y "${COMMON_PACKAGES[@]}" "${FEDORA_EXTRA[@]}"
    ;;
  arch)
    info "Updating pacman and installing packages..."
    as_root pacman -Syu --needed --noconfirm "${COMMON_PACKAGES[@]}" "${ARCH_EXTRA[@]}"
    ;;
  opensuse)
    info "Refreshing zypper..."
    as_root zypper --non-interactive refresh
    info "Installing packages..."
    as_root zypper --non-interactive install --no-recommends "${COMMON_PACKAGES[@]}" "${OPENSUSE_EXTRA[@]}"
    ;;
  macos)
    # On macOS, most of COMMON_PACKAGES come via Homebrew (Brewfile).
    # We only ensure xcode CLI tools are present here.
    if ! xcode-select -p &>/dev/null; then
      info "Installing Xcode Command Line Tools..."
      xcode-select --install 2>/dev/null || true
      wait_for_xcode_cli_tools
    else
      info "Xcode CLI tools already installed"
    fi
    ;;
esac

info "Core packages done"
