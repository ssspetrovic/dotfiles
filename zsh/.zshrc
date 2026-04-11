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

# Fix insecure completion dirs silently (common on brew systems)
zstyle ':completion:*' rehash true
compinit -d "$HOME/.zcompdump"

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'

# ── fzf-tab (better completion UI) ────────────────────────────────────────────
if [[ -f "$(brew --prefix 2>/dev/null)/opt/fzf-tab/share/fzf-tab/fzf-tab.plugin.zsh" ]]; then
  source "$(brew --prefix)/opt/fzf-tab/share/fzf-tab/fzf-tab.plugin.zsh"
fi

# ── kubectl completion ────────────────────────────────────────────────────────
if command -v kubectl &>/dev/null; then
  source <(kubectl completion zsh)
fi

# ── helm completion ───────────────────────────────────────────────────────────
if command -v helm &>/dev/null; then
  source <(helm completion zsh)
fi

# ── docker completion ─────────────────────────────────────────────────────────
if [[ -f /usr/share/zsh/vendor-completions/_docker ]]; then
  fpath+=(/usr/share/zsh/vendor-completions)
fi

# ── history search fix ────────────────────────────────────────────────────────
autoload -Uz up-line-or-beginning-search
autoload -Uz down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# ── key bindings ──────────────────────────────────────────────────────────────
bindkey -e
bindkey '^[[A' up-line-or-beginning-search   # Up arrow
bindkey '^[[B' down-line-or-beginning-search # Down arrow
bindkey '^[[H' beginning-of-line         # home
bindkey '^[[F' end-of-line               # end
bindkey '^[[3~' delete-char              # delete
bindkey '^[[1;5C' forward-word           # Ctrl+right
bindkey '^[[1;5D' backward-word          # Ctrl+left

# ── sudo widget (Esc Esc) ─────────────────────────────────────────────────────
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
bindkey '\e\e' _sudo_command_line

# ── colored man pages ─────────────────────────────────────────────────────────
export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'
export MANPAGER="less -R"

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

# ── zoxide ────────────────────────────────────────────────────────────────────
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
fi

# ── direnv ────────────────────────────────────────────────────────────────────
if command -v direnv &>/dev/null; then
  eval "$(direnv hook zsh)"
fi

# ── mise ──────────────────────────────────────────────────────────────────────
if command -v mise &>/dev/null; then
  eval "$(mise activate zsh)"
fi

# ── zsh-autosuggestions ───────────────────────────────────────────────────────
if [[ -f "$(brew --prefix 2>/dev/null)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
  bindkey '^]' autosuggest-accept
fi

# ── zsh-syntax-highlighting ───────────────────────────────────────────────────
if [[ -f "$(brew --prefix 2>/dev/null)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# ── pure prompt ───────────────────────────────────────────────────────────────
if [[ -d "$HOME/.zsh/pure" ]]; then
  fpath+=("$HOME/.zsh/pure")
fi

if autoload -Uz promptinit 2>/dev/null && promptinit 2>/dev/null; then
  zstyle ':prompt:pure:git:stash' show yes
  prompt pure
fi

# ── prompt timestamp ─────────────────────────────────────────────────────────
_prompt_timestamp() {
  RPROMPT="%F{8}%D{%H:%M:%S}%f"
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _prompt_timestamp

# ── machine-local overrides ───────────────────────────────────────────────────
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# ── profiling end (uncomment to debug slow startup) ───────────────────────────
# zprof
