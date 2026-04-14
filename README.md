# Setup Scripts 🚀

Une collection de scripts et configurations pour automatiser l'installation et la configuration d'environnements de développement, d'outils de sécurité, et d'utilitaires système.

## 📁 Structure du Projet

```
setup-scripts/
├── dev-environement/     # Environnement de développement complet
├── dvwa/                 # Configuration Docker pour DVWA (Dam Vulnerable Web App)
├── ghostty-conf/         # Configuration du terminal Ghostty
├── partitioning/         # Scripts de partitionnement et migration
└── security-tools/       # Outils de cybersécurité et pentesting
```

## 🛠️ Scripts Disponibles

### 1. **dev-environement** - Environnement de Développement
Script complet pour configurer un environnement de développement moderne sur Linux.

**Fichiers :**
- `install.sh` - Script principal d'installation
- `zshrc` - Configuration Zsh personnalisée
- `aliases.zsh` - Alias utiles pour le développement
- `starship.toml` - Configuration du prompt Starship

**Fonctionnalités :**
- Installation de Zsh avec Oh My Zsh
- Configuration de Starship pour un prompt élégant
- Installation de polices Nerd Fonts (JetBrains Mono, Hack, etc.)
- Outils de développement : Go, Node.js, Rust, Bun, Docker
- Éditeurs : Helix
- Utilitaires : eza, tldr, ShellCheck, fastfetch

**Utilisation :**
```bash
cd dev-environement
chmod +x install.sh
./install.sh
```

### 2. **dvwa** - Dam Vulnerable Web Application
Configuration Docker Compose pour déployer plusieurs instances de DVWA pour des exercices de sécurité.

**Fichiers :**
- `compose.yml` - Configuration Docker Compose

**Configuration :**
- 3 instances indépendantes (Joueur 1, 2, 3)
- Chaque instance a sa propre base de données MariaDB
- Ports exposés : 4281, 4282, 4283
- Réseaux isolés pour chaque instance

**Utilisation :**
```bash
cd dvwa
docker-compose up -d
# Accéder aux instances :
# - Joueur 1: http://localhost:4281
# - Joueur 2: http://localhost:4282
# - Joueur 3: http://localhost:4283
```

### 3. **ghostty-conf** - Configuration du Terminal Ghostty
Configuration optimisée pour le terminal Ghostty avec des thèmes et raccourcis personnalisés.

**Fichiers :**
- `config.ghostty` - Configuration principale

**Fonctionnalités :**
- Thèmes clair/sombre (Horizon Bright / Broadcast)
- Police JetBrainsMono Nerd Font
- Raccourcis pour les splits (Ctrl+Shift+D/R/W)
- Opacité et flou d'arrière-plan
- Padding et décoration de fenêtre

**Installation :**
```bash
# Copier la configuration dans le dossier approprié
cp ghostty-conf/config.ghostty ~/.config/ghostty/config
```

### 4. **partitioning** - Migration de Partition /home
Script pour migrer le répertoire `/home` vers une partition dédiée.

**Fichiers :**
- `script.sh` - Script de migration principal
- `README.md` - Documentation détaillée

**Fonctionnalités :**
- Migration sécurisée des données avec rsync
- Configuration automatique de /etc/fstab
- Sauvegarde de l'ancienne configuration
- Support des disques SSD (option TRIM)

**⚠️ Important :**
- Exécuter depuis une session Live USB recommandé
- Partition cible doit être formatée en ext4
- Sauvegarde des données recommandée avant exécution

**Utilisation :**
```bash
cd partitioning
chmod +x script.sh
sudo ./script.sh
```

### 5. **security-tools** - Outils de Cybersécurité
Collection complète d'outils pour le pentesting et la sécurité.

**Fichiers :**
- `install_sec_tools.sh` - Script d'installation

**Outils inclus :**
- **Réseau** : Wireshark, Nmap, Socat, Proxychains
- **Web** : OWASP ZAP, Gobuster, SQLMap, FFUF
- **Cracking** : Hashcat, John the Ripper, Hydra
- **Exploitation** : Metasploit Framework
- **Python** : Impacket, BloodHound, Pwntools, CrackMapExec
- **Reverse** : Ghidra, Radare2
- **OSINT** : theHarvester, Recon-ng, Maltego
- **Utilitaires** : SecLists, Dirb, WFuzz

**Utilisation :**
```bash
cd security-tools
chmod +x install_sec_tools.sh
sudo ./install_sec_tools.sh
```

## 🚀 Installation Rapide

Pour installer tous les environnements (non recommandé - installez séparément selon vos besoins) :

```bash
# Cloner le repository
git clone <repository-url>
cd setup-scripts

# Installer l'environnement de développement
cd dev-environement && ./install.sh

# Installer les outils de sécurité
cd ../security-tools && sudo ./install_sec_tools.sh
```

## ⚠️ Notes de Sécurité

1. **Privilèges Root** : Certains scripts nécessitent des privilèges sudo
2. **Sauvegarde** : Toujours sauvegarder vos données avant d'exécuter des scripts système
3. **Compréhension** : Lisez les scripts avant de les exécuter
4. **Environnement Test** : Testez d'abord dans un environnement virtuel ou machine de test

## 🔧 Prérequis Système

- Système d'exploitation : Linux (Ubuntu/Debian/Mint recommandés)
- Shell : Bash
- Privilèges : Accès sudo pour certaines installations
- Espace disque : Variable selon les outils installés

## 📝 Journal des Modifications

### Version 1.0.0
- Script d'environnement de développement complet
- Configuration DVWA multi-instances
- Configuration Ghostty optimisée
- Script de migration de partition /home
- Collection complète d'outils de sécurité

## 🤝 Contribution

Les contributions sont les bienvenues ! Pour contribuer :

1. Fork le repository
2. Créez une branche pour votre fonctionnalité
3. Committez vos changements
4. Push vers la branche
5. Ouvrez une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier LICENSE pour plus de détails.

## ⚠️ Avertissement

Ces scripts sont fournis "tels quels", sans garantie d'aucune sorte. L'auteur n'est pas responsable des dommages pouvant résulter de leur utilisation. Utilisez à vos propres risques.

## 🆘 Support

Pour des problèmes ou questions :
1. Vérifiez la documentation dans chaque dossier
2. Examinez les messages d'erreur dans le terminal
3. Consultez les issues du repository (si public)

---

**Note** : Ces scripts sont optimisés pour Ubuntu/Linux Mint mais peuvent fonctionner sur d'autres distributions Linux avec des adaptations mineures.

---
