#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

INSTALL_ALL=false
FORCE_OVERWRITE=false
TOOLS=(
    "Bun:install_bun"
    "Node.js:install_nodejs"
    "Rust:install_rust"
    "Go:install_go"
    "Docker:install_docker"
    "tldr:install_tldr"
    "Helix:install_helix"
    "ShellCheck:install_shellcheck"
    "Dioxus:install_dioxus"
    "Ghostty:install_ghostty"
    "Iriunwebcam:install_iriun_webcam"
    "DeepSeek-tui:install_deepseek"
    "flatpak:install_flatpaks"
    "Zed:install_zed"
)

# ---------- Fonctions d'affichage et d'utilitaires ----------
function usage() {
    echo "Usage: $0 [OPTIONS] [TOOLS...]"
    echo ""
    echo "Options:"
    echo "  -a, --all       Installer tous les outils sans confirmation"
    echo "  -f, --force     Forcer le remplacement des fichiers de configuration existants"
    echo "  -l, --list      Lister les outils disponibles"
    echo "  -h, --help      Afficher cette aide"
    echo ""
    echo "Outils disponibles:"
    for tool in "${TOOLS[@]}"; do
        local name="${tool%:*}"
        echo "  $name"
    done
    echo ""
    echo "Exemples:"
    echo "  $0 --all                              # Tout installer"
    echo "  $0                                    # Mode interactif (checklist)"
    echo "  $0 Docker Rust Go                     # Installer Docker, Rust et Go"
    echo "  $0 --force Docker                     # Forcer le remplacement des configs + installer Docker"
    echo "  $0 Node.js Bun Helix                  # Installer Node.js, Bun et Helix"
    exit 0
}

function log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
function log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
function log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
function log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

# Vérifie si une commande est dans le PATH
function is_installed() {
    command -v "$1" >/dev/null 2>&1
}

# Vérification spécifique pour chaque outil
function is_tool_installed() {
    local tool="$1"
    case "$tool" in
        "Bun")            is_installed bun ;;
        "Node.js")        is_installed node ;;
        "Rust")           is_installed rustc ;;
        "Go")             is_installed go ;;
        "Docker")         is_installed docker ;;
        "tldr")           is_installed tldr ;;
        "Helix")          is_installed hx ;;
        "ShellCheck")     is_installed shellcheck ;;
        "Dioxus")         is_installed dx ;;
        "Ghostty")        is_installed ghostty ;;
        "Iriunwebcam")    is_installed iriunwebcam ;;  # à adapter si le binaire a un autre nom
        "DeepSeek-tui")   is_installed deepseek-tui ;;
        "flatpak")        is_installed flatpak ;;
        "Zed")            is_installed zed ;;
        *)                return 1 ;;
    esac
}

# ---------- Fonctions d'installation des outils (inchangées) ----------
function install_go() {
    # ... (identique à l'original)
    log_info "Installation de Go..."
    local arch
    arch=$(uname -m)
    case "$arch" in
        x86_64) arch="amd64" ;;
        aarch64) arch="arm64" ;;
        armv6l|armv7l) arch="armv6l" ;;
        *) log_error "Architecture non supportée : $arch"; return 1 ;;
    esac
    local latest_version
    latest_version=$(curl -s https://go.dev/VERSION?m=text | head -n1)
    if [ -z "$latest_version" ]; then
        log_error "Impossible de déterminer la dernière version de Go."
        return 1
    fi
    local filename="${latest_version}.linux-${arch}.tar.gz"
    local url="https://go.dev/dl/${filename}"
    log_info "Téléchargement de $filename..."
    archive_file=$(mktemp "/tmp/${filename}")
    curl -L -o "$archive_file" "$url" || {
        log_error "Échec du téléchargement de Go."
        rm -f "$archive_file"
        return 1
    }
    log_info "Installation de Go dans /usr/local..."
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf "$archive_file"
    export PATH=$PATH:/usr/local/go/bin
    local path_export="export PATH=$PATH:/usr/local/go/bin"
    local shell_rc
    if [ -n "$ZSH_VERSION" ]; then
        shell_rc="$HOME/.zshrc"
    elif [ -n "$BASH_VERSION" ]; then
        shell_rc="$HOME/.bashrc"
    else
        shell_rc="$HOME/.profile"
    fi
    if ! grep -q "/usr/local/go/bin" "$shell_rc" 2>/dev/null; then
        log_info "Configuration des variables d'environnement dans $shell_rc..."
        echo -e "# Ajout de Go au PATH\n$path_export" >> "$shell_rc"
    fi
    [[ "$archive_file" == /tmp/* ]] && rm -f "$archive_file"
    log_success "Go installé"
}

function install_nodejs() {
    log_info "Installation de Node.js..."
    if [[ ! -d "$HOME/.nvm" ]]; then
        if curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash; then
            export NVM_DIR="$HOME/.nvm"
            # shellcheck disable=SC1091
            [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
            log_success "nvm installé"
        else
            log_error "Échec de l'installation de nvm"
            return 1
        fi
    fi
    set +u
    export NVM_DIR="$HOME/.nvm"
    # shellcheck disable=SC1091
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    set -u
    if nvm install --lts; then
        nvm use --lts
        nvm alias default --lts
        log_success "Node.js LTS installé"
        echo "Node.js version: $(node -v)"
        echo "npm version: $(npm -v)"
    else
        log_error "Échec de l'installation de Node.js"
        return 1
    fi
}

function install_bun() {
    log_info "Installation de Bun..."
    if curl -fsSL https://bun.sh/install | bash; then
        export BUN_INSTALL="$HOME/.bun"
        export PATH="$BUN_INSTALL/bin:$PATH"
        log_success "Bun installé"
        echo "Bun version: $(bun --version 2>/dev/null || echo 'Non détecté')"
    else
        log_error "Échec de l'installation de Bun"
        return 1
    fi
}

function install_rust() {
    log_info "Installation de Rust..."
    if curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y; then
        # shellcheck disable=SC1091
        source "$HOME/.cargo/env"
        log_success "Rust installé"
        echo "Rust version: $(rustc --version 2>/dev/null || echo 'Non détecté')"
    else
        log_error "Échec de l'installation de Rust"
        return 1
    fi
}

function install_tldr() {
    log_info "Installation de tldr..."
    if cargo install tlrc --locked; then
        log_success "tldr installé"
        echo "tldr version: $(tldr --version 2>/dev/null || echo 'Non détecté')"
    else
        log_error "Échec de l'installation de tldr"
        return 1
    fi
}

function install_deepseek() {
    log_info "Installation de DeepSeek..."
    if cargo install deepseek-tui --locked; then
        log_success "DeepSeek installé"
        echo "DeepSeek version: $(deepseek-tui --version 2>/dev/null || echo 'Non détecté')"
    else
        log_error "Échec de l'installation de DeepSeek"
        return 1
    fi
}

function install_dioxus() {
    log_info "Installation de Dioxus..."
    if cargo binstall dioxus-cli --force; then
        log_success "Dioxus installé"
        echo "Dioxus version: $(dx --version 2>/dev/null || echo 'Non détecté')"
    else
        log_error "Échec de l'installation de Dioxus"
        return 1
    fi
}

function install_docker() {
    sudo apt update
    sudo apt install -y ca-certificates curl gnupg
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    # shellcheck disable=SC1091
    OS_RELEASE_CODE=$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
    https://download.docker.com/linux/ubuntu \
    $OS_RELEASE_CODE stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo systemctl enable --now docker
    sudo systemctl start docker
    sudo usermod -aG docker "$USER"
    log_success "Docker installé"
    echo "Docker version: $(docker --version)"
    log_warning "Vous devez vous déconnecter et reconnecter pour que les permissions Docker soient appliquées"
}

function install_helix() {
    log_info "Installation de Helix..."
    sudo add-apt-repository ppa:maveonair/helix-editor
    sudo apt update
    sudo apt install -y helix
    log_success "Helix installé"
}

function install_shellcheck() {
    log_info "Installation de ShellCheck..."
    sudo apt install -y shellcheck
    log_success "ShellCheck installé"
}

function install_font() {
    FONTS_DIR="$HOME/.local/share/fonts"
    mkdir -p "$FONTS_DIR"
    local fonts=(
        "JetBrainsMono"
        "Go-Mono"
        "Hack"
    )
    local font_installed=false
    for font in "${fonts[@]}"; do
        # 1. Vérifier si un fichier contenant le nom de la police existe dans le répertoire utilisateur
        if find "$FONTS_DIR" -type f \( -name "*${font}*.ttf" -o -name "*${font}*.otf" \) 2>/dev/null | grep -q .; then
            log_info "$font déjà installée dans $FONTS_DIR"
            continue
        fi

        # 2. Sinon, vérifier via fc-list (après un rafraîchissement du cache)
        fc-cache -fv > /dev/null 2>&1
        if fc-list | grep -qi "$font" 2>/dev/null; then
            log_info "$font déjà présente dans le système"
            continue
        fi

        log_info "Téléchargement de $font..."
        local zip_file="/tmp/${font}.zip"
        local extract_dir="/tmp/${font}"
        if wget -q "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/${font}.zip" -O "$zip_file"; then
            mkdir -p "$extract_dir"
            unzip -q -o "$zip_file" -d "$extract_dir"
            find "$extract_dir" -name "*.ttf" -o -name "*.otf" | while read -r font_file; do
                cp "$font_file" "$FONTS_DIR/"
            done
            log_success "$font installée"
            font_installed=true
        else
            log_error "Échec du téléchargement de $font"
        fi
    done
    if [[ "$font_installed" == true ]]; then
        fc-cache -fv
        log_success "Cache des polices mis à jour"
    else
        log_info "Toutes les polices étaient déjà installées"
    fi
}

function install_fastfetch() {
    if is_installed fastfetch; then
        log_info "fastfetch est déjà installé, aucune action."
    else
        log_info "Installation de fastfetch..."
        sudo add-apt-repository ppa:zhangsongcui3371/fastfetch
        sudo apt update
        sudo apt install -y fastfetch
        log_success "fastfetch installé"
    fi
}

function install_ghostty() {
    log_info "Installation de ghostty..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)"
    log_success "ghostty installé"
}

function install_iriun_webcam() {
    log_info "Installation de Iriun Webcam..."
    wget -O iriun.deb "https://iriun.gitlab.io/iriunwebcam-2.9.1.deb"
    sudo apt install -y ./iriun.deb
    log_success "Iriun Webcam installé"
}

function install_flatpaks() {
    log_info "Installation des paquets Flatpak..."
    xargs -a ~/liste_flatpaks.txt flatpak install --system -y
    log_success "Flatpak installé"
}

function install_zed() {
    log_info "Installation de Zed..."
    curl -f https://zed.dev/install.sh | sh
    log_success "Zed installé"
}

function install_all_tools() {
    log_info "Installation de tous les outils de développement..."
    for tool in "${TOOLS[@]}"; do
        local name="${tool%:*}"
        local func="${tool#*:}"
        log_info "Installation de $name..."
        if $func; then
            log_success "$name installé avec succès"
        else
            log_error "Échec de l'installation de $name"
        fi
    done
}

# ---------- Nouvelle fonction d'installation interactive avec checklist ----------
function install_dev_tools_interactive() {
    log_info "Mode interactif : sélection des outils à installer."

    # Déterminer l'outil d'interface (whiptail ou dialog)
    local cmd=""
    if command -v whiptail >/dev/null; then
        cmd="whiptail"
    elif command -v dialog >/dev/null; then
        cmd="dialog"
    else
        log_warning "Ni whiptail ni dialog trouvés. Utilisation du mode interactif texte."
        install_dev_tools_text
        return
    fi

    # Construire la liste des options pour la checklist
    local options=()
    local state
    local default
    for tool in "${TOOLS[@]}"; do
        local name="${tool%:*}"
        if is_tool_installed "$name"; then
            state="(installé)"
            default="OFF"   # par défaut non coché
        else
            state="(non installé)"
            default="ON"    # par défaut coché
        fi
        options+=("$name" "$state" "$default")
    done

    local choice
    if [[ "$cmd" == "whiptail" ]]; then
        # whiptail renvoie les choix séparés par des espaces
        choice=$(whiptail --checklist --separate-output \
            "Sélectionnez les outils à installer (ou à réinstaller si déjà installés) :" \
            20 60 10 "${options[@]}" 3>&1 1>&2 2>&3)
    else # dialog
        # dialog renvoie les choix sur la sortie standard, avec les guillemets
        choice=$(dialog --checklist \
            "Sélectionnez les outils à installer (ou à réinstaller si déjà installés) :" \
            20 60 10 "${options[@]}" 2>&1 >/dev/tty)
    fi

    if [[ -z "$choice" ]]; then
        log_info "Aucun outil sélectionné. Aucune installation."
        return
    fi

    # Installer chaque outil sélectionné
    for selected in $choice; do
        # Trouver la fonction d'installation correspondante
        for tool in "${TOOLS[@]}"; do
            local name="${tool%:*}"
            local func="${tool#*:}"
            if [[ "$selected" == "$name" ]]; then
                log_info "Installation de $name..."
                if $func; then
                    log_success "$name installé avec succès."
                else
                    log_error "Échec de l'installation de $name."
                fi
                break
            fi
        done
    done
}

# Fallback interactif en mode texte (si whiptail/dialog absents)
function install_dev_tools_text() {
    log_info "Mode interactif texte :"
    local to_install=()
    for tool in "${TOOLS[@]}"; do
        local name="${tool%:*}"
        local func="${tool#*:}"
        local installed=""
        if is_tool_installed "$name"; then
            installed="[installé]"
        else
            installed="[non installé]"
        fi
        read -p "Installer $name $installed ? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            to_install+=("$name")
        fi
    done
    if [[ ${#to_install[@]} -eq 0 ]]; then
        log_info "Aucun outil sélectionné."
        return
    fi
    for name in "${to_install[@]}"; do
        for tool in "${TOOLS[@]}"; do
            local tname="${tool%:*}"
            local func="${tool#*:}"
            if [[ "$name" == "$tname" ]]; then
                log_info "Installation de $name..."
                if $func; then
                    log_success "$name installé."
                else
                    log_error "Échec de l'installation de $name."
                fi
                break
            fi
        done
    done
}

# ---------- Fonction principale ----------
function main() {
    local selected_tools=()
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -a|--all)
                INSTALL_ALL=true
                shift
                ;;
            -f|--force)
                FORCE_OVERWRITE=true
                shift
                ;;
            -l|--list)
                log_info "Outils disponibles:"
                for tool in "${TOOLS[@]}"; do
                    echo "  ${tool%:*}"
                done
                exit 0
                ;;
            -h|--help)
                usage
                ;;
            -*)
                log_error "Option inconnue : $1"
                usage
                ;;
            *)
                selected_tools+=("$1")
                shift
                ;;
        esac
    done

    log_info "Début de l'installation..."

    if [[ $EUID -eq 0 ]]; then
        log_warning "Le script est exécuté en tant que root"
        log_warning "Certaines installations (nvm, rustup) peuvent ne pas fonctionner correctement"
        read -p "Voulez-vous continuer? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi

    log_info "Mise à jour des paquets apt..."
    sudo apt update

    log_info "Installation des outils de base..."
    sudo apt install -y gpg curl wget git unzip axel

    # Installer eza
    if ! is_installed eza; then
        log_info "Installation de eza..."
        sudo mkdir -p /etc/apt/keyrings
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | \
            sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | \
            sudo tee /etc/apt/sources.list.d/gierens.list
        sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
        sudo apt update
        sudo apt install -y eza
    else
        log_success "eza déjà installé"
    fi

    # Starship
    log_info "Installation de Starship..."
    if ! is_installed starship; then
        if curl -sS https://starship.rs/install.sh | sh -s -- -y; then
            log_success "Starship installé"
        else
            log_error "Échec de l'installation de Starship"
        fi
    else
        log_success "Starship déjà installé"
    fi

    if [[ ! -f ~/.config/starship.toml ]] || [[ "$FORCE_OVERWRITE" == true ]]; then
        mkdir -p ~/.config
        if wget -q https://raw.githubusercontent.com/Betzalel75/setup-scripts/refs/heads/main/dev-environnement/starship.toml -O ~/.config/starship.toml; then
            log_success "Configuration Starship téléchargée"
        fi
    else
        log_info "Configuration Starship déjà présente (utilisez --force pour remplacer)"
    fi

    # Zsh et Oh My Zsh
    log_info "Installation de Zsh..."
    sudo apt install -y zsh fonts-powerline
    log_info "Installation de Oh My Zsh..."
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi

    log_info "Installation des plugins Zsh..."
    local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    if [[ ! -d "$zsh_custom/plugins/zsh-autosuggestions" ]]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions "$zsh_custom/plugins/zsh-autosuggestions"
    fi
    if [[ ! -d "$zsh_custom/plugins/zsh-syntax-highlighting" ]]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$zsh_custom/plugins/zsh-syntax-highlighting"
    fi

    if [[ ! -f ~/.zshrc ]] || [[ "$FORCE_OVERWRITE" == true ]]; then
        log_info "Téléchargement de la configuration Zsh..."
        if wget -q https://raw.githubusercontent.com/Betzalel75/setup-scripts/refs/heads/main/dev-environnement/zshrc -O ~/.zshrc; then
            log_success "Configuration Zsh téléchargée"
        fi
    else
        log_info "Fichier ~/.zshrc déjà présent (utilisez --force pour remplacer)"
    fi

    if [[ ! -f "$zsh_custom/aliases.zsh" ]] || [[ "$FORCE_OVERWRITE" == true ]]; then
        log_info "Téléchargement des aliases..."
        if wget -q https://raw.githubusercontent.com/Betzalel75/setup-scripts/refs/heads/main/dev-environnement/aliases.zsh -O "$zsh_custom/aliases.zsh"; then
            log_success "Aliases téléchargés"
        fi
    else
        log_info "Fichier aliases.zsh déjà présent (utilisez --force pour remplacer)"
    fi

    if [[ ! -d "$zsh_custom/plugins/zsh-history-substring-search" ]]; then
        git clone https://github.com/zsh-users/zsh-history-substring-search.git "$zsh_custom/plugins/zsh-history-substring-search"
    fi

    # Polices
    install_font

    # Installation des outils de développement
    if [[ "$INSTALL_ALL" == true ]]; then
        install_all_tools
    elif [[ ${#selected_tools[@]} -gt 0 ]]; then
        log_info "Installation des outils sélectionnés..."
        for selected in "${selected_tools[@]}"; do
            local found=false
            for tool in "${TOOLS[@]}"; do
                local name="${tool%:*}"
                local func="${tool#*:}"
                if [[ "${selected,,}" == "${name,,}" ]]; then
                    found=true
                    log_info "Installation de $name..."
                    if $func; then
                        log_success "$name installé avec succès"
                    else
                        log_error "Échec de l'installation de $name"
                    fi
                    break
                fi
            done
            if [[ "$found" == false ]]; then
                log_warning "Outil inconnu : '$selected'"
                log_info "Utilisez --list pour voir les outils disponibles"
            fi
        done
    else
        # Mode interactif par défaut
        install_dev_tools_interactive
    fi

    # Changer le shell par défaut
    if [[ $(basename "$SHELL") != "zsh" ]]; then
        log_info "Changement du shell par défaut vers Zsh..."
        chsh -s "$(which zsh)"
        log_success "Shell changé vers Zsh"
        log_warning "Vous devez vous déconnecter et reconnecter pour que le changement prenne effet"
    fi

    install_fastfetch

    log_success "🎉 Installation terminée !"
    echo ""
    echo "Résumé :"
    echo "- Zsh et Oh My Zsh installés"
    echo "- Starship et eza configurés"
    echo "- Plugins Zsh installés"
    echo "- Polices Nerd Fonts installées"
    echo ""
    echo "Prochaines étapes :"
    echo "1. Déconnectez-vous et reconnectez-vous"
    echo "2. Exécutez 'source ~/.zshrc'"
    echo "3. Profitez de votre nouvel environnement !"
}

main "$@"
