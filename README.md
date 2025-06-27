# Fedora Dotfiles

A comprehensive set of dotfiles for web development with Angular and Laravel on Fedora Workstation 42 with GNOME.

## Features

- **ZSH with Oh My Zsh**: Powerful shell with extensive plugin ecosystem
- **Custom Tokyo Night Theme**: Beautiful dark theme for both terminal and shell
- **JetBrains Mono Font**: Professional coding font
- **Brave Browser**: Privacy-focused browser set as default
- **VS Code**: Full-featured editor with 42 essential extensions
- **GitHub Copilot**: AI-powered code completion for VS Code and CLI
- **Obsidian**: Knowledge management and note-taking
- **DBeaver Community Edition**: Universal database management tool
- **Postman**: API development and testing platform
- **WPS Office**: Microsoft Office-compatible suite (replaces LibreOffice, set as default for all supported file types)
- **PDF Viewer**: Okular for PDF viewing and annotation
- **Development Tools**: Node.js, PHP, Composer, Python, pyenv, Docker Desktop, and more
- **Environment Management**: direnv for project-specific variables, pipx for Python tools
- **Git Workflow**: Conventional commits with commitizen and pre-commit hooks
- **Infrastructure Tools**: Terraform for IaC, Ansible for configuration management, Redis CLI for caching
- **Database Tools**: MySQL and MongoDB CLI tools for database management (servers not included)
- **System Monitoring**: btop, iotop, glances, procs, duf for comprehensive monitoring
- **Terminal Multiplexers**: tmux and screen for complex workflows
- **Smart Navigation**: zoxide for AI-powered directory jumping
- **File Synchronization**: rsync and rclone for data management
- **Modern CLI Tools**: exa, bat, fd, ripgrep, fzf for better productivity
- **Git Configuration**: Optimized with useful aliases and settings
- **Comprehensive Aliases**: Shortcuts for Angular, Laravel, Docker, and general development

## Installation

1. Clone this repository:
   ```bash
   git clone <your-repo-url>
   cd dotfiles
   ```

2. Make the setup script executable and run it:
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

3. Log out and log back in for ZSH to become your default shell

4. Update your Git configuration:
   ```bash
   code ~/.gitconfig
   # Update name and email in the [user] section
   ```

## What's Included

### Terminal Setup
- **JetBrains Mono Font**: Professional coding font
- **Tokyo Night Theme**: Beautiful dark color scheme
- **Custom Keybindings**: Optimized for development workflow

### Shell Configuration
- **ZSH**: Set as default shell
- **Oh My Zsh**: Framework for managing ZSH configuration
- **Custom Tokyo Night Theme**: Matches terminal color scheme
- **Useful Plugins**: 
  - zsh-autosuggestions
  - zsh-syntax-highlighting
  - zsh-completions
  - git, docker, npm, composer, laravel, node, vscode

### Development Tools
- **Node.js & npm**: For Angular and JavaScript development
- **NVM**: Node Version Manager for dynamic Node.js version switching
- **PHP & Composer**: For Laravel development
- **Python & pyenv**: For Python development and version management
- **Docker & Docker Compose**: For containerized development (via Docker Desktop)
- **Environment Management**: direnv for project variables, pipx for Python tools
- **Git Workflow**: Conventional commits with commitizen and pre-commit hooks
- **Infrastructure Tools**: Terraform for IaC, Ansible for configuration management, Redis CLI for caching
- **Database Tools**: MySQL and MongoDB CLI for database management and operations
- **Kubernetes Tools**: kubectl, helm, flux CLI, k9s, kubectx, kubens
- **AWS Tools**: AWS CLI, aws-sso-util for AWS SSO management
- **Modern CLI Tools**:
  - `exa` - Better ls
  - `bat` - Better cat
  - `fd` - Better find
  - `ripgrep` - Better grep
  - `fzf` - Fuzzy finder
  - `tldr` - Simplified man pages
  - `jq` - JSON processor
  - `yq` - YAML processor
  - `httpie` - HTTP client

### Git Configuration
- **Global Git Config**: Optimized settings and aliases
- **Global Gitignore**: Comprehensive ignore patterns
- **Useful Aliases**: Shortcuts for common Git operations
- **Laravel & Node.js Aliases**: Framework-specific Git commands

### ZSH Aliases & Functions
- **Git Aliases**: `gs`, `ga`, `gc`, `gp`, `gl`, `gco`, `gcb`, etc.
- **Docker Aliases**: `d`, `dc`, `dps`, `dex`, `dlogs`, etc.
- **Docker Desktop Aliases**: `dd`, `dd-start`, `dd-stop`, `dd-restart`, `dd-status`
- **Node.js Aliases**: `n`, `ni`, `nrb`, `nrd`, `nrs`, `nrt`
- **NVM Aliases**: `nvmls`, `nvmuse`, `nvminstall`, `nvmcurrent`, `nvmdefault`
- **NVM Functions**: `nvmsetup <version>`, `nvmlts`
- **Angular Aliases**: `ng`, `nga`, `ngs`, `ngb`, `ngt`, `nge`
- **Laravel Aliases**: `art`, `artm`, `artc`, `artmig`, `artseed`
- **Composer Aliases**: `c`, `ci`, `cu`, `cr`, `crd`, `crm`
- **Python Aliases**: `py`, `pip`, `pyenvls`, `pyenvuse`, `pyenvinstall`
- **pipx Aliases**: `px`, `pxls`, `pxinstall`, `pxuninstall`
- **direnv Aliases**: `de`, `deallow`, `dedeny`, `dereload`
- **Conventional Commits**: `cz`, `czcommit`, `czbump`
- **System Aliases**: `update`, `upgrade`, `install`, `remove`
- **Browser Aliases**: `brave`, `browser`
- **Office Aliases**: `word`, `excel`, `powerpoint`, `office`
- **Development Application Aliases**: `dbeaver`, `db`, `postman`, `api`
- **PDF Viewer**: `pdf`, `viewer`
- **Monitoring Tools**: `top`, `htop`, `ps`, `df`, `iostat`
- **Terminal Multiplexers**: `t`, `ta`, `tl`, `tn`, `tk` (tmux), `s`, `sa`, `sl`, `sn`, `sk` (screen)
- **File Sync**: `sync`, `sync-dry`, `rclone-sync`, `rclone-copy`
- **Utility Functions**: `mkcd`, `extract`
- **GitHub Copilot**: `copilot`, `chat`, `copilot-suggest`, `chat-suggest`, `copilot-explain`, `chat-explain`, `copilot-test`, `chat-test`, `copilot-fix`, `chat-fix`
- **DevOps Tool Aliases**: `k`, `h`, `fluxs`, `k9`, `aws-ss`, etc.
- **Infrastructure Aliases**: `tf`, `tfi`, `tfp`, `tfa`, `ans`, `ansb`, `redis`, `redis-monitor`
- **Database Aliases**: `mysql`, `mysql-dev`, `mongo`, `mongo-dev`, `mysql-dump`, `mongo-dump`

### DevOps Tool Aliases & Completions
- **kubectl**: `k`, `kgp`, `kgs`, `kgn`, `kga`, `kd`, `kl`, `kaf`, `kdf`, `kctx`, `kns`
- **helm**: `h`, `hls`, `hsr`, `hi`, `hu`, `hd`
- **flux**: `fluxs`, `fluxc`, `fluxa`, `fluxg`
- **k9s**: `k9`
- **kubectx/kubens**: `kx`, `kn`
- **AWS**: `aws-ss`, `aws-ssc`, `aws-ssr`, `aws-sss`
- **Shell completions**: Enabled for kubectl, helm, flux, and AWS CLI

#### Example Usage
```bash
k get pods           # List pods
kaf deployment.yaml  # Apply a manifest
hls                  # List helm releases
fluxs                # Show flux status
k9                   # Launch k9s TUI
kx                   # Switch Kubernetes context
kn                   # Switch Kubernetes namespace
aws-ss               # Login to AWS SSO
aws-ssc              # Configure AWS SSO
```

### Infrastructure Tools
- **Terraform**: `tf`, `tfi`, `tfp`, `tfa`, `tfd`, `tfw`, `tfo`, `tfs`
- **Ansible**: `ans`, `ansb`, `ansg`, `ansv`
- **Redis CLI**: `redis`, `redis-monitor`, `redis-info`, `redis-keys`, `redis-flush`
- **Shell completions**: Enabled for Terraform, Ansible, and Redis CLI

#### Example Usage
```bash
# Terraform
tf init          # Initialize Terraform
tfp              # Plan Terraform changes
tfa              # Apply Terraform changes
tfw list         # List Terraform workspaces

# Ansible
ans --version    # Check Ansible version
ansb playbook.yml # Run Ansible playbook
ansg install     # Install Ansible Galaxy roles
ansv encrypt     # Encrypt sensitive files

# Redis
redis ping       # Test Redis connection
redis-monitor    # Monitor Redis commands
redis-info       # Get Redis server info
redis-keys       # List all keys
```

### Python Tools
- **Python**: `py`, `pip`
- **pyenv**: `pyenvls`, `pyenvuse`, `pyenvglobal`, `pyenvinstall`, `pyenvcurrent`
- **pipx**: `px`, `pxls`, `pxinstall`, `pxuninstall`, `pxupgrade`
- **Shell completions**: Enabled for Python, pyenv, and pipx

#### Example Usage
```bash
# Python Version Management
pyenvls          # List installed Python versions
pyenvinstall 3.11.0  # Install Python 3.11.0
pyenvuse 3.11.0      # Set Python 3.11.0 for current project
pyenvcurrent         # Show current Python version

# Python Development
py --version     # Check Python version
pip install package  # Install Python package
px install black     # Install Python tool globally
pxls                 # List installed pipx tools
```

### Environment Management
- **direnv**: `de`, `deallow`, `dedeny`, `dereload`
- **Automatic environment loading** for project-specific variables

#### Example Usage
```bash
# Project Environment Setup
echo "export NODE_ENV=development" > .envrc
echo "export API_KEY=your_key" >> .envrc
deallow              # Allow direnv to load environment variables
# Environment variables are now automatically loaded when you cd into the project
```

### Git Workflow Tools
- **Conventional Commits**: `cz`, `czcommit`, `czbump`
- **pre-commit hooks** for code quality
- **commitlint** for commit message validation

#### Example Usage
```bash
# Conventional Commits
cz commit         # Interactive conventional commit prompt
cz init           # Initialize conventional commits in project
cz bump           # Bump version based on commits

# Pre-commit Hooks
pre-commit install  # Install pre-commit hooks in project
pre-commit run --all-files  # Run all hooks on all files
```

### Database Tools
- **MySQL CLI**: `mysql`, `mysql-dev`, `mysql-prod`, `mysql-dump`, `mysql-restore`
- **MongoDB CLI**: `mongo`, `mongo-dev`, `mongo-prod`, `mongo-dump`, `mongo-restore`
- **Redis CLI**: `redis`, `redis-monitor`, `redis-info`, `redis-keys`, `redis-flush`
- **Shell completions**: Enabled for MySQL, MongoDB, and Redis CLI

#### Example Usage
```bash
# MySQL Database Management
mysql-dev         # Connect to local MySQL as root
mysql-dump db_name > backup.sql  # Backup database
mysql-restore < backup.sql       # Restore database
mysql -e "SHOW DATABASES;"       # Execute SQL command

# MongoDB Database Management
mongo-dev         # Connect to local MongoDB
mongo-dump --db mydb --out /backup  # Backup database
mongo-restore --db mydb /backup/mydb  # Restore database
mongo --eval "db.adminCommand('listDatabases')"  # List databases

# Redis Database Management
redis ping        # Test Redis connection
redis-monitor     # Monitor Redis commands
redis-info        # Get Redis server info
redis-keys "*"    # List all keys
```

### VS Code Configuration
- **42 Essential Extensions**: Angular, Laravel, Docker, Kubernetes, AWS, and productivity tools
- **Tokyo Night Theme**: Matches terminal color scheme
- **Custom Keybindings**: Optimized shortcuts for development workflow
- **Language-Specific Settings**: Tailored for JavaScript, TypeScript, PHP, YAML, etc.
- **Auto-formatting**: Prettier and ESLint integration
- **Git Integration**: GitLens and enhanced Git features
- **Terminal Integration**: Integrated terminal with ZSH

#### Popular Extensions Included
- **Angular Language Service** - Official Angular support
- **PHP Intelephense** - PHP/Laravel language server
- **Docker** - Container management
- **Kubernetes** - K8s resource management
- **AWS Toolkit** - AWS services integration
- **Terraform** - HashiCorp Terraform support
- **Ansible** - Red Hat Ansible support
- **Redis** - Redis database support
- **MySQL** - MySQL database client and management
- **MongoDB** - MongoDB database client and management
- **Python** - Python language support and debugging
- **Pylance** - Python language server with type checking
- **Black Formatter** - Python code formatting
- **Flake8** - Python linting
- **Git Graph** - Visual Git history
- **GitLens** - Enhanced Git capabilities
- **Prettier** - Code formatting
- **ESLint** - JavaScript/TypeScript linting
- **Thunder Client** - REST API client
- **Todo Tree** - TODO comment highlighting
- **Project Manager** - Easy project switching
- **Material Icon Theme** - Beautiful file icons
- **GitHub Copilot** - AI-powered code completion
- **GitHub Copilot Chat** - AI chat assistant

### Development Applications
- **DBeaver Community Edition**: Universal database management tool supporting MySQL, PostgreSQL, SQLite, Oracle, SQL Server, and more
- **Postman**: Complete API development platform for testing, documenting, and sharing APIs

#### Development Application Aliases
- **DBeaver**: `dbeaver`, `db`
- **Postman**: `postman`, `api`

#### Example Usage
```bash
db              # Launch DBeaver database client
postman         # Launch Postman API client
```

## Development Workflow

### Node.js Version Management
```bash
nvmls          # List installed Node.js versions
nvmsetup 18.17.0  # Install and set Node.js 18.17.0 as default
nvmlts         # Install and switch to latest LTS version
nvmuse 16.20.0 # Switch to Node.js 16.20.0 temporarily
nvmcurrent     # Show current Node.js version
```

### Angular Development
```bash
ng new my-angular-app
cd my-angular-app
ngs  # ng serve
ngb  # ng build
ngt  # ng test
```

### Laravel Development
```bash
composer create-project laravel/laravel my-laravel-app
cd my-laravel-app
artserve  # php artisan serve
artmig    # php artisan migrate
artseed   # php artisan db:seed
```

### Docker Development
```bash
dc up -d    # docker-compose up -d
dc logs     # docker-compose logs
dex app bash # docker exec -it app bash
```

### Docker Desktop Workflow
```bash
# Docker Desktop Management
dd-start     # Start Docker Desktop
dd-stop      # Stop Docker Desktop
dd-restart   # Restart Docker Desktop
dd-status    # Check Docker Desktop status
dd           # Launch Docker Desktop GUI

# Docker Operations (via Docker Desktop)
dps          # List running containers
di           # List Docker images
dc up -d     # Start services with Docker Compose
dc logs      # View service logs
dex app bash # Execute commands in containers
```

### AWS & Kubernetes Workflow
```bash
aws-ss              # Login to AWS SSO
aws-ssc             # Configure AWS SSO profiles
aws eks update-kubeconfig --region us-west-2 --name my-cluster  # Get kubeconfig
kx                  # Switch between Kubernetes contexts
kn                  # Switch between namespaces
k9                  # Launch k9s for cluster management
```

### GitHub Copilot Workflow
```bash
# VS Code: Automatic AI suggestions and chat
# Use Ctrl+Enter for inline suggestions
# Use Ctrl+I for chat in editor

# Terminal: GitHub Copilot CLI
copilot suggest "create a React component for user profile"  # Generate code
copilot explain "this complex function"                      # Explain code
copilot test "write unit tests for this function"           # Generate tests
copilot fix "fix the bugs in this code"                     # Fix issues
```

### Infrastructure Tools Workflow
```bash
# Terraform Infrastructure as Code
tf init              # Initialize Terraform project
tfp                  # Plan infrastructure changes
tfa                  # Apply infrastructure changes
tfd                  # Destroy infrastructure
tfw list             # List Terraform workspaces
tfo                  # Show Terraform outputs

# Ansible Configuration Management
ans --version        # Check Ansible version
ansb site.yml        # Run main playbook
ansg install geerlingguy.nginx  # Install Galaxy role
ansv encrypt secrets.yml        # Encrypt sensitive files

# Redis Development and Debugging
redis ping           # Test Redis connection
redis-monitor        # Monitor Redis commands in real-time
redis-info           # Get detailed Redis server information
redis-keys "*user*"  # Find keys matching pattern
redis-flush          # Clear all Redis data (development only)
```

### Python Development Workflow
```bash
# Python Version Management
pyenvls              # List available Python versions
pyenvinstall 3.11.0  # Install Python 3.11.0
pyenvuse 3.11.0      # Set Python version for current project
pyenvcurrent         # Show current Python version

# Python Development
py --version         # Check Python version
pip install -r requirements.txt  # Install project dependencies
px install black     # Install code formatter globally
px install flake8    # Install linter globally

# Virtual Environments
python3 -m venv venv  # Create virtual environment
source venv/bin/activate  # Activate virtual environment
pip install -r requirements.txt  # Install dependencies in venv
```

### Environment Management Workflow
```bash
# Project-Specific Environment Variables
echo "export NODE_ENV=development" > .envrc
echo "export API_URL=http://localhost:3000" >> .envrc
echo "export DATABASE_URL=postgresql://localhost/mydb" >> .envrc
deallow              # Allow direnv to load variables
# Variables are now automatically loaded when you cd into the project

# Docusaurus Project Setup
echo "export DOCUSAURUS_PORT=3000" > .envrc
echo "export NODE_ENV=development" >> .envrc
deallow              # Load environment variables
```

### Git Workflow with Conventional Commits
```bash
# Initialize Conventional Commits
cz init              # Set up conventional commits in project

# Make Commits
cz commit            # Interactive conventional commit prompt
# Choose: feat, fix, docs, style, refactor, test, chore
# Enter scope, description, breaking changes, etc.

# Pre-commit Hooks
pre-commit install   # Install hooks in project
pre-commit run       # Run hooks on staged files
pre-commit run --all-files  # Run hooks on all files

# Version Bumping
cz bump              # Bump version based on commit types
```

### Database Tools Workflow
```bash
# MySQL Database Operations
mysql-dev            # Connect to local MySQL development database
mysql-dump myapp > backup.sql  # Create database backup
mysql-restore < backup.sql     # Restore from backup
mysql -e "SELECT * FROM users LIMIT 10;"  # Quick query execution

# MongoDB Database Operations
mongo-dev            # Connect to local MongoDB development database
mongo-dump --db myapp --out ./backups  # Backup MongoDB database
mongo-restore --db myapp ./backups/myapp  # Restore MongoDB database
mongo --eval "db.users.find().limit(10)"  # Quick query execution

# Redis Cache Operations
redis ping           # Test Redis connection
redis-monitor        # Monitor Redis commands in real-time
redis-info memory    # Check Redis memory usage
redis-keys "user:*"  # Find user-related keys
redis-flush          # Clear all data (development only)
```

### System Monitoring & Terminal Workflow
```bash
# Smart directory navigation with zoxide
z my-project    # Jump to project directory (learns your habits)

# System monitoring
top             # Enhanced system monitor (btop)
ps              # Better process listing (procs)
df              # Better disk usage (duf)
iostat          # Disk I/O monitoring (iotop)

# Terminal multiplexing
t               # Start tmux
ta              # Attach to tmux session
tl              # List tmux sessions
s               # Start screen
sa              # Attach to screen session

# File synchronization
sync source/ dest/           # Sync with progress
sync-dry source/ dest/       # Dry run sync
rclone-sync local/ remote:/  # Cloud sync
```

### Office Workflow
```bash
word            # Open WPS Writer (Word alternative)
excel           # Open WPS Spreadsheets (Excel alternative)
powerpoint      # Open WPS Presentation (PowerPoint alternative)
office          # Open WPS Office main application
pdf             # Open PDF viewer (Okular)
viewer          # Open document viewer (Okular)
```

## Keyboard Shortcuts

### ZSH
- `Ctrl+R`: Search command history
- `Ctrl+Space`: Accept autosuggestion
- `Ctrl+Shift+Space`: Execute autosuggestion
- `Ctrl+X Ctrl+E`: Edit command in editor

### VS Code
- `Ctrl+Shift+P`: Command palette
- `Ctrl+P`: Quick file open
- `Ctrl+Shift+F`: Find in files
- `Ctrl+Shift+H`: Replace in files
- `Ctrl+Shift+E`: Explorer
- `Ctrl+Shift+G`: Git panel
- `Ctrl+``: Toggle terminal
- `Ctrl+Shift+``: New terminal
- `Shift+Alt+F`: Format document
- `Ctrl+Shift+A`: Generate Angular component
- `Ctrl+Shift+M`: Laravel Artisan make
- `Ctrl+Alt+K`: Toggle bookmark
- `Ctrl+K Z`: Zen mode

## Requirements

- Fedora Workstation 42
- GNOME Desktop Environment
- sudo privileges for package installation

## Customization

The configuration files are located in:
- ZSH config: `~/.zshrc`
- Git config: `~/.gitconfig`
- Git ignore: `~/.gitignore_global`
- VS Code settings: `~/.config/Code/User/settings.json`
- VS Code keybindings: `~/.config/Code/User/keybindings.json`
- Tmux config: `~/.tmux.conf`
- Custom theme: `~/.oh-my-zsh/custom/themes/tokyo-night.zsh-theme`

Feel free to modify these files to suit your preferences.

## Contributing

This is a personal dotfiles setup, but suggestions and improvements are welcome!
