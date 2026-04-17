# 🚀 Setup Scripts - Environnement de Développement

Un ensemble de scripts pour configurer rapidement un environnement de développement complet sur Debian/Ubuntu et dérivées.

## 📋 Fonctionnalités

### 🛠️ Outils de base installés

- **Zsh** avec **Oh My Zsh** - Shell moderne avec plugins
- **Starship** - Prompt rapide et personnalisable
- **eza** - Alternative moderne à `ls` avec icônes
- **fastfetch** - Alternative à neofetch
- **Polices Nerd Fonts** - JetBrains Mono, Go Mono, Hack

### 🔧 Outils de développement (optionnels)

- **Go** - Dernière version avec mise à jour automatique
- **Node.js** - Via nvm avec support LTS
- **Bun** - Runtime JavaScript rapide
- **Rust** - Avec Cargo
- **Docker** - Avec Docker Compose
- **Helix** - Éditeur de texte moderne
- **ShellCheck** - Linter pour scripts shell
- **tldr** - Pages de manuel simplifiées

### ⚙️ Configuration personnalisée

- **Alias pratiques** pour Git, système, etc.
- **Plugins Zsh** :
  - zsh-autosuggestions
  - zsh-syntax-highlighting
  - zsh-history-substring-search
- **Configuration Starship** avec thème optimisé
- **Variables d'environnement** préconfigurées

## 🚀 Installation rapide

```bash
# Télécharger le script
curl -L https://raw.githubusercontent.com/Betzalel75/setup-scripts/main/dev-environnement/install.sh -o install.sh

# Rendre exécutable
chmod +x install.sh

# Lancer l'installation
./install.sh
```

## 📁 Structure des fichiers

```
dev-environnement/
├── install.sh              # Script principal d'installation
├── zshrc                   # Configuration Zsh personnalisée
├── aliases.zsh            # Alias personnalisés
├── starship.toml          # Configuration Starship
└── README.md              # Ce fichier
```

## 🔧 Fonctions personnalisées

### Commandes Git améliorées

```bash
# Initialisation rapide d'un repo Git
git-init <url> [gitea|github]

# Commit et push en une commande
submit "message du commit"
submit -v "message"        # Avec vérification préalable
```

### Mise à jour de Go

```bash
# Mise à jour automatique vers la dernière version
update-golang

# Ou avec un fichier d'archive spécifique
update-golang /chemin/vers/go.tar.gz
```

### Alias utiles

```bash
cls                        # clear
mint-update                # Mise à jour complète du système
ff                         # fastfetch
ll, la, lt                # Variantes de ls avec eza
```

## ⚙️ Configuration Starship

Le prompt Starship est configuré pour afficher :

- **Système d'exploitation** avec icône
- **Nom d'utilisateur**
- **Répertoire courant** avec troncation intelligente
- **Branche Git** avec statut détaillé
- **Contexte Kubernetes** (si activé)
- **Environnement Python** (si activé)
- **Heure** avec format français

## 🎨 Polices Nerd Fonts

Le script installe automatiquement :

- **JetBrains Mono** - Pour le développement
- **Go Mono** - Optimisée pour Go
- **Hack** - Pour le terminal

## 🔒 Sécurité

- Le script vérifie s'il est exécuté en tant que root
- Utilise `set -euo pipefail` pour une exécution sécurisée
- Vérifie les dépendances avant installation
- Messages de log colorés pour une meilleure lisibilité

## 🐛 Dépannage

### Problèmes courants

1. **Permissions Docker** :

   ```bash
   # Après installation, déconnectez-vous et reconnectez-vous
   # Ou exécutez :
   newgrp docker
   ```

2. **Shell non changé** :

   ```bash
   # Vérifiez le shell actuel
   echo $SHELL

   # Forcez le changement
   chsh -s $(which zsh)
   ```

3. **Variables d'environnement non chargées** :
   ```bash
   # Rechargez la configuration
   source ~/.zshrc
   ```

### Logs et débogage

Le script utilise un système de logging coloré :

- 🔵 **INFO** - Informations générales
- 🟡 **WARNING** - Avertissements
- 🔴 **ERROR** - Erreurs
- 🟢 **SUCCESS** - Succès


## 🙏 Remerciements

- [Oh My Zsh](https://ohmyz.sh/) - Framework Zsh
- [Starship](https://starship.rs/) - Prompt cross-shell
- [Nerd Fonts](https://www.nerdfonts.com/) - Polices avec icônes
- Tous les mainteneurs des outils inclus

---

**✨ Profitez de votre nouvel environnement de développement !**
