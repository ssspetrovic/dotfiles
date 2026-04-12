#!/usr/bin/env bash
# apply_dotfiles.sh — apply dotfiles with chezmoi from this repo's source dir.
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

info "Applying dotfiles from $CHEZMOI_SOURCE_DIR"
chezmoi apply --source="$CHEZMOI_SOURCE_DIR" --less-interactive "$@"
info "Dotfiles applied"
