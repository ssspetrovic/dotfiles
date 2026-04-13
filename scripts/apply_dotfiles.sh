#!/usr/bin/env bash
# apply_dotfiles.sh — apply dotfiles with chezmoi (standard workflow)
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHEZMOI_SOURCE_DIR="$DOTFILES_DIR/chezmoi"

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'
info() { echo -e "${GREEN}[chezmoi]${NC} $*"; }
error() {
  echo -e "${RED}[chezmoi]${NC} $*" >&2
  exit 1
}

if ! command -v chezmoi &>/dev/null; then
  error "chezmoi not found — install_brew.sh or brew bundle should have handled this"
fi

if [[ ! -d "$CHEZMOI_SOURCE_DIR" ]]; then
  error "chezmoi source directory not found: $CHEZMOI_SOURCE_DIR"
fi

# ── initialize chezmoi if needed ──────────────────────────────────────────────
CURRENT_SOURCE="$(chezmoi source-path 2>/dev/null || true)"

if [[ -z "$CURRENT_SOURCE" ]]; then
  info "Initializing chezmoi with source: $CHEZMOI_SOURCE_DIR"
  chezmoi init --source="$CHEZMOI_SOURCE_DIR"
elif [[ "$CURRENT_SOURCE" != "$CHEZMOI_SOURCE_DIR" ]]; then
  info "Re-initializing chezmoi with new source: $CHEZMOI_SOURCE_DIR"
  chezmoi init --force --source="$CHEZMOI_SOURCE_DIR"
else
  info "chezmoi already initialized with correct source"
fi

# ── apply dotfiles ────────────────────────────────────────────────────────────
info "Applying dotfiles"
chezmoi apply --force --progress
info "Dotfiles applied"
