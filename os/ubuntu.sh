#!/usr/bin/env bash
# os/ubuntu.sh — Ubuntu/Debian-specific extras after core install
set -euo pipefail

info() { echo -e "\033[0;32m[ubuntu]\033[0m $*"; }

# ── example: install a font ───────────────────────────────────────────────────
# mkdir -p ~/.local/share/fonts
# curl -fsSL "https://..." -o ~/.local/share/fonts/SomeFont.ttf
# fc-cache -f

# ── example: enable fzf key bindings installed via brew ───────────────────────
# Already handled in .zshrc via: source <(fzf --zsh)

# ── example: add mise shims to PATH via .zshenv ───────────────────────────────
# Already handled in .zshenv

info "Ubuntu extras done (add distro-specific steps here)"
