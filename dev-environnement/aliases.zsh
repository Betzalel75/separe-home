alias zshconfig="hx ~/.zshrc"
alias ohmyzsh="hx ~/.oh-my-zsh"
alias cls="clear"
alias clone="git clone"
alias ls="eza --icons --group-directories-first"
alias lt="ls -T"
alias ll="ls -l"
alias l='ls -CF'
alias la='ls -A'
alias grep="grep --color"
alias mint-update="sudo apt update && sudo apt upgrade -y && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt clean -y"
alias clone='git clone'
alias ff='fastfetch'
# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

update-golang(){
    local archive_file="$1"

    if [ -z "$archive_file" ]; then
        echo "Aucun fichier fourni, récupération automatique de la dernière version depuis go.dev..."

        # Détection de l'architecture
        local arch=$(uname -m)
        case "$arch" in
            x86_64) arch="amd64" ;;
            aarch64) arch="arm64" ;;
            armv6l|armv7l) arch="armv6l" ;;
            *) echo "Architecture non supportée : $arch"; return 1 ;;
        esac

        local latest_version=$(curl -s https://go.dev/VERSION?m=text | head -n1)
        if [ -z "$latest_version" ]; then
            echo "Impossible de déterminer la dernière version de Go."
            return 1
        fi

        local filename="${latest_version}.linux-${arch}.tar.gz"
        local url="https://go.dev/dl/${filename}"

        echo "Téléchargement de $filename..."
        archive_file="/tmp/${filename}"
        curl -L -o "$archive_file" "$url" || {
            echo "Échec du téléchargement de Go."
            return 1
        }
    else
        if [ ! -f "$archive_file" ]; then
            echo "Erreur : le fichier '$archive_file' n'existe pas."
            return 1
        fi
    fi

    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf "$archive_file"

    export PATH=$PATH:/usr/local/go/bin

    [[ "$archive_file" == /tmp/* ]] && rm -f "$archive_file"

    if command -v go &> /dev/null; then
        echo "Go a été mis à jour avec succès vers $(go version)"
    else
        echo "Erreur : la commande 'go' est introuvable après installation."
        return 1
    fi
}

git-init(){
    if [ -z "$1" ]; then
        echo "Usage: git-init <lien_vers_le_repository> [gitea|github]"
        return 1
    fi

    git init
    git add .
    git commit -m "first commit"

    if [ "$2" == "gitea" ]; then
        branch="master"
    elif [ "$2" == "github" ]; then
        branch="main"
    else
        echo "Usage: git-init <lien_vers_le_repository> [gitea|github]"
        return 1
    fi

    git branch -M "$branch"
    git remote add origin "$1"

    if ! git push -u origin "$branch"; then
        echo "Erreur lors de la mise à jour du dépôt sur $1"
        return 1
    fi
}

submit() {
    local commentaire=""
    local verify_flag=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -v|--verify)
                verify_flag=true
                shift
                ;;
            *)
                commentaire="$1"
                shift
                ;;
        esac
    done

    if [ "$verify_flag" = true ]; then
        verify
    fi

    if [ -z "$commentaire" ]; then
        echo -n "Entrez votre commentaire pour le commit: "
        read commentaire
    fi

    git add .
    git commit -m "$commentaire"
    git push
}
