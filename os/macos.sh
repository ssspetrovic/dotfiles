#!/usr/bin/env bash
# os/macos.sh — macOS-specific extras and sensible defaults
set -euo pipefail

info() { echo -e "\033[0;32m[macos]\033[0m $*"; }

info "Applying macOS defaults..."

# ── Finder ────────────────────────────────────────────────────────────────────
defaults write com.apple.finder AppleShowAllFiles -bool true          # show hidden files
defaults write com.apple.finder ShowPathbar -bool true                # show path bar
defaults write com.apple.finder ShowStatusBar -bool true              # show status bar
defaults write NSGlobalDomain AppleShowAllExtensions -bool true       # show all extensions

# ── Dock ──────────────────────────────────────────────────────────────────────
defaults write com.apple.dock autohide -bool true                     # auto-hide dock
defaults write com.apple.dock show-recents -bool false                # no recent apps
defaults write com.apple.dock tilesize -int 48

# ── Keyboard ──────────────────────────────────────────────────────────────────
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false    # key repeat over accents

# ── Trackpad ──────────────────────────────────────────────────────────────────
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1      # tap to click

# ── Screenshots ───────────────────────────────────────────────────────────────
defaults write com.apple.screencapture location -string "$HOME/Desktop"
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture disable-shadow -bool true

# ── Activity Monitor ──────────────────────────────────────────────────────────
defaults write com.apple.ActivityMonitor ShowCategory -int 0          # show all processes

# ── apply ─────────────────────────────────────────────────────────────────────
killall Finder Dock 2>/dev/null || true

info "macOS defaults applied"
