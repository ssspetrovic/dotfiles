if command -v eza &>/dev/null; then
  alias ls='eza --icons'
  alias ll='eza -lah --icons --git'
  alias la='eza -a --icons'
  alias lt='eza --tree --icons'
elif [[ "$OSTYPE" == darwin* ]]; then
  alias ls='ls -G'
  alias ll='ls -lahG'
  alias la='ls -aG'
  alias lt='find . -print'
else
  alias ls='ls --color=auto'
  alias ll='ls -lah --color=auto'
  alias la='ls -a --color=auto'
  alias lt='find . -print'
fi
alias l='ls'

# alias cat='bat'

alias v='vim'
alias vi='vim'

alias c='clear'
alias q='exit'

alias g='git'
alias k='kubectl'
alias tf='terraform'
