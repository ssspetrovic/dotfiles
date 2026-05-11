mkcd() {
  if [[ $# -ne 1 ]]; then
    echo "usage: mkcd <directory>" >&2
    return 2
  fi

  local directory="$1"
  mkdir -p "$directory" && cd "$directory"
}

extract() {
  if [[ $# -ne 1 ]]; then
    echo "usage: extract <archive>" >&2
    return 2
  fi

  local archive="$1"
  if [[ ! -f "$archive" ]]; then
    echo "'$archive' is not a valid file" >&2
    return
  fi

  case "$archive" in
    *.tar.bz2) tar xjf "$archive" ;;
    *.tar.gz) tar xzf "$archive" ;;
    *.bz2) bunzip2 "$archive" ;;
    *.rar) unrar x "$archive" ;;
    *.gz) gunzip "$archive" ;;
    *.tar) tar xf "$archive" ;;
    *.tbz2) tar xjf "$archive" ;;
    *.tgz) tar xzf "$archive" ;;
    *.zip) unzip "$archive" ;;
    *.Z) uncompress "$archive" ;;
    *.7z) 7z x "$archive" ;;
    *) echo "cannot extract '$archive'" >&2 ;;
  esac
}
