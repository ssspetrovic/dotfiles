# .functions.zsh — shell functions, sourced by .zshrc

# ── mkcd: mkdir + cd in one step ──────────────────────────────────────────────
mkcd() { mkdir -p "$1" && cd "$1"; }

# ── extract: universal archive extractor ─────────────────────────────────────
extract() {
  if [[ -z "$1" ]]; then
    echo "Usage: extract <archive>"
    return 1
  fi
  if [[ ! -f "$1" ]]; then
    echo "extract: '$1' is not a file"
    return 1
  fi
  case "$1" in
    *.tar.bz2) tar xjf "$1"         ;;
    *.tar.gz)  tar xzf "$1"         ;;
    *.tar.xz)  tar xJf "$1"         ;;
    *.tar.zst) tar --zstd -xf "$1"  ;;
    *.tar)     tar xf "$1"          ;;
    *.bz2)     bunzip2 "$1"         ;;
    *.gz)      gunzip "$1"          ;;
    *.zip)     unzip "$1"           ;;
    *.7z)      7z x "$1"            ;;
    *.rar)     unrar x "$1"         ;;
    *)         echo "extract: unknown archive format '$1'" ; return 1 ;;
  esac
}

# ── fcd: fzf-powered cd ───────────────────────────────────────────────────────
fcd() {
  local dir
  dir=$(fd --type d --hidden --exclude .git 2>/dev/null | fzf --preview 'eza --tree --level=2 {}') && cd "$dir"
}

# ── fkill: fzf-powered process killer ────────────────────────────────────────
fkill() {
  local pid
  pid=$(ps aux | fzf --header='Select process to kill' | awk '{print $2}')
  [[ -n "$pid" ]] && kill -9 "$pid" && echo "Killed $pid"
}

# ── up: go up N directories ───────────────────────────────────────────────────
up() {
  local count="${1:-1}"
  local path=""
  for _ in $(seq 1 "$count"); do path="../$path"; done
  cd "$path" || return
}

# ── serve: quick HTTP server in current dir ───────────────────────────────────
serve() {
  local port="${1:-8000}"
  echo "Serving http://localhost:$port"
  python3 -m http.server "$port"
}

# ── gitignore: fetch .gitignore from gitignore.io ─────────────────────────────
gitignore() {
  curl -sL "https://www.toptal.com/developers/gitignore/api/$*"
}

# ── brew-dump: update Brewfile with current packages ─────────────────────────
brew-dump() {
  brew bundle dump --file="$HOME/dotfiles/brew/Brewfile" --force
  echo "Brewfile updated"
}
