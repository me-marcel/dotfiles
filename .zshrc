# Fedora Web Development ZSH Configuration
# Optimized for Angular, Laravel, and DevOps tasks

# Path to your oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Theme setting
ZSH_THEME="bira"

# Uncomment the following line to use case-sensitive completion
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion
# Case-sensitive completion must be off. _ and - will be interchangeable
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days)
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion
# You can also set it to another string to have that shown instead of the default red dots
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Plugins
plugins=(
    git
    zsh-autosuggestions
    zsh-completions
    docker
    npm
    composer
    laravel
    node
    vscode
    history
    extract
    sudo
    web-search
    copypath
    dirhistory
    jsontools
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# User configuration

# Export PATH
export PATH=$HOME/bin:/usr/local/bin:$PATH

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS

# Better directory navigation
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_MINUS

# Better completion
autoload -U compinit
compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Key bindings
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# Aliases for better tools
alias cat='bat'
alias grep='rg'
alias find='fd'
alias top='htop'
alias man='tldr'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gb='git branch'
alias gd='git diff'
alias glog='git log --oneline --graph --decorate'

# Docker aliases
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'
alias dlogs='docker logs'
alias dstop='docker stop'
alias drm='docker rm'
alias drmi='docker rmi'

# Docker Desktop aliases
alias dd='docker-desktop'
alias dd-start='docker-desktop --start'
alias dd-stop='docker-desktop --stop'
alias dd-restart='docker-desktop --restart'
alias dd-status='docker-desktop --status'

# Node.js and npm aliases
alias n='npm'
alias ni='npm install'
alias nid='npm install --save-dev'
alias nrb='npm run build'
alias nrd='npm run dev'
alias nrs='npm run start'
alias nrt='npm run test'
alias nge='ng e2e'

# NVM aliases and functions
alias nvmls='nvm list'
alias nvmuse='nvm use'
alias nvminstall='nvm install'
alias nvmcurrent='nvm current'
alias nvmdefault='nvm alias default'

# Function to install and use a specific Node.js version
function nvmsetup() {
    if [ -z "$1" ]; then
        echo "Usage: nvmsetup <version>"
        echo "Example: nvmsetup 18.17.0"
        return 1
    fi
    
    echo "Installing Node.js version $1..."
    nvm install $1
    nvm use $1
    nvm alias default $1
    echo "Node.js $1 is now the default version"
}

# Function to quickly switch to LTS version
function nvmlts() {
    echo "Installing and switching to Node.js LTS..."
    nvm install --lts
    nvm use --lts
    nvm alias default node
    echo "Node.js LTS is now the default version"
}

# Angular CLI aliases
alias ng='npx @angular/cli'
alias nga='ng generate'
alias ngs='ng serve'
alias ngb='ng build'
alias ngt='ng test'

# Laravel and PHP aliases
alias art='php artisan'
alias artm='php artisan make:'
alias artc='php artisan cache:clear'
alias artcc='php artisan config:clear'
alias artcr='php artisan config:cache'
alias artro='php artisan route:list'
alias artmig='php artisan migrate'
alias artseed='php artisan db:seed'
alias artserve='php artisan serve'

# Composer aliases
alias c='composer'
alias ci='composer install'
alias cu='composer update'
alias cr='composer require'
alias crd='composer require --dev'
alias crm='composer remove'
alias cdu='composer dump-autoload'

# Python and pyenv aliases
alias py='python3'
alias pip='pip3'
alias pyenvls='pyenv versions'
alias pyenvuse='pyenv local'
alias pyenvglobal='pyenv global'
alias pyenvinstall='pyenv install'
alias pyenvcurrent='pyenv version'

# pipx aliases
alias px='pipx'
alias pxls='pipx list'
alias pxinstall='pipx install'
alias pxuninstall='pipx uninstall'
alias pxupgrade='pipx upgrade'

# direnv aliases
alias de='direnv'
alias deallow='direnv allow'
alias dedeny='direnv deny'
alias dereload='direnv reload'

# Conventional commits aliases
alias cz='cz'
alias czinit='cz init'
alias czcommit='cz commit'
alias czbump='cz bump'

# Development directory shortcuts
alias dev='cd ~/Development'
alias projects='cd ~/Projects'
alias work='cd ~/Work'

# System aliases
alias update='sudo dnf update'
alias upgrade='sudo dnf upgrade'
alias install='sudo dnf install'
alias remove='sudo dnf remove'
alias search='sudo dnf search'

# Network and web development
alias myip='curl -s https://ipinfo.io/ip'
alias weather='curl -s wttr.in'
alias ports='netstat -tulanp'

# File operations
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias mkdir='mkdir -p'

# Quick navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# Quick file editing
alias zshrc='code ~/.zshrc'
alias bashrc='code ~/.bashrc'

# Browser aliases
alias brave='brave-browser'
alias browser='brave-browser'

# Office application aliases
alias word='wps'
alias excel='et'
alias powerpoint='wpp'
alias office='wps'

# Development application aliases
alias dbeaver='dbeaver-ce'
alias db='dbeaver-ce'
alias postman='postman'
alias api='postman'

# PDF viewer aliases
alias pdf='okular'
alias viewer='okular'

# Monitoring and system tools aliases
alias top='btop'
alias htop='btop'
alias ps='procs'
alias df='duf'
alias iostat='iotop'

# Terminal multiplexer aliases
alias t='tmux'
alias ta='tmux attach'
alias tl='tmux list-sessions'
alias tn='tmux new-session'
alias tk='tmux kill-session'

# Screen aliases
alias s='screen'
alias sa='screen -r'
alias sl='screen -ls'
alias sn='screen -S'
alias sk='screen -X quit'

# File synchronization aliases
alias sync='rsync -avz --progress'
alias sync-dry='rsync -avzn --progress'
alias rclone-sync='rclone sync --progress'
alias rclone-copy='rclone copy --progress'

# Utility functions
function mkcd() {
    mkdir -p "$1" && cd "$1"
}

function extract() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)          echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# FZF configuration
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --exclude node_modules --exclude vendor'

# Node.js version management
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Zoxide initialization
eval "$(zoxide init zsh)"

# pyenv initialization
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"

# direnv initialization
eval "$(direnv hook zsh)"

# PHP version management
export PATH="$HOME/.composer/vendor/bin:$PATH"

# Environment variables
export EDITOR='code'
export VISUAL='code'
export BROWSER='brave-browser'

# Laravel specific
export COMPOSER_MEMORY_LIMIT=-1

# Node.js specific
export NODE_ENV=development

# Python specific
export PYTHONPATH="$HOME/.local/lib/python3.*/site-packages:$PYTHONPATH"
export PIP_USER=yes
export PIP_REQUIRE_VIRTUALENV=false

# Docker specific
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

# Load local configuration if exists
if [ -f ~/.zshrc.local ]; then
    source ~/.zshrc.local
fi

# DevOps tool aliases
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kgn='kubectl get nodes'
alias kga='kubectl get all'
alias kd='kubectl describe'
alias kl='kubectl logs'
alias kaf='kubectl apply -f'
alias kdf='kubectl delete -f'
alias kctx='kubectl config use-context'
alias kns='kubectl config set-context --current --namespace'

alias h='helm'
alias hls='helm list'
alias hsr='helm search repo'
alias hi='helm install'
alias hu='helm upgrade'
alias hd='helm delete'

alias fluxs='flux status'
alias fluxc='flux check'
alias fluxa='flux apply'
alias fluxg='flux get'

alias k9='k9s'

# Infrastructure and Configuration Management aliases
alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfd='terraform destroy'
alias tfw='terraform workspace'
alias tfo='terraform output'
alias tfs='terraform state'

alias ans='ansible'
alias ansb='ansible-playbook'
alias ansg='ansible-galaxy'
alias ansv='ansible-vault'

# Redis aliases
alias redis='redis-cli'
alias redis-monitor='redis-cli monitor'
alias redis-info='redis-cli info'
alias redis-keys='redis-cli keys "*"'
alias redis-flush='redis-cli flushall'

# MySQL aliases
alias mysql='mysql -u root -p'
alias mysql-dev='mysql -h localhost -u root -p'
alias mysql-prod='mysql -h production-host -u user -p'
alias mysql-dump='mysqldump -u root -p'
alias mysql-restore='mysql -u root -p'

# MongoDB aliases
alias mongo='mongosh'
alias mongo-dev='mongosh mongodb://localhost:27017'
alias mongo-prod='mongosh mongodb://production-host:27017'
alias mongo-dump='mongodump'
alias mongo-restore='mongorestore'

# AWS CLI aliases
alias aws='aws'
alias aws-ss='aws-sso-util login'
alias aws-ssc='aws-sso-util configure'
alias aws-ssr='aws-sso-util logout'
alias aws-sss='aws-sso-util session'

# GitHub Copilot CLI aliases
alias copilot='gh copilot'
alias chat='gh copilot'
alias copilot-suggest='gh copilot suggest'
alias chat-suggest='gh copilot suggest'
alias copilot-explain='gh copilot explain'
alias chat-explain='gh copilot explain'
alias copilot-test='gh copilot test'
alias chat-test='gh copilot test'
alias copilot-fix='gh copilot fix'
alias chat-fix='gh copilot fix'

# kubectx and kubens aliases
alias kx='kubectx'
alias kn='kubens'

# kubectl completion
if command -v kubectl &>/dev/null; then
  source <(kubectl completion zsh)
fi

# helm completion
if command -v helm &>/dev/null; then
  source <(helm completion zsh)
fi

# flux completion
if command -v flux &>/dev/null; then
  source <(flux completion zsh)
fi

# AWS CLI completion
if command -v aws &>/dev/null; then
  complete -C '/usr/local/bin/aws_completer' aws
fi

# Terraform completion
if command -v terraform &>/dev/null; then
  complete -o nospace -C terraform terraform
fi

# Ansible completion
if command -v ansible &>/dev/null; then
  complete -W "help version" ansible
fi

# Redis completion
if command -v redis-cli &>/dev/null; then
  complete -W "ping echo select quit exit auth info client list config get set del keys exists expire ttl type" redis-cli
fi

# MySQL completion
if command -v mysql &>/dev/null; then
  complete -W "show use select insert update delete create drop alter describe explain" mysql
fi

# MongoDB completion
if command -v mongosh &>/dev/null; then
  complete -W "show use find insert update delete create drop" mongosh
fi 

# Screenfetch
screenfetch
