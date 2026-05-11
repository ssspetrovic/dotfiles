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

TARGET_USER="${DOTFILES_TARGET_USER:-${SUDO_USER:-${USER:-$(id -un)}}}"

get_login_shell() {
  local login_shell=""

  if command -v getent &>/dev/null; then
    login_shell="$(getent passwd "$TARGET_USER" 2>/dev/null | cut -d: -f7 || true)"
    if [[ -n "$login_shell" ]]; then
      printf '%s\n' "$login_shell"
      return
    fi
  fi

  if [[ "$OS" == "macos" ]] && command -v dscl &>/dev/null; then
    login_shell="$(dscl . -read "/Users/$TARGET_USER" UserShell 2>/dev/null | awk '{print $2}' || true)"
    if [[ -n "$login_shell" ]]; then
      printf '%s\n' "$login_shell"
      return
    fi
  fi

  printf '%s\n' "${SHELL:-}"
}

change_shell_with_chsh() {
  local missing_chsh_message="$1"
  local failed_chsh_message="$2"
  local current_user

  current_user="$(id -un)"
  if [[ "$current_user" != "$TARGET_USER" ]]; then
    warning "Skipping chsh because this process is running as '$current_user', not '$TARGET_USER'."
    return
  fi

  if ! command -v chsh &>/dev/null; then
    warning "$missing_chsh_message"
    return
  fi

  if chsh -s "$ZSH_PATH"; then
    info "Shell changed to $ZSH_PATH — re-login to take effect"
  else
    warning "$failed_chsh_message"
  fi
}

# ── source helpers ─────────────────────────────────────────────────────────────
# shellcheck disable=SC1091
source "$DOTFILES_DIR/scripts/detect_os.sh"
# shellcheck disable=SC1091
source "$DOTFILES_DIR/scripts/brew_shellenv.sh"

section "Detected: $OS / $DISTRO"

# ── step 1: core packages via native package manager ──────────────────────────
section "Core packages"
bash "$DOTFILES_DIR/scripts/install_packages.sh"

# ── step 2: homebrew ──────────────────────────────────────────────────────────
section "Homebrew"
bash "$DOTFILES_DIR/scripts/install_brew.sh"

# Ensure brew is in PATH for the rest of this session — install_brew.sh runs
# in a subshell so its eval doesn't propagate back to here.
load_brew_shellenv || true

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
  arch | opensuse) info "No extra OS-specific steps for $OS yet" ;;
esac

# ── step 6: set default shell to zsh ──────────────────────────────────────────
section "Default shell"
if [[ $(id -u) -eq 0 && -z "${SUDO_USER:-}" && -z "${DOTFILES_TARGET_USER:-}" ]]; then
  warning "Running as root without SUDO_USER; skipping login shell change. Set DOTFILES_TARGET_USER to target another account."
else
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
    # usermod only updates local /etc/passwd. LDAP/SSSD/NIS users are not there, so
    # usermod fails with "does not exist in /etc/passwd" — use chsh or directory admin.
    # chsh can still fail non-interactively on some PAM setups; usermod is preferred when local.
    if command -v usermod &>/dev/null && awk -F: -v user="$TARGET_USER" '$1 == user { found = 1 } END { exit !found }' /etc/passwd 2>/dev/null; then
      as_root usermod -s "$ZSH_PATH" "$TARGET_USER"
      info "Shell changed to $ZSH_PATH — re-login to take effect"
    elif command -v usermod &>/dev/null; then
      warning "User '$TARGET_USER' has no local /etc/passwd entry (typical for LDAP/SSSD). Skipping usermod."
      info "To set login shell: run  chsh -s '$ZSH_PATH'  (password may be required), or ask your admin to set loginShell in the directory."
      change_shell_with_chsh \
        "chsh not found; ask your admin to set loginShell in the directory." \
        "chsh failed; use one of the options above."
    else
      change_shell_with_chsh \
        "Neither usermod nor chsh is available; default shell was not changed." \
        "chsh failed; default shell was not changed."
    fi
  fi
fi

# ── step 7: vim plugins ───────────────────────────────────────────────────────
section "Vim plugins"
if command -v vim &>/dev/null; then
  VIM_PLUG_PATH="$HOME/.vim/autoload/plug.vim"

  if [[ ! -f "$VIM_PLUG_PATH" ]]; then
    info "Installing vim-plug..."
    if command -v curl &>/dev/null; then
      if ! curl -fLo "$VIM_PLUG_PATH" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim; then
        warning "Failed to download vim-plug with curl; skipping Vim plugin install"
      fi
    elif command -v wget &>/dev/null; then
      mkdir -p "$(dirname "$VIM_PLUG_PATH")"
      if ! wget -O "$VIM_PLUG_PATH" \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim; then
        warning "Failed to download vim-plug with wget; skipping Vim plugin install"
      fi
    else
      warning "Neither curl nor wget found; skipping vim-plug install"
    fi
  fi

  if [[ -f "$VIM_PLUG_PATH" ]]; then
    if [[ ! -d "$HOME/.vim/plugged" ]]; then
      info "Installing vim plugins headlessly..."
      if vim -Es -u "$HOME/.vimrc" +PlugInstall +qall 2>/dev/null; then
        info "Vim plugins installed"
      else
        warning "Vim plugin install failed; continuing"
      fi
    else
      info "Vim plugins already installed, updating..."
      if ! vim -Es -u "$HOME/.vimrc" +PlugUpdate +qall 2>/dev/null; then
        warning "Vim plugin update failed; continuing"
      fi
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
if ! command -v tmux &>/dev/null; then
  warning "tmux not found, skipping tmux plugin install"
else
  if [[ ! -d "$TPM_DIR" ]] && command -v git &>/dev/null; then
    info "Cloning TPM..."
    if ! git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"; then
      warning "Failed to clone TPM; skipping tmux plugin install"
    fi
  elif [[ ! -d "$TPM_DIR" ]]; then
    warning "git not found, skipping TPM clone"
  fi

  if [[ -x "$TPM_DIR/bin/install_plugins" ]]; then
    info "Installing tmux plugins headlessly..."
    # TPM supports headless install via its install script directly.
    if "$TPM_DIR/bin/install_plugins"; then
      info "Tmux plugins installed"
    else
      warning "Tmux plugin install failed; continuing"
    fi
  else
    warning "TPM install script not found, skipping tmux plugin install"
  fi
fi

section "Done! Open a new terminal or run: exec zsh"
