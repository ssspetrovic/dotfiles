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

as_root() {
  if [[ $(id -u) -eq 0 ]]; then
    "$@"
  elif command -v sudo &>/dev/null; then
    sudo "$@"
  else
    error "This step requires root privileges, but sudo is not installed"
  fi
}

TARGET_USER="${SUDO_USER:-${USER:-$(id -un)}}"

get_login_shell() {
  if command -v getent &>/dev/null; then
    getent passwd "$TARGET_USER" | cut -d: -f7
  elif [[ "$OS" == "macos" ]] && command -v dscl &>/dev/null; then
    dscl . -read "/Users/$TARGET_USER" UserShell | awk '{print $2}'
  else
    printf '%s\n' "${SHELL:-}"
  fi
}

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
CURRENT_LOGIN_SHELL="$(get_login_shell)"
if [[ "$CURRENT_LOGIN_SHELL" == "$ZSH_PATH" ]]; then
  info "zsh is already the default shell"
else
  info "Setting zsh as default shell..."
  if ! grep -qF "$ZSH_PATH" /etc/shells; then
    if [[ $(id -u) -eq 0 ]]; then
      echo "$ZSH_PATH" >>/etc/shells
    elif command -v sudo &>/dev/null; then
      echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
    else
      error "Need root privileges to add $ZSH_PATH to /etc/shells"
    fi
  fi
  # chsh fails non-interactively on Ubuntu (PAM); usermod is more reliable
  if command -v usermod &>/dev/null; then
    as_root usermod -s "$ZSH_PATH" "$TARGET_USER"
  else
    chsh -s "$ZSH_PATH"
  fi
  info "Shell changed to $ZSH_PATH — re-login to take effect"
fi

# ── step 7: vim plugins ───────────────────────────────────────────────────────
section "Vim plugins"
if command -v vim &>/dev/null; then
  VIM_PLUG_PATH="$HOME/.vim/autoload/plug.vim"

  if [[ ! -f "$VIM_PLUG_PATH" ]]; then
    info "Installing vim-plug..."
    if command -v curl &>/dev/null; then
      curl -fLo "$VIM_PLUG_PATH" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    elif command -v wget &>/dev/null; then
      mkdir -p "$(dirname "$VIM_PLUG_PATH")"
      wget -O "$VIM_PLUG_PATH" \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    else
      warning "Neither curl nor wget found; skipping vim-plug install"
    fi
  fi

  if [[ -f "$VIM_PLUG_PATH" ]]; then
    if [[ ! -d "$HOME/.vim/plugged" ]]; then
      info "Installing vim plugins headlessly..."
      vim -Es -u "$HOME/.vimrc" +PlugInstall +qall 2>/dev/null
      info "Vim plugins installed"
    else
      info "Vim plugins already installed, updating..."
      vim -Es -u "$HOME/.vimrc" +PlugUpdate +qall 2>/dev/null
    fi
  else
    warning "vim-plug not available, skipping plugin install"
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
