#!/usr/bin/env bash

# =====================================================
# Script de séparation du /home de la partition racine
# Auteur : Betzalel75
# Usage : sudo bash separe-home.sh
# =====================================================

set -euo pipefail

# =====================================================
# Configuration des couleurs
# =====================================================

RESET="\033[0m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
CYAN="\033[36m"
BOLD="\033[1m"

# =====================================================
# Fonctions de logging
# =====================================================

log_info() {
    echo -e "${BLUE}[INFO]${RESET} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${RESET} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${RESET} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${RESET} $1" >&2
}

log_step() {
    echo -e "\n${CYAN}${BOLD}==> $1${RESET}\n"
}

# =====================================================
# Vérification des privilèges root
# =====================================================

if [[ $EUID -ne 0 ]]; then
    log_error "Ce script doit être exécuté avec sudo (ou en tant que root)."
    exit 1
fi

# =====================================================
# Configuration
# =====================================================

log_step "Configuration des partitions"

# Demander les partitions à l'utilisateur
read -rp "Quelle est votre partition racine ('/') ? " root_partition
read -rp "Quelle est votre future partition home ('/home') ? " home_partition

# Vérifier que les partitions existent
if [[ ! -b "$root_partition" ]]; then
    log_error "La partition racine '$root_partition' n'existe pas ou n'est pas un périphérique bloc."
    exit 1
fi

if [[ ! -b "$home_partition" ]]; then
    log_error "La partition home '$home_partition' n'existe pas ou n'est pas un périphérique bloc."
    exit 1
fi

# Points de montage temporaires
mount_point_root="/mnt_tmp/root"
mount_point_home="/mnt_tmp/home"

# =====================================================
# Création des points de montage
# =====================================================

log_step "Création des points de montage temporaires"

mkdir -p "$mount_point_root"
mkdir -p "$mount_point_home"

# =====================================================
# Montage des partitions
# =====================================================

log_step "Montage des partitions"

if mountpoint -q "$mount_point_root"; then
    log_warning "Le point de montage $mount_point_root est déjà utilisé."
    read -rp "Voulez-vous le démonter ? (y/n) " -n 1 choice
    echo
    if [[ "$choice" =~ ^[Yy]$ ]]; then
        umount "$mount_point_root"
    else
        log_error "Abandon."
        exit 1
    fi
fi

if mountpoint -q "$mount_point_home"; then
    log_warning "Le point de montage $mount_point_home est déjà utilisé."
    read -rp "Voulez-vous le démonter ? (y/n) " -n 1 choice
    echo
    if [[ "$choice" =~ ^[Yy]$ ]]; then
        umount "$mount_point_home"
    else
        log_error "Abandon."
        exit 1
    fi
fi

mount "$root_partition" "$mount_point_root"
mount "$home_partition" "$mount_point_home"

# =====================================================
# Synchronisation du contenu de /home
# =====================================================

log_step "Synchronisation du contenu de /home"

if [[ ! -d "$mount_point_root/home" ]]; then
    log_error "Le répertoire /home n'existe pas sur la partition racine."
    umount "$mount_point_root"
    umount "$mount_point_home"
    exit 1
fi

log_info "Copie des données de /home vers la nouvelle partition..."
rsync -azh "$mount_point_root/home/" "$mount_point_home/"

# =====================================================
# Nettoyage de l'ancien /home
# =====================================================

log_step "Nettoyage de l'ancien répertoire /home"

# Vérification avant suppression
if [[ "$mount_point_root/home" =~ ^/mnt_tmp/ ]] && [[ -d "$mount_point_root/home" ]]; then
    log_info "Suppression du contenu de l'ancien /home..."
    rm -rf "${mount_point_root:?}/home"/*
else
    log_error "Chemin invalide pour la suppression : $mount_point_root/home"
    exit 1
fi

# =====================================================
# Configuration de fstab
# =====================================================

log_step "Configuration de /etc/fstab"

# Sauvegarde de fstab
fstab_path="$mount_point_root/etc/fstab"
if [[ -f "$fstab_path" ]]; then
    cp "$fstab_path" "$fstab_path.backup.$(date +%Y%m%d_%H%M%S)"
    log_success "Sauvegarde de fstab créée."
else
    log_error "Le fichier fstab n'existe pas à l'emplacement attendu."
    exit 1
fi

# Demander les options de montage
read -rp "Voulez-vous utiliser l'option 'discard' pour la partition home ? (y/n) " use_discard
echo

if [[ "$use_discard" =~ ^[Yy]$ ]]; then
    mount_options="defaults,discard"
    log_info "L'option 'discard' sera ajoutée."
else
    mount_options="defaults"
    log_info "L'option 'discard' ne sera pas ajoutée."
fi

# Obtenir l'UUID de la partition home
home_uuid=$(blkid -s UUID -o value "$home_partition")
if [[ -z "$home_uuid" ]]; then
    log_warning "Impossible d'obtenir l'UUID de $home_partition, utilisation du chemin du périphérique."
    home_identifier="$home_partition"
else
    home_identifier="UUID=$home_uuid"
    log_info "UUID de la partition home : $home_uuid"
fi

# Ajouter l'entrée dans fstab
fstab_entry="$home_identifier /home   ext4  $mount_options       0  2"
echo "$fstab_entry" | tee -a "$fstab_path" > /dev/null
log_success "Entrée ajoutée à fstab :"
echo -e "${YELLOW}$fstab_entry${RESET}"

# =====================================================
# Nettoyage et finalisation
# =====================================================

log_step "Nettoyage et finalisation"

# Démontage des partitions
umount "$mount_point_root"
umount "$mount_point_home"

# Suppression des points de montage temporaires
rmdir "$mount_point_root" 2>/dev/null || log_warning "Impossible de supprimer $mount_point_root (non vide ?)"
rmdir "$mount_point_home" 2>/dev/null || log_warning "Impossible de supprimer $mount_point_home (non vide ?)"

# =====================================================
# Instructions finales
# =====================================================

log_step "Opération terminée avec succès !"
log_info "Voici ce que vous devez faire maintenant :"
echo -e "${BOLD}1.${RESET} Fermez toutes les applications ouvertes"
echo -e "${BOLD}2.${RESET} Redémarrez votre système"
echo -e "${BOLD}3.${RESET} Après le redémarrage, vérifiez que :"
echo -e "   - Votre partition home est bien montée : ${CYAN}lsblk${RESET}"
echo -e "   - Vos fichiers sont accessibles : ${CYAN}ls ~/${RESET}"
echo -e "   - Le fichier fstab est correct : ${CYAN}cat /etc/fstab${RESET}"
echo
log_warning "Si le système ne démarre pas correctement :"
echo -e "1. Démarrez depuis un live USB"
echo -e "2. Montez votre partition racine"
echo -e "3. Restaurez la sauvegarde de fstab :"
echo -e "   ${CYAN}sudo cp /mnt/etc/fstab.backup.* /mnt/etc/fstab${RESET}"
echo

log_success "Script terminé. Redémarrez votre système pour appliquer les changements."
