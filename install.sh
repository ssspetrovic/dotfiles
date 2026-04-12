#!/usr/bin/env bash
# install.sh — main orchestrator. Run this directly when already cloned.
# Usage: bash ~/.dotfiles/install.sh
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── colours ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'
info() { echo -e "${GREEN}[install]${NC} $*"; }
warning() { echo -e "${YELLOW}[install]${NC} $*"; }
error() {
  echo -e "${RED}[install]${NC} $*" >&2
  exit 1
}
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

# Ensure brew is in PATH for the rest of this session — install_brew.sh runs
# in a subshell so its eval doesn't propagate back to here.
if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
elif [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# ── step 3: brew bundle ───────────────────────────────────────────────────────
section "Brew Bundle"
if command -v brew &>/dev/null; then
  brew bundle --file="$DOTFILES_DIR/brew/Brewfile"
else
  warning "brew not found, skipping Brewfile"
fi

# ── step 4: apply dotfiles via chezmoi ────────────────────────────────────────
section "Applying dotfiles (chezmoi)"
bash "$DOTFILES_DIR/scripts/apply_dotfiles.sh"

# ── step 5: OS-specific extras ────────────────────────────────────────────────
section "OS-specific setup"
case "$OS" in
  ubuntu) bash "$DOTFILES_DIR/os/ubuntu.sh" ;;
  fedora) bash "$DOTFILES_DIR/os/fedora.sh" ;;
  macos) bash "$DOTFILES_DIR/os/macos.sh" ;;
esac

# ── step 6: set default shell to zsh ──────────────────────────────────────────
section "Default shell"
ZSH_PATH="$(command -v zsh)"
if [[ "$SHELL" == "$ZSH_PATH" ]]; then
  info "zsh is already the default shell"
else
  info "Setting zsh as default shell..."
  if ! grep -qF "$ZSH_PATH" /etc/shells; then
    echo "$ZSH_PATH" | sudo tee -a /etc/shells
  fi
  # chsh fails non-interactively on Ubuntu (PAM); usermod is more reliable
  if command -v usermod &>/dev/null; then
    sudo usermod -s "$ZSH_PATH" "$USER"
  else
    chsh -s "$ZSH_PATH"
  fi
  info "Shell changed to $ZSH_PATH — re-login to take effect"
fi

# ── step 7: vim plugins ───────────────────────────────────────────────────────
section "Vim plugins"
if command -v vim &>/dev/null; then
  if [[ ! -d "$HOME/.vim/plugged" ]]; then
    info "Installing vim plugins headlessly..."
    vim -Es -u "$HOME/.vimrc" +PlugInstall +qall 2>/dev/null
    info "Vim plugins installed"
  else
    info "Vim plugins already installed, updating..."
    vim -Es -u "$HOME/.vimrc" +PlugUpdate +qall 2>/dev/null
  fi
else
  warning "vim not found, skipping plugin install"
fi

# ── step 8: tmux plugins ──────────────────────────────────────────────────────
section "Tmux plugins"
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [[ ! -d "$TPM_DIR" ]]; then
  info "Cloning TPM..."
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

info "Installing tmux plugins headlessly..."
# TPM supports headless install via its install script directly
"$TPM_DIR/bin/install_plugins"
info "Tmux plugins installed"

section "Done! Open a new terminal or run: exec zsh"
