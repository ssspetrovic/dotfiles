#!/usr/bin/env bash
# os/fedora.sh — Fedora-specific extras after core install
set -euo pipefail

info() { echo -e "\033[0;32m[fedora]\033[0m $*"; }

# ── enable RPM Fusion (free) — common need on Fedora ─────────────────────────
# Uncomment if you need codecs, drivers, etc.
# sudo dnf install -y \
#   "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm"

info "Fedora extras done (add distro-specific steps here)"
