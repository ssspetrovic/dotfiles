# dotfiles

Personal development environment for Ubuntu / Fedora / macOS.

**Stack:** zsh · vim · tmux · pure · chezmoi · Homebrew

---

## Quick Start

### Fresh machine (curl bootstrap)

```bash
curl -fsSL https://raw.githubusercontent.com/ssspetrovic/dotfiles/main/bootstrap.sh | bash
```

This will:
1. Install `git` via the native package manager if missing
2. Clone this repo to `~/.dotfiles`
3. Run `install.sh` — which handles everything including plugins

### Already cloned

```bash
cd ~/.dotfiles
bash install.sh
```

### Just the dotfiles (no package installs)

```bash
cd ~/.dotfiles
bash scripts/apply_dotfiles.sh
```

---

## What Gets Installed

### Native package manager (apt / dnf / xcode-select)
Core system tools only: `git`, `curl`, `wget`, `zsh`, `vim`, `tmux`, plus the platform compiler toolchain (`build-essential` on Ubuntu/Debian; `gcc`/`make` on Fedora).

### Homebrew (all platforms)
Dev tooling via `brew/Brewfile`. Highlights:

| Tool        | Purpose                                            |
| ----------- | -------------------------------------------------- |
| `pure`      | Minimal zsh prompt                                 |
| `zoxide`    | Smarter `cd`                                       |
| `eza`       | Modern `ls`                                        |
| `bat`       | `cat` with syntax highlighting                     |
| `ripgrep`   | Fast `grep`                                        |
| `fd`        | Fast `find`                                        |
| `fzf`       | Fuzzy finder                                       |
| `delta`     | Better git diffs                                   |
| `mise`      | Runtime version manager (replaces nvm/pyenv/rbenv) |
| `lazygit`   | Terminal git UI                                    |
| `gh`        | GitHub CLI                                         |
| `kubectl`   | Kubernetes CLI                                     |
| `helm`      | Kubernetes package manager                         |
| `k9s`       | Terminal Kubernetes UI                             |
| `btop`      | Modern top                                         |
| `fastfetch` | Display OS logo and PC specs                       |

`chezmoi` is also installed via the Brewfile and is used by `install.sh` / `scripts/apply_dotfiles.sh` to manage the dotfiles themselves.

### dotfiles (via chezmoi)

| Target | Managed files                                                 |
| ------ | ------------------------------------------------------------- |
| `zsh`  | `~/.zshrc`, `~/.zshenv`, `~/.aliases.zsh`, `~/.functions.zsh` |
| `vim`  | `~/.vimrc`                                                    |
| `tmux` | `~/.tmux.conf`                                                |
| `git`  | `~/.gitconfig`, `~/.gitignore_global`                         |

---

## Directory Structure

```
dotfiles/
├── bootstrap.sh        # curl-able entry point
├── install.sh          # main orchestrator (runs all steps including plugins)
├── brew/
│   └── Brewfile        # all Homebrew packages
├── chezmoi/            # chezmoi source state for files under $HOME
│   ├── dot_aliases.zsh
│   ├── dot_functions.zsh
│   ├── dot_gitconfig
│   ├── dot_gitignore_global
│   ├── dot_tmux.conf
│   ├── dot_vimrc
│   ├── dot_zshenv
│   └── dot_zshrc
├── os/
│   ├── macos.sh        # macOS defaults
│   ├── ubuntu.sh       # Ubuntu extras (locale, etc.)
│   └── fedora.sh       # Fedora extras
└── scripts/
    ├── detect_os.sh    # sets $OS / $DISTRO
    ├── apply_dotfiles.sh
    ├── install_brew.sh
    └── install_packages.sh
```

---

## Per-Machine Configuration

Some things intentionally don't live in this repo:

### Git identity
`~/.gitconfig` includes `~/.gitconfig.local` which is machine-specific and never committed:

```ini
# ~/.gitconfig.local
[user]
  name = Your Name
  email = you@example.com

# work machine example:
# [url "git@github.com-work:"]
#   insteadOf = git@github.com:
```

### Machine-specific zsh config
Add a `~/.zshrc.local` for anything machine-specific. It is sourced at the end of `.zshrc` if it exists.

---

## Adding a New Tool

1. Create the chezmoi source entry mirroring the target path in `$HOME`:
   ```
   chezmoi/dot_config/newtool/config.toml
   ```
2. Run `bash scripts/apply_dotfiles.sh` to apply

---

## Updating

```bash
cd ~/.dotfiles
git pull
bash install.sh        # re-runs everything idempotently
```

Or just apply dotfiles:
```bash
bash scripts/apply_dotfiles.sh
```

Or update brew packages:
```bash
brew bundle --file=~/.dotfiles/brew/Brewfile
```

Or update vim/tmux plugins manually:
```bash
vim -Es -u ~/.vimrc +PlugUpdate +qall
~/.tmux/plugins/tpm/bin/update_plugins all
```

---

## Key Bindings Reference

### tmux (prefix: `Ctrl-a`)

| Key              | Action                     |
| ---------------- | -------------------------- |
| `prefix \|`      | Split horizontal           |
| `prefix -`       | Split vertical             |
| `prefix h/j/k/l` | Navigate panes             |
| `prefix H/J/K/L` | Resize panes               |
| `prefix r`       | Reload config              |
| `prefix I`       | Install/update TPM plugins |

### vim (leader: `Space`)

| Key            | Action             |
| -------------- | ------------------ |
| `<leader>f`    | Fuzzy find files   |
| `<leader>b`    | Fuzzy find buffers |
| `<leader>g`    | Grep (ripgrep)     |
| `<leader>w`    | Save               |
| `Ctrl-h/j/k/l` | Navigate splits    |

### zsh

| Key        | Action                          |
| ---------- | ------------------------------- |
| `Ctrl-r`   | fzf history search              |
| `Ctrl-t`   | fzf file search                 |
| `Alt-c`    | fzf cd                          |
| `Esc Esc`  | Prepend sudo to current command |
| `z <name>` | zoxide jump                     |

---

## Troubleshooting

**chezmoi conflicts:** `scripts/apply_dotfiles.sh` runs `chezmoi apply --less-interactive`, so chezmoi will prompt before overwriting pre-existing targets or files changed since the last apply. Use `chezmoi diff --source ~/.dotfiles/chezmoi` to inspect the pending changes first.

**brew not found after install:** Run `exec zsh` or open a new terminal to pick up the updated PATH from `.zshenv`.

**Locale error on Ubuntu:** Run `sudo locale-gen en_US.UTF-8 && sudo update-locale LANG=en_US.UTF-8` then re-login.

**Icons look broken:** Install one of the Nerd Fonts (NF) and use set it as the main font in your terminal of choice.
