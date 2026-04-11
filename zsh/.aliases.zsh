# .aliases.zsh — shell aliases, sourced by .zshrc

# ── navigation ────────────────────────────────────────────────────────────────
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'

# ── ls → eza ──────────────────────────────────────────────────────────────────
if command -v eza &>/dev/null; then
  alias ls='eza --icons'
  alias ll='eza -lah --icons --git'
  alias la='eza -a --icons'
  alias lt='eza --tree --icons --level=2'
  alias llt='eza -lah --tree --icons --git --level=2'
else
  alias ls='ls --color=auto'
  alias ll='ls -lahF'
  alias la='ls -A'
fi

# ── cat → bat ─────────────────────────────────────────────────────────────────
if command -v bat &>/dev/null; then
  alias cat='bat --paging=never'
  alias less='bat'
fi

# ── grep → ripgrep ────────────────────────────────────────────────────────────
if command -v rg &>/dev/null; then
  alias grep='rg'
fi

# ── git ───────────────────────────────────────────────────────────────────────
alias g='git'
alias gs='git status -sb'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias glog='git log --oneline --graph --decorate --all'
alias gco='git checkout'
alias gbr='git branch'

# ── dotfiles ──────────────────────────────────────────────────────────────────
alias dotfiles='cd ~/dotfiles'
alias dot='cd ~/dotfiles'

# ── system ────────────────────────────────────────────────────────────────────
alias reload='source ~/.zshrc'
alias path='echo $PATH | tr ":" "\n"'
alias ports='ss -tulpn'         # listening ports (use netstat on macOS)
alias df='duf 2>/dev/null || df -h'
alias du='dust 2>/dev/null || du -sh'
alias ps='procs 2>/dev/null || ps aux'
alias top='btm 2>/dev/null || htop 2>/dev/null || top'

# ── editor ────────────────────────────────────────────────────────────────────
alias v='vim'
alias nv='nvim'

# ── kubernetes ────────────────────────────────────────────────────────────────
alias kc='kubectl'
alias kca='kubectl apply -f'
alias kcd='kubectl describe'
alias kcdel='kubectl delete'
alias kcg='kubectl get'
alias kcgp='kubectl get pods'
alias kcgs='kubectl get services'
alias kcgn='kubectl get nodes'
alias kcl='kubectl logs'
alias kclf='kubectl logs -f'
alias kcex='kubectl exec -it'
alias kcns='kubens'            # kubectx companion for namespaces
alias kcctx='kubectx'          # switch cluster contexts

# ── docker ────────────────────────────────────────────────────────────────────
alias d='docker'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'
alias dlogs='docker logs -f'
alias dprune='docker system prune -af --volumes'
alias dc='docker compose'
alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias dcl='docker compose logs -f'

# ── misc ──────────────────────────────────────────────────────────────────────
alias cls='clear'
alias please='sudo'
alias myip='curl -s https://icanhazip.com'
alias weather='curl -s "wttr.in?format=3"'
