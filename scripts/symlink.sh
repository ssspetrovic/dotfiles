#!/usr/bin/env bash
# symlink.sh — backwards-compatible wrapper for the old stow entrypoint.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[deprecated] scripts/symlink.sh now delegates to chezmoi; prefer scripts/apply_dotfiles.sh" >&2
exec bash "$SCRIPT_DIR/apply_dotfiles.sh" "$@"
