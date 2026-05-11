#!/usr/bin/env bash
# bootstrap.sh — curl-able entry point
# Usage: curl -fsSL https://raw.githubusercontent.com/ssspetrovic/dotfiles/main/bootstrap.sh | bash
set -euo pipefail

DOTFILES_REPO="https://github.com/ssspetrovic/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"

# ── colours ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
info() { echo -e "${GREEN}[bootstrap]${NC} $*"; }
warning() { echo -e "${YELLOW}[bootstrap]${NC} $*"; }
error() {
  echo -e "${RED}[bootstrap]${NC} $*" >&2
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

# ── detect OS ─────────────────────────────────────────────────────────────────
detect_os() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "macos"
  elif [[ -f /etc/os-release ]]; then
    # shellcheck disable=SC1091
    source /etc/os-release
    local os_id="${ID:-unknown}"
    local os_like=" ${ID_LIKE:-} "

    case "$os_id" in
      ubuntu | debian) echo "ubuntu" ;;
      fedora) echo "fedora" ;;
      arch) echo "arch" ;;
      opensuse* | suse | sles | sled) echo "opensuse" ;;
      *)
        case "$os_like" in
          *" debian "*) echo "ubuntu" ;;
          *" fedora "*) echo "fedora" ;;
          *" arch "*) echo "arch" ;;
          *" opensuse "* | *" suse "*) echo "opensuse" ;;
          *) error "Unsupported distro: $os_id. Supported: macOS, Debian/Ubuntu, Fedora, Arch, openSUSE/SUSE" ;;
        esac
        ;;
    esac
  else
    error "Cannot detect OS"
  fi
}

OS=$(detect_os)
info "Detected OS: $OS"

wait_for_command() {
  local command_name="$1"
  local install_label="$2"
  local max_wait_seconds="${3:-600}"
  local waited=0

  while ! command -v "$command_name" &>/dev/null; do
    if (( waited >= max_wait_seconds )); then
      error "$install_label did not finish within ${max_wait_seconds}s; complete it manually and re-run bootstrap.sh"
    fi
    sleep 5
    waited=$((waited + 5))
  done
}

# ── install git if missing ─────────────────────────────────────────────────────
install_git() {
  if command -v git &>/dev/null; then
    info "git already installed"
    return
  fi
  info "Installing git..."
  case "$OS" in
    ubuntu)
      as_root apt-get update -qq
      as_root apt-get install -y git
      ;;
    fedora) as_root dnf install -y git ;;
    arch) as_root pacman -Syu --needed --noconfirm git ;;
    opensuse)
      as_root zypper --non-interactive refresh
      as_root zypper --non-interactive install --no-recommends git
      ;;
    macos)
      # xcode-select triggers the git stub which installs CLI tools
      xcode-select --install 2>/dev/null || true
      # Wait for installation to complete
      wait_for_command git "Xcode Command Line Tools"
      ;;
  esac
}

install_git

# ── clone or update dotfiles ───────────────────────────────────────────────────
if [[ -d "$DOTFILES_DIR/.git" ]]; then
  info "dotfiles already cloned, pulling latest..."
  git -C "$DOTFILES_DIR" pull --rebase
else
  info "Cloning dotfiles to $DOTFILES_DIR..."
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

# ── hand off to install.sh ─────────────────────────────────────────────────────
info "Handing off to install.sh..."
bash "$DOTFILES_DIR/install.sh"
