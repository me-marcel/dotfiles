export ZSH="$HOME/.oh-my-zsh"
export EDITOR="code"
export VISUAL="code"
export PAGER="less"

ZSH_THEME="agnoster"

plugins=(
  git
  fzf
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
  sudo
  extract
)

source "$ZSH/oh-my-zsh.sh"

HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt EXTENDED_HISTORY

autoload -U compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

bindkey -e
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

export FZF_DEFAULT_OPTS='--height=45% --layout=reverse --border --color=fg:#d7d7d7,bg:#1e1e1e,hl:#ff9f1c'

alias ls='eza --group-directories-first --icons=auto'
alias ll='eza -la --group-directories-first --icons=auto'
alias cat='bat'
alias grep='rg'
alias find='fd'
alias t='tmux'
alias ta='tmux attach -t main'
alias gs='git status -sb'
alias gl='git log --oneline --graph --decorate --all'

if [[ -o interactive ]] && [[ -z "${TMUX:-}" ]] && command -v tmux >/dev/null 2>&1; then
  tmux attach-session -t main 2>/dev/null || tmux new-session -s main
fi
