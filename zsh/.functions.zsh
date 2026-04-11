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

# ── web-search: search the web from the terminal ─────────────────────────────
# Usage: google foo bar | github sindresorhus | ddg privacy tools
_web_search() {
  local engine="$1"; shift
  local query="${(j:+:)@}"   # join args with +
  local url

  case "$engine" in
    google)    url="https://www.google.com/search?q=${query}" ;;
    ddg|duck)  url="https://duckduckgo.com/?q=${query}" ;;
    github)    url="https://github.com/search?q=${query}" ;;
    yt|youtube) url="https://www.youtube.com/results?search_query=${query}" ;;
    maps)      url="https://maps.google.com/maps?q=${query}" ;;
    wiki)      url="https://en.wikipedia.org/w/index.php?search=${query}" ;;
    *)         echo "web-search: unknown engine '$engine'"; return 1 ;;
  esac

  # open in browser — works on macOS, Linux (xdg-open), and WSL2 (explorer.exe)
  if command -v xdg-open &>/dev/null; then
    xdg-open "$url"
  elif command -v open &>/dev/null; then
    open "$url"
  elif command -v explorer.exe &>/dev/null; then
    explorer.exe "$url"
  else
    echo "Open: $url"
  fi
}

google()  { _web_search google "$@" }
ddg()     { _web_search ddg "$@" }
duck()    { _web_search ddg "$@" }
github()  { _web_search github "$@" }
youtube() { _web_search yt "$@" }
yt()      { _web_search yt "$@" }
maps()    { _web_search maps "$@" }
wiki()    { _web_search wiki "$@" }