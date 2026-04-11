#!/usr/bin/env bash
# install.sh — main orchestrator. Run this directly when already cloned.
# Usage: bash ~/dotfiles/install.sh
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── colours ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
info()    { echo -e "${GREEN}[install]${NC} $*"; }
warning() { echo -e "${YELLOW}[install]${NC} $*"; }
error()   { echo -e "${RED}[install]${NC} $*" >&2; exit 1; }
section() { echo -e "\n${CYAN}══ $* ══${NC}"; }

# ── source helpers ─────────────────────────────────────────────────────────────
# shellcheck disable=SC1091
source "$DOTFILES_DIR/scripts/detect_os.sh"

section "Detected: $OS / $DISTRO"

# ── step 1: core packages via native package manager ──────────────────────────
section "Core packages"
bash "$DOTFILES_DIR/scripts/install_packages.sh"

# ── step 2: homebrew ──────────────────────────────────────────────────────────
section "Homebrew"
bash "$DOTFILES_DIR/scripts/install_brew.sh"

# ── step 3: brew bundle ───────────────────────────────────────────────────────
section "Brew Bundle"
if command -v brew &>/dev/null; then
  brew bundle --file="$DOTFILES_DIR/brew/Brewfile"
else
  warning "brew not found, skipping Brewfile"
fi

# ── step 4: symlinks via stow ─────────────────────────────────────────────────
section "Symlinking dotfiles (stow)"
bash "$DOTFILES_DIR/scripts/symlink.sh"

# ── step 5: OS-specific extras ────────────────────────────────────────────────
section "OS-specific setup"
case "$OS" in
  ubuntu) bash "$DOTFILES_DIR/os/ubuntu.sh" ;;
  fedora) bash "$DOTFILES_DIR/os/fedora.sh" ;;
  macos)  bash "$DOTFILES_DIR/os/macos.sh"  ;;
esac

# ── step 6: set default shell to zsh ──────────────────────────────────────────
section "Default shell"
if [[ "$SHELL" != "$(command -v zsh)" ]]; then
  info "Setting zsh as default shell..."
  ZSH_PATH="$(command -v zsh)"
  if ! grep -qF "$ZSH_PATH" /etc/shells; then
    echo "$ZSH_PATH" | sudo tee -a /etc/shells
  fi
  chsh -s "$ZSH_PATH"
  info "Shell changed — re-login to take effect"
else
  info "zsh is already the default shell"
fi

section "Done! Open a new terminal or run: exec zsh"
