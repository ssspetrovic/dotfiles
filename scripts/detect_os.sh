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
  case "$ID" in
    ubuntu | debian) OS="ubuntu" ;;
    fedora) OS="fedora" ;;
    *)
      echo "[detect_os] Warning: unrecognised distro '$ID', treating as ubuntu" >&2
      OS="ubuntu"
      ;;
  esac
else
  echo "[detect_os] Error: cannot detect OS" >&2
  exit 1
fi

export OS DISTRO
