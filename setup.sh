#!/bin/bash

# Fedora Web Development Dotfiles Setup Script

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

update_system() {
    print_status "Updating system..."
    sudo dnf update -y
    print_success "System updated successfully!"
}

set_hostname() {
    local hostname=${1:-$HOSTNAME}
    print_status "Setting hostname to '$hostname'..."
    sudo hostnamectl set-hostname $hostname
    echo "127.0.0.1 $hostname" | sudo tee -a /etc/hosts > /dev/null
    print_success "Hostname set to '$hostname' successfully!"
}

add_third_party_repositories() {
    print_status "Enabling third-party repositories..."
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    sudo dnf install -y dnf-plugins-core
    sudo dnf-3 config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    sudo dnf config-manager addrepo --from-repofile=https://rpm.releases.hashicorp.com/fedora/hashicorp.repo --overwrite
    print_success "Third-party repositories enabled successfully!"
}

install_development_tools() {
    print_status "Installing development tools..."
    sudo dnf install -y curl wget git unzip zip tree htop fzf bat fd-find ripgrep tldr gnome-terminal jq yq httpie btop iotop glances procs duf tmux screen rsync gh screenfetch nmtui

    mkdir -p ~/.tmux/plugins
    mkdir -p ~/.config/Code/User

    rm -rf ~/.tmux/plugins/tpm
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    curl https://rclone.org/install.sh | sudo bash || true
    cp .tmux.conf ~/.tmux.conf
    cp .gitconfig ~/.gitconfig
    cp .gitignore_global ~/.gitignore_global
    print_success "Development tools installed successfully!"
}

install_fonts() {
    print_status "Installing fonts..."
    sudo dnf install -y jetbrains-mono-fonts-all curl cabextract xorg-x11-font-utils fontconfig
    sudo rpm -i https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm
    print_success "Fonts installed successfully!"
}

install_zsh() {
    print_status "Installing ZSH..."
    sudo dnf install -y zsh

    if [ ! -d ~/.oh-my-zsh ]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi

    mkdir -p ~/.oh-my-zsh/custom/plugins

    rm -rf ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions

    rm -rf ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

    rm -rf ~/.oh-my-zsh/custom/plugins/zsh-completions
    git clone https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/custom/plugins/zsh-completions

    cp .zshrc ~/.zshrc

    if [ "$SHELL" != "/bin/zsh" ]; then
        chsh -s $(which zsh)
    fi

    print_success "ZSH installed successfully!"
}

uninstall_libreoffice() {
    print_status "Removing LibreOffice..."
    sudo dnf remove -y libreoffice* calligra* koffice*
    sudo dnf autoremove -y
    sudo dnf clean all
    print_success "LibreOffice removed successfully!"
}

install_wps_office() {
    print_status "Installing WPS Office..."
    curl -L -o wps-office.rpm "https://wdl1.pcfg.cache.wpscdn.com/wpsdl/wpsoffice/download/linux/${WPS_OFFICE_BUILD}/wps-office-${WPS_OFFICE_VERSION}.XA-1.x86_64.rpm"
    sudo dnf install -y ./wps-office.rpm
    rm -f wps-office.rpm
    print_success "WPS Office installed successfully!"

    print_status "Setting WPS Office as default for supported file types..."
    if command -v gsettings &> /dev/null; then
        xdg-mime default wps-office-wps.desktop application/vnd.openxmlformats-officedocument.wordprocessingml.document
        xdg-mime default wps-office-wps.desktop application/msword
        xdg-mime default wps-office-wps.desktop application/vnd.oasis.opendocument.text
        xdg-mime default wps-office-wps.desktop text/plain

        xdg-mime default wps-office-et.desktop application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
        xdg-mime default wps-office-et.desktop application/vnd.ms-excel
        xdg-mime default wps-office-et.desktop application/vnd.oasis.opendocument.spreadsheet

        xdg-mime default wps-office-wpp.desktop application/vnd.openxmlformats-officedocument.presentationml.presentation
        xdg-mime default wps-office-wpp.desktop application/vnd.ms-powerpoint
        xdg-mime default wps-office-wpp.desktop application/vnd.oasis.opendocument.presentation

        sudo update-desktop-database

        print_success "WPS Office set as default for all supported file types!"
    else
        print_warning "gsettings not found. You may need to manually set WPS Office as default."
    fi
}

install_okular() {
    print_status "Installing PDF viewer..."
    sudo dnf install -y okular
    print_success "Okular PDF viewer installed successfully!"

    print_status "Setting PDF viewer as default for PDF files..."
    if command -v gsettings &> /dev/null; then
        xdg-mime default okular.desktop application/pdf

        sudo update-desktop-database

        print_success "PDF viewer set as default for PDF files!"
    else
        print_warning "gsettings not found. You may need to manually set PDF viewer as default."
    fi
}

install_evolution() {
    print_status "Installing Evolution email client..."
    sudo dnf install -y evolution evolution-data-server evolution-ews
    print_success "Evolution email client installed successfully!"

    print_status "Setting Evolution as default email client..."
    if command -v gsettings &> /dev/null; then
        xdg-mime default org.gnome.Evolution.desktop x-scheme-handler/mailto

        sudo update-desktop-database

        print_success "Evolution set as default email client!"
    else
        print_warning "gsettings not found. You may need to manually set Evolution as default."
    fi
}

install_krita() {
    print_status "Installing Krita..."
    sudo dnf install -y krita
    print_success "Krita installed successfully!"
}

install_obs() {
    print_status "Installing OBS Studio..."
    sudo dnf install -y obs-studio
    print_success "OBS Studio installed successfully!"
}

install_nodejs_development_environment() {
    print_status "Installing Node.js development environment..."
    sudo dnf install -y nodejs npm

    if [ ! -d ~/.nvm ]; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh | bash
    fi

    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

    nvm install --lts
    nvm use --lts
    nvm alias default node
    sudo npm install -g node-gyp @commitlint/cli @commitlint/config-conventional
    print_success "Node.js development environment installed successfully!"
}

install_php_development_environment() {
    print_status "Installing PHP development environment..."
    sudo dnf install -y php php-cli php-common php-json php-mbstring php-xml php-zip php-curl php-gd php-mysqlnd php-pgsql php-sqlite3

    if [ ! -f /usr/local/bin/composer ]; then
        print_status "Installing Composer..."
        curl -sS https://getcomposer.org/installer | php
        sudo mv composer.phar /usr/local/bin/composer
        sudo chmod +x /usr/local/bin/composer
    fi

    print_success "PHP development environment installed successfully!"
}

install_python_development_environment() {
    print_status "Installing Python development environment..."
    sudo dnf install -y python3 python3-pip python3-devel

    if [ ! -d ~/.pyenv ]; then
        curl https://pyenv.run | bash
    fi

    python3 -m pip install --user pipx
    python3 -m pipx ensurepath

    sudo dnf install -y direnv

    if command -v pipx &> /dev/null; then
        pipx install commitizen
        pipx install pre-commit
    fi

    print_success "Python development environment installed successfully!"
}

install_docker_desktop() {
    print_status "Installing Docker Desktop..."

    ORIGINAL_DIR=$(pwd)

    cd /tmp
    wget -q "https://desktop.docker.com/linux/main/amd64/docker-desktop-x86_64.rpm" -O docker-desktop-x86_64.rpm
    sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo systemctl enable --now docker
    sudo dnf install -y ./docker-desktop-x86_64.rpm
    rm docker-desktop-x86_64.rpm
    sudo usermod -aG docker $USER

    cd "$ORIGINAL_DIR"

    print_success "Docker Desktop installed successfully!"
}

install_devops_tools() {
    print_status "Installing devops tools..."

    ORIGINAL_DIR=$(pwd)

    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"

    curl -LO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

    curl -s https://fluxcd.io/install.sh | sudo bash

    K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep tag_name | cut -d '"' -f 4)
    curl -Lo k9s.tar.gz "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz"
    tar -xzf k9s.tar.gz k9s
    sudo install -o root -g root -m 0755 k9s /usr/local/bin/k9s

    sudo rm -rf /opt/kubectx
    sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
    sudo ln -sf /opt/kubectx/kubectx /usr/local/bin/kubectx
    sudo ln -sf /opt/kubectx/kubens /usr/local/bin/kubens

    if ! command -v aws &> /dev/null; then
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        unzip -q awscliv2.zip
        sudo ./aws/install
    fi

    cd "$ORIGINAL_DIR"
    rm -rf "$TEMP_DIR"

    pip3 install aws-sso-util
    sudo dnf install -y ansible terraform redis-cli
    print_success "Devops tools installed successfully!"
}

install_obsidian() {
    print_status "Installing Obsidian..."
    sudo flatpak install -y flathub md.obsidian.Obsidian
    print_success "Obsidian installed successfully!"
}

install_dbeaver() {
    print_status "Installing DBeaver Community Edition..."
    sudo flatpak install -y flathub io.dbeaver.DBeaverCommunity
    print_success "DBeaver Community Edition installed successfully!"
}

install_postman() {
    print_status "Installing Postman..."
    sudo flatpak install -y flathub com.getpostman.Postman
    print_success "Postman installed successfully!"
}

install_brave_browser() {
    print_status "Installing Brave Browser..."
    curl -fsS https://dl.brave.com/install.sh | sh
    print_success "Brave Browser installed successfully!"
}

install_password_manager() {
    print_status "Installing Password Manager..."
    sudo dnf install -y keepassxc
    print_success "Password Manager installed successfully!"
}

install_communication_tools() {
    print_status "Installing Communication Tools..."
    sudo flatpak install -y flathub com.slack.Slack
    sudo flatpak install -y flathub com.discordapp.Discord
    sudo flatpak install -y flathub com.github.IsmaelMartinez.teams_for_linux
    print_success "Communication Tools installed successfully!"
}

install_vscode() {
    print_status "Installing VS Code..."
    wget -q "https://code.visualstudio.com/sha/download?build=stable&os=linux-rpm-x64" -O vscode.rpm
    sudo dnf install -y ./vscode.rpm
    rm -f vscode.rpm
    code --install-extension angular.ng-template >/dev/null 2>&1
    code --install-extension steoates.autoimport >/dev/null 2>&1
    code --install-extension dsznajder.es7-react-js-snippets >/dev/null 2>&1
    code --install-extension formulahendry.auto-rename-tag >/dev/null 2>&1
    code --install-extension esbenp.prettier-vscode >/dev/null 2>&1
    code --install-extension dbaeumer.vscode-eslint >/dev/null 2>&1
    code --install-extension christian-kohler.npm-intellisense >/dev/null 2>&1
    code --install-extension bmewburn.vscode-intelephense-client >/dev/null 2>&1
    code --install-extension onecentlin.laravel-blade >/dev/null 2>&1
    code --install-extension ryannaddy.laravel-artisan >/dev/null 2>&1
    code --install-extension xdebug.php-debug >/dev/null 2>&1
    code --install-extension MehediDracula.php-namespace-resolver >/dev/null 2>&1
    code --install-extension ms-kubernetes-tools.vscode-kubernetes-tools >/dev/null 2>&1
    code --install-extension ms-azuretools.vscode-docker >/dev/null 2>&1
    code --install-extension redhat.vscode-yaml >/dev/null 2>&1
    code --install-extension HashiCorp.terraform >/dev/null 2>&1
    code --install-extension AmazonWebServices.aws-toolkit-vscode >/dev/null 2>&1
    code --install-extension PKief.material-icon-theme >/dev/null 2>&1
    code --install-extension eamodio.gitlens >/dev/null 2>&1
    code --install-extension donjayamanne.githistory >/dev/null 2>&1
    code --install-extension christian-kohler.path-intellisense >/dev/null 2>&1
    code --install-extension rangav.vscode-thunder-client >/dev/null 2>&1
    code --install-extension streetsidesoftware.code-spell-checker >/dev/null 2>&1
    code --install-extension usernamehw.errorlens >/dev/null 2>&1
    code --install-extension aaron-bond.better-comments >/dev/null 2>&1
    code --install-extension oderwat.indent-rainbow >/dev/null 2>&1
    code --install-extension alefragnani.Bookmarks >/dev/null 2>&1
    code --install-extension Gruntfuggly.todo-tree >/dev/null 2>&1
    code --install-extension alefragnani.project-manager >/dev/null 2>&1
    code --install-extension sleistner.vscode-fileutils >/dev/null 2>&1
    code --install-extension yzhang.markdown-all-in-one >/dev/null 2>&1
    code --install-extension eriklynd.json-tools >/dev/null 2>&1
    code --install-extension janisdd.vscode-edit-csv >/dev/null 2>&1
    code --install-extension wix.vscode-import-cost >/dev/null 2>&1
    code --install-extension ritwickdey.LiveServer >/dev/null 2>&1
    code --install-extension humao.rest-client >/dev/null 2>&1
    code --install-extension GitHub.copilot >/dev/null 2>&1
    code --install-extension GitHub.copilot-chat >/dev/null 2>&1
    code --install-extension redhat.ansible >/dev/null 2>&1
    code --install-extension bradlc.vscode-tailwindcss >/dev/null 2>&1
    code --install-extension ms-vscode.vscode-typescript-next >/dev/null 2>&1
    code --install-extension cweijan.vscode-mysql-client2 >/dev/null 2>&1
    code --install-extension mongodb.mongodb-vscode >/dev/null 2>&1
    code --install-extension ms-python.python >/dev/null 2>&1
    code --install-extension ms-python.vscode-pylance >/dev/null 2>&1
    code --install-extension ms-python.black-formatter >/dev/null 2>&1
    code --install-extension ms-python.flake8 >/dev/null 2>&1
    code --install-extension ms-python.isort >/dev/null 2>&1
    code --install-extension njpwerner.autodocstring >/dev/null 2>&1
    code --install-extension donjayamanne.python-extension-pack >/dev/null 2>&1
    code --install-extension mhutchie.git-graph >/dev/null 2>&1
    code --install-extension michelemelluso.code-beautifier >/dev/null 2>&1
    mkdir -p ~/.config/Code/User
    cp .config/Code/User/settings.json ~/.config/Code/User/settings.json
    cp .config/Code/User/keybindings.json ~/.config/Code/User/keybindings.json
    print_success "VS Code installed successfully!"
}

install_applications() {
    install_wps_office
    install_okular
    install_evolution
    install_krita
    install_obs
    install_obsidian
    install_dbeaver
    install_postman
    install_password_manager
    install_communication_tools
    install_brave_browser
    install_vscode
    install_docker_desktop
}

uninstall_applications() {
    uninstall_libreoffice
}

install_tiling_manager() {
    print_status "Installing Tiling Manager..."
    sudo dnf install -y gnome-shell-extension-pop-shell xprop
    print_status "To enable the tiling manager, reboot and run the following command:"
    print_status "gnome-extensions enable pop-shell@system76.com"
    print_success "Tiling Manager installed successfully!"
}

set_desktop_background() {
    print_status "Setting desktop background..."

    if [ -f "wallpapers/default.jpg" ]; then
        WALLPAPER_PATH=$(realpath "wallpapers/default.jpg")

        if command -v gsettings &> /dev/null; then
            gsettings set org.gnome.desktop.background picture-uri "file://$WALLPAPER_PATH"
            gsettings set org.gnome.desktop.background picture-uri-dark "file://$WALLPAPER_PATH"
            print_success "Desktop background set successfully!"
        else
            print_warning "gsettings not found. You may need to manually set the desktop background."
        fi
    else
        print_error "Wallpaper file not found!"
    fi
}

configure_gnome_terminal() {
    print_status "Configuring GNOME Terminal..."

    gsettings set org.gnome.Terminal.Legacy.Settings new-tab-position 'last'
    gsettings set org.gnome.Terminal.Legacy.Settings confirm-close 'true'

    local profile_id=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")

    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile_id/ use-custom-command true
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile_id/ custom-command 'zsh'

    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile_id/ font 'JetBrains Mono 12'

    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile_id/ scrollback-lines 10000

    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile_id/ bold-color-same-as-fg true

    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile_id/ cursor-shape 'ibeam'
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile_id/ cursor-blink-mode 'on'

    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile_id/ audible-bell false

    print_success "GNOME Terminal configured successfully!"
}

configure_gnome_desktop() {
    print_status "Configuring GNOME Desktop..."

    if command -v gsettings &> /dev/null; then
        gsettings set org.gnome.desktop.interface enable-hot-corners false
        gsettings set org.gnome.mutter dynamic-workspaces false
        gsettings set org.gnome.desktop.wm.preferences num-workspaces 6

        for i in {1..6}; do
            gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-$i "['<Super>$i']"
        done

        for i in {1..6}; do
            gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-$i "['<Super><Shift>$i']"
        done

        print_success "GNOME Desktop configured successfully!"
    else
        print_warning "gsettings not found. You may need to manually disable hot corners."
    fi
}

validate_fedora_workstation() {
    print_status "Validating Fedora..."

    if ! grep -q "Fedora" /etc/os-release; then
        print_error "This script is designed for Fedora systems"
        exit 1
    fi

    print_success "Fedora detected!"
}

INSTALL_ALL=${INSTALL_ALL:-true}
INSTALL_DEVOPS=${INSTALL_DEVOPS:-false}
INSTALL_NODEJS=${INSTALL_NODEJS:-false}
INSTALL_PHP=${INSTALL_PHP:-false}
INSTALL_PYTHON=${INSTALL_PYTHON:-false}
INSTALL_APPS=${INSTALL_APPS:-false}
INSTALL_TILING_MANAGER=${INSTALL_TILING_MANAGER:-false}
SYSTEM_HOSTNAME=${SYSTEM_HOSTNAME:-code-ninja}

NVM_VERSION=${NVM_VERSION:-"v0.40.3"}
WPS_OFFICE_VERSION=${WPS_OFFICE_VERSION:-"11.1.0.11723"}
WPS_OFFICE_BUILD=${WPS_OFFICE_BUILD:-"11723"}

validate_fedora_workstation

print_status "Setting up Fedora Web Development Environment..."

update_system
set_hostname "$SYSTEM_HOSTNAME"
add_third_party_repositories
install_development_tools
install_fonts
install_zsh
configure_gnome_terminal
configure_gnome_desktop
set_desktop_background

if [[ "$INSTALL_ALL" == true || "$INSTALL_APPS" == true ]]; then
    install_applications
fi

if [[ "$INSTALL_ALL" == true || "$INSTALL_NODEJS" == true ]]; then
    install_nodejs_development_environment
fi

if [[ "$INSTALL_ALL" == true || "$INSTALL_PHP" == true ]]; then
    install_php_development_environment
fi

if [[ "$INSTALL_ALL" == true || "$INSTALL_PYTHON" == true ]]; then
    install_python_development_environment
fi

if [[ "$INSTALL_ALL" == true || "$INSTALL_DEVOPS" == true ]]; then
    install_devops_tools
fi

if [[ "$INSTALL_ALL" == true || "$INSTALL_TILING_MANAGER" == true ]]; then
    install_tiling_manager
fi

uninstall_applications

print_success "🎉 Fedora Web Development Environment Setup Complete!"
