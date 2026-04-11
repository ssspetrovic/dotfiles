# .zshenv — loaded for ALL zsh sessions (login, interactive, scripts).
# Keep this minimal: PATH and essential env vars only.
# Anything interactive (aliases, prompt) goes in .zshrc.

# ── XDG base dirs ─────────────────────────────────────────────────────────────
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# ── Homebrew ──────────────────────────────────────────────────────────────────
if [[ -f /opt/homebrew/bin/brew ]]; then                     # macOS Apple Silicon
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then                      # macOS Intel
  eval "$(/usr/local/bin/brew shellenv)"
elif [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then      # Linux
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# ── local bin ─────────────────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# ── editor ────────────────────────────────────────────────────────────────────
export EDITOR="vim"
export VISUAL="vim"

# ── locale ────────────────────────────────────────────────────────────────────
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# ── pager ─────────────────────────────────────────────────────────────────────
export PAGER="less"
export LESS="-FRX --mouse"          # -F: quit if one screen, -R: colours, -X: no clear
# use delta as pager for git (also set in .gitconfig)
# if command -v delta &>/dev/null; then export GIT_PAGER="delta"; fi

# ── mise (runtime version manager) ───────────────────────────────────────────
# mise replaces nvm / pyenv / rbenv with a single tool
export MISE_DATA_DIR="$XDG_DATA_HOME/mise"

# ── python ────────────────────────────────────────────────────────────────────
export PYTHONDONTWRITEBYTECODE=1     # no .pyc files
export PYTHONUNBUFFERED=1            # unbuffered stdout/stderr
export PIP_REQUIRE_VIRTUALENV=1      # prevent accidental global pip installs
                                     # override with: PIP_REQUIRE_VIRTUALENV=0 pip install ...
# ── node ──────────────────────────────────────────────────────────────────────
export NODE_REPL_HISTORY="$XDG_DATA_HOME/node_repl_history"
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"

# ── docker ────────────────────────────────────────────────────────────────────
export DOCKER_BUILDKIT=1             # use BuildKit by default
export COMPOSE_DOCKER_CLI_BUILD=1    # also use BuildKit in compose

# ── kubernetes ────────────────────────────────────────────────────────────────
export KUBECONFIG="$HOME/.kube/config"
# To add multiple kubeconfigs: export KUBECONFIG="$HOME/.kube/config:$HOME/.kube/other"

# ── history (also set in .zshrc, but HISTFILE must be set early) ──────────────
export HISTFILE="$HOME/.zsh_history"

# ── less / man colours ────────────────────────────────────────────────────────
# (full colour setup is in .zshrc; this ensures PAGER works in non-interactive shells)
export MANPAGER="sh -c 'col -bx | bat -l man -p'" 2>/dev/null || export MANPAGER="less"

