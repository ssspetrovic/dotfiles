#!/usr/bin/env bash
# detect_os.sh — sourced helper. Sets $OS and $DISTRO.
# Source this, don't execute it.

if [[ "$OSTYPE" == "darwin"* ]]; then
  OS="macos"
  DISTRO="macos"
elif [[ -f /etc/os-release ]]; then
  # shellcheck disable=SC1091
  source /etc/os-release
  DISTRO="${ID:-unknown}"
  DISTRO_LIKE=" ${ID_LIKE:-} "

  case "$DISTRO" in
    ubuntu | debian) OS="ubuntu" ;;
    fedora) OS="fedora" ;;
    arch) OS="arch" ;;
    opensuse* | suse | sles | sled) OS="opensuse" ;;
    *)
      case "$DISTRO_LIKE" in
        *" debian "*) OS="ubuntu" ;;
        *" fedora "*) OS="fedora" ;;
        *" arch "*) OS="arch" ;;
        *" opensuse "* | *" suse "*) OS="opensuse" ;;
        *)
          echo "[detect_os] Error: unsupported distro '$DISTRO'" >&2
          echo "[detect_os] Supported: macOS, Debian/Ubuntu, Fedora, Arch, openSUSE/SUSE" >&2
          exit 1
          ;;
      esac
      ;;
  esac
else
  echo "[detect_os] Error: cannot detect OS" >&2
  exit 1
fi

export OS DISTRO
