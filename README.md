# dotfiles

Personal development environment for Ubuntu / Fedora / macOS.

**Stack:** zsh · vim · tmux · starship · GNU stow · Homebrew

---

## Quick Start

### Fresh machine (curl bootstrap)

```bash
curl -fsSL https://raw.githubusercontent.com/ssspetrovic/dotfiles/main/bootstrap.sh | bash
```

This will:
1. Install `git` via the native package manager if missing
2. Clone this repo to `~/dotfiles`
3. Run `install.sh`

### Already cloned

```bash
cd ~/dotfiles
bash install.sh
```

### Just the dotfiles (no package installs)

```bash
cd ~/dotfiles
bash scripts/symlink.sh
```

---

## What Gets Installed

### Native package manager (apt / dnf / xcode-select)
Core system tools only: `git`, `curl`, `wget`, `zsh`, `vim`, `tmux`, `stow`, `build-essential`

### Homebrew (all platforms)
Dev tooling via `brew/Brewfile`. Highlights:

| Tool | Purpose |
|---|---|
| `starship` | Cross-shell prompt |
| `zoxide` | Smarter `cd` |
| `eza` | Modern `ls` |
| `bat` | `cat` with syntax highlighting |
| `ripgrep` | Fast `grep` |
| `fd` | Fast `find` |
| `fzf` | Fuzzy finder |
| `delta` | Better git diffs |
| `mise` | Runtime version manager (replaces nvm/pyenv/rbenv) |
| `lazygit` | Terminal git UI |
| `gh` | GitHub CLI |

### dotfiles (via GNU stow)

| Package | Links |
|---|---|
| `zsh` | `~/.zshrc`, `~/.zshenv`, `~/.aliases.zsh`, `~/.functions.zsh` |
| `vim` | `~/.vimrc` |
| `tmux` | `~/.tmux.conf` |
| `git` | `~/.gitconfig`, `~/.gitignore_global` |
| `starship` | `~/.config/starship.toml` |

---

## Directory Structure

```
dotfiles/
├── bootstrap.sh        # curl-able entry point
├── install.sh          # main orchestrator
├── brew/
│   └── Brewfile        # all Homebrew packages
├── git/
│   ├── .gitconfig
│   └── .gitignore_global
├── os/
│   ├── macos.sh        # macOS defaults
│   ├── ubuntu.sh       # Ubuntu extras
│   └── fedora.sh       # Fedora extras
├── scripts/
│   ├── detect_os.sh    # sets $OS / $DISTRO
│   ├── install_brew.sh
│   ├── install_packages.sh
│   └── symlink.sh      # runs stow
├── starship/
│   └── .config/
│       └── starship.toml
├── tmux/
│   └── .tmux.conf
├── vim/
│   └── .vimrc
└── zsh/
    ├── .zshrc
    ├── .zshenv
    ├── .aliases.zsh
    └── .functions.zsh
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

1. Create the stow package directory mirroring `$HOME`:
   ```
   newtool/
   └── .config/
       └── newtool/
           └── config.toml
   ```
2. Add `newtool` to `STOW_PACKAGES` in `scripts/symlink.sh`
3. Run `bash scripts/symlink.sh` to apply

---

## Updating

```bash
cd ~/dotfiles
git pull
bash install.sh        # re-runs everything idempotently
```

Or just re-stow dotfiles:
```bash
bash scripts/symlink.sh
```

Or update brew packages:
```bash
brew bundle --file=~/dotfiles/brew/Brewfile
```

---

## Key Bindings Reference

### tmux (prefix: `Ctrl-a`)

| Key | Action |
|---|---|
| `prefix \|` | Split horizontal |
| `prefix -` | Split vertical |
| `prefix h/j/k/l` | Navigate panes |
| `prefix H/J/K/L` | Resize panes |
| `prefix r` | Reload config |
| `prefix I` | Install TPM plugins |

### vim (leader: `Space`)

| Key | Action |
|---|---|
| `<leader>f` | Fuzzy find files |
| `<leader>b` | Fuzzy find buffers |
| `<leader>g` | Grep (ripgrep) |
| `<leader>w` | Save |
| `Ctrl-h/j/k/l` | Navigate splits |

### zsh

| Key | Action |
|---|---|
| `Ctrl-r` | fzf history search |
| `Ctrl-t` | fzf file search |
| `Alt-c` | fzf cd |
| `z <name>` | zoxide jump |

---

## Troubleshooting

**stow conflicts:** If `symlink.sh` fails with a conflict, check for existing non-symlinked files. The script backs them up as `.bak.TIMESTAMP` automatically.

**brew not found after install:** Run `exec zsh` or open a new terminal to pick up the updated PATH from `.zshenv`.

**TPM plugins not loading:** Inside tmux, press `prefix + I` to install plugins for the first time.

**vim plugins not loading:** Run `:PlugInstall` inside vim the first time.
