
# Migration de la partition `/home`

Ce script Bash permet d'automatiser et de sécuriser le transfert de votre répertoire `/home` existant vers une nouvelle partition dédiée. Il se charge de la copie des données, de la libération de l'espace sur la racine, et de la configuration du montage automatique.

---

## ⚠️ Prérequis obligatoires

Avant d'exécuter ce script, **vous devez impérativement préparer la future partition `/home`**. 

1. **Création de la partition :** Utilisez un outil comme `GParted`, `fdisk` ou `cfdisk` pour créer la nouvelle partition sur votre disque principal ou sur un disque secondaire.
2. **Formatage (Crucial) :** La partition doit être formatée en **`ext4`**. *(Note : le script configure automatiquement le fichier `fstab` pour le système de fichiers ext4).*
3. **Repérer les identifiants :** Notez le chemin de votre partition racine actuelle (ex: `/dev/sda1` ou `/dev/nvme0n1p2`) et celui de votre nouvelle partition (ex: `/dev/sdb1`).

> **Recommandation de sécurité :** Bien que le script puisse techniquement s'exécuter sur votre système actif, il est vivement conseillé de l'exécuter depuis une session **Live USB**. Cela évite tout conflit avec des fichiers ouverts par votre session utilisateur lors de la suppression de l'ancien `/home`.

---

## 🚀 Comment utiliser le script

### 1. Rendre le script exécutable
Ouvrez votre terminal dans le dossier où se trouve le script et accordez-lui les droits d'exécution :
```bash
chmod +x migrate_home.sh
```

### 2. Lancer le script
Le script nécessite les privilèges d'administrateur pour monter les partitions et modifier les fichiers système :
```bash
sudo ./migrate_home.sh
```

### 3. Suivre les instructions à l'écran
Le script est interactif. Il vous demandera :
* **Votre partition racine** (ex: `/dev/sda1`).
* **Votre future partition `/home`** (ex: `/dev/sdb1`).
* **L'activation de l'option `discard` :** Si votre partition se trouve sur un disque SSD, il est recommandé de répondre `y` (oui) pour activer le TRIM.

---

## ⚙️ Ce que fait le script (Sous le capot)

Pour garantir la transparence, voici les actions exactes effectuées par le script :
1. **Montage temporaire :** Monte votre partition racine et la nouvelle partition `/home` dans `/mnt_tmp/`.
2. **Synchronisation :** Copie toutes vos données avec `rsync` (en préservant les permissions, les liens symboliques et les fichiers cachés).
3. **Nettoyage :** Vide le contenu du répertoire `/home` de l'ancienne partition racine pour libérer de l'espace disque.
4. **Configuration :** * Crée une sauvegarde horodatée de votre fichier système `/etc/fstab`.
   * Ajoute la nouvelle partition (via son UUID pour plus de stabilité) à `/etc/fstab` pour qu'elle se monte automatiquement au démarrage.
5. **Démontage :** Démonte proprement les partitions et nettoie les dossiers temporaires.

---

## 🛠️ Post-Installation & Dépannage

Une fois le script terminé, **redémarrez votre ordinateur**.

### Vérifications après redémarrage :
Ouvrez un terminal et tapez ces commandes pour vous assurer que tout fonctionne :
* Vérifiez que la partition est montée sur `/home` : `lsblk`
* Vérifiez que vos fichiers sont présents : `ls -la ~/`
* Vérifiez votre fichier de configuration : `cat /etc/fstab`

### En cas de problème au redémarrage (Système bloqué) :
Si le système refuse de démarrer (souvent à cause d'une erreur de saisie de partition), pas de panique, une sauvegarde a été créée.
1. Démarrez sur une clé Live USB.
2. Montez votre partition racine : `sudo mount /dev/sdXn /mnt` *(remplacez sdXn par votre partition racine)*.
3. Restaurez la sauvegarde :
   ```bash
   sudo cp /mnt/etc/fstab.backup.* /mnt/etc/fstab
   ```
4. Redémarrez normalement.

---
