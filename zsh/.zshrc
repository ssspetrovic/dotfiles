# .zshrc — interactive shell configuration

# ── profiling (uncomment to debug slow startup) ───────────────────────────────
# zmodload zsh/zprof

# ── history ───────────────────────────────────────────────────────────────────
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt HIST_IGNORE_DUPS       # don't record duplicates
setopt HIST_IGNORE_SPACE      # don't record lines starting with space
setopt HIST_VERIFY            # show before executing history expansion
setopt SHARE_HISTORY          # share history across sessions
setopt EXTENDED_HISTORY       # save timestamp + duration

# ── options ───────────────────────────────────────────────────────────────────
setopt AUTO_CD                # cd by typing directory name
setopt CORRECT                # correct typos in commands
setopt NO_CASE_GLOB           # case-insensitive globbing
setopt GLOB_COMPLETE          # don't insert first match; show completion menu
setopt EXTENDED_GLOB

# ── completion ────────────────────────────────────────────────────────────────
autoload -Uz compinit
# Regenerate compinit cache only once per day
if [[ -n "$HOME/.zcompdump"(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'  # case-insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*' rehash true                           # auto-find new executables

# ── kubectl completion ────────────────────────────────────────────────────────
if command -v kubectl &>/dev/null; then
  source <(kubectl completion zsh)
fi

# ── helm completion ───────────────────────────────────────────────────────────
if command -v helm &>/dev/null; then
  source <(helm completion zsh)
fi

# ── docker completion (via CLI plugin) ───────────────────────────────────────
# Docker Desktop ships its own completions; if using plain docker CLI:
if [[ -f /usr/share/zsh/vendor-completions/_docker ]]; then
  fpath+=(/usr/share/zsh/vendor-completions)
fi

# ── key bindings ──────────────────────────────────────────────────────────────
bindkey -e                               # emacs key bindings (change to -v for vi)
bindkey '^[[A' history-search-backward   # up arrow: history search
bindkey '^[[B' history-search-forward    # down arrow: history search
bindkey '^[[H' beginning-of-line         # home
bindkey '^[[F' end-of-line               # end
bindkey '^[[3~' delete-char              # delete
bindkey '^[[1;5C' forward-word           # Ctrl+right
bindkey '^[[1;5D' backward-word          # Ctrl+left

# ── sudo plugin (Esc Esc to prepend sudo) ────────────────────────────────────
# Reimplements the OMZ sudo plugin without the framework
_sudo_command_line() {
  [[ -z $BUFFER ]] && zle up-history
  if [[ $BUFFER == sudo\ * ]]; then
    LBUFFER="${LBUFFER#sudo }"
  elif [[ $BUFFER == $EDITOR\ * ]]; then
    LBUFFER="${LBUFFER#$EDITOR }"
    LBUFFER="sudoedit $LBUFFER"
  elif [[ $BUFFER == sudoedit\ * ]]; then
    LBUFFER="${LBUFFER#sudoedit }"
    LBUFFER="$EDITOR $LBUFFER"
  else
    LBUFFER="sudo $LBUFFER"
  fi
}
zle -N _sudo_command_line
bindkey '\e\e' _sudo_command_line    # Esc Esc

# ── colored man pages ─────────────────────────────────────────────────────────
export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'

# ── source aliases and functions ──────────────────────────────────────────────
[[ -f "$HOME/.aliases.zsh" ]] && source "$HOME/.aliases.zsh"
[[ -f "$HOME/.functions.zsh" ]] && source "$HOME/.functions.zsh"

# ── fzf ───────────────────────────────────────────────────────────────────────
if command -v fzf &>/dev/null; then
  source <(fzf --zsh)
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
fi

# ── zoxide (smarter cd, replaces z plugin) ────────────────────────────────────
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
fi

# ── direnv ────────────────────────────────────────────────────────────────────
if command -v direnv &>/dev/null; then
  eval "$(direnv hook zsh)"
fi

# ── mise (runtime version manager) ───────────────────────────────────────────
if command -v mise &>/dev/null; then
  eval "$(mise activate zsh)"
fi

# ── zsh-autosuggestions (installed via brew) ──────────────────────────────────
if [[ -f "$(brew --prefix 2>/dev/null)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'          # subtle grey
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)   # history first, then completion
  bindkey '^]' autosuggest-accept                 # Ctrl+] to accept suggestion
fi

# ── zsh-syntax-highlighting (must be last before prompt) ─────────────────────
if [[ -f "$(brew --prefix 2>/dev/null)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# ── pure prompt ───────────────────────────────────────────────────────────────
# Install: brew install pure (or: git clone https://github.com/sindresorhus/pure ~/.zsh/pure)
# Brew installs into site-functions; manual install needs fpath addition.
if [[ -d "$HOME/.zsh/pure" ]]; then
  # manual install path
  fpath+=("$HOME/.zsh/pure")
elif [[ -d "$(brew --prefix 2>/dev/null)/share/zsh/site-functions" ]]; then
  # brew install path (already in fpath via brew shellenv)
  :
fi

if autoload -Uz promptinit 2>/dev/null && promptinit 2>/dev/null; then
  zstyle ':prompt:pure:git:stash' show yes
  prompt pure
fi

# ── prompt timestamp ─────────────────────────────────────────────────────────
# Prints time on the right side of the terminal before each prompt.
# Pure renders its own right-prompt so we use RPROMPT with a precmd hook.
_prompt_timestamp() {
  RPROMPT="%F{242}%D{%H:%M:%S}%f"
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _prompt_timestamp

# ── machine-local overrides ───────────────────────────────────────────────────
# ~/.zshrc.local is gitignored — put machine-specific config here
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# ── profiling end (uncomment to debug slow startup) ───────────────────────────
# zprof
