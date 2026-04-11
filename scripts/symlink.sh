#!/usr/bin/env bash
# symlink.sh — uses GNU stow to symlink dotfile packages into $HOME.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()    { echo -e "${GREEN}[stow]${NC} $*"; }
warning() { echo -e "${YELLOW}[stow]${NC} $*"; }

# ── ensure stow is available ──────────────────────────────────────────────────
if ! command -v stow &>/dev/null; then
  warning "stow not found — install_packages.sh should have handled this"
  exit 1
fi

# ── packages to stow ──────────────────────────────────────────────────────────
# Each entry is a subdirectory of dotfiles/ whose structure mirrors $HOME.
STOW_PACKAGES=(
  zsh
  vim
  tmux
  git
  starship
)

# ── backup helper ─────────────────────────────────────────────────────────────
backup_if_exists() {
  local target="$1"
  if [[ -e "$target" && ! -L "$target" ]]; then
    local backup="${target}.bak.$(date +%Y%m%d_%H%M%S)"
    warning "Backing up existing $target → $backup"
    mv "$target" "$backup"
  fi
}

# ── pre-flight: backup any real files that stow would conflict with ───────────
backup_if_exists "$HOME/.zshrc"
backup_if_exists "$HOME/.zshenv"
backup_if_exists "$HOME/.vimrc"
backup_if_exists "$HOME/.tmux.conf"
backup_if_exists "$HOME/.gitconfig"
backup_if_exists "$HOME/.gitignore_global"
backup_if_exists "$HOME/.config/starship.toml"

# ── stow each package ─────────────────────────────────────────────────────────
cd "$DOTFILES_DIR"

for pkg in "${STOW_PACKAGES[@]}"; do
  if [[ -d "$pkg" ]]; then
    info "Stowing $pkg..."
    # --restow removes and re-creates links (idempotent)
    stow --restow --target="$HOME" --dir="$DOTFILES_DIR" "$pkg"
  else
    warning "Package directory '$pkg' not found, skipping"
  fi
done

info "All packages stowed"
