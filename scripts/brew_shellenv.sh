#!/usr/bin/env bash
# brew_shellenv.sh — helpers for finding Homebrew across macOS and Linux.
# Source this from installer scripts; do not execute it directly.

find_brew() {
  local candidate
  local candidates=(
    "$(command -v brew 2>/dev/null || true)"
    /opt/homebrew/bin/brew
    /usr/local/bin/brew
    /home/linuxbrew/.linuxbrew/bin/brew
    "$HOME/.linuxbrew/bin/brew"
  )

  for candidate in "${candidates[@]}"; do
    if [[ -n "$candidate" && -x "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  return 1
}

load_brew_shellenv() {
  local brew_bin

  if ! brew_bin="$(find_brew)"; then
    return 1
  fi

  eval "$("$brew_bin" shellenv)"
}
