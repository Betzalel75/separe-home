# 🎯 DVWA Multi-Instance Docker Compose - Environnement Pédagogique

Un système Docker Compose modulaire pour déployer plusieurs instances isolées de **DVWA** (Damn Vulnerable Web Application) destiné à un environnement d'apprentissage en cybersécurité.

## 🎯 Objectif Pédagogique

Ce système a été conçu spécifiquement pour les **environnements de formation** où plusieurs étudiants doivent travailler simultanément sur des instances indépendantes de DVWA, sans interférer les uns avec les autres.

### Pourquoi cette architecture ?

- **Isolation complète** : Chaque étudiant a son propre environnement
- **Indépendance** : Les actions d'un étudiant n'affectent pas les autres
- **Reproductibilité** : Même configuration pour tous les participants
- **Facilité de gestion** : Déploiement et nettoyage simplifiés

## 🏗️ Architecture Modulaire

### Structure des Services

```
┌─────────────────────────────────────────────────────────────┐
│                     Hôte Principal                          │
├─────────────┬──────────────┬────────────────┬───────────────┤
│  Instance 1 │  Instance 2  │  Instance 3    │  ...          │
│  (Port 4281)│  (Port 4282) │  (Port 4283)   │               │
├─────────────┼──────────────┼────────────────┼───────────────┤
│   DVWA 1    │   DVWA 2     │   DVWA 3       │               │
│   + DB 1    │   + DB 2     │   + DB 3       │               │
└─────────────┴──────────────┴────────────────┴───────────────┘
```

### Caractéristiques Techniques

#### 1. **Isolation Réseau**
```yaml
networks:
  net_p1:  # Réseau privé pour Joueur 1
  net_p2:  # Réseau privé pour Joueur 2
  net_p3:  # Réseau privé pour Joueur 3
```
- Chaque instance a son propre réseau Docker
- Aucune communication inter-instances possible
- Sécurité renforcée contre les interférences

#### 2. **Isolation des Données**
```yaml
volumes:
  dvwa_db1:  # Volume dédié pour DB1
  dvwa_db2:  # Volume dédié pour DB2
  dvwa_db3:  # Volume dédié pour DB3
```
- Base de données MariaDB indépendante par instance
- Persistance des données entre les redémarrages
- Pas de contamination croisée des données

#### 3. **Configuration Portuaire**
```
Port 4281 → Instance 1 (Joueur 1)
Port 4282 → Instance 2 (Joueur 2)  
Port 4283 → Instance 3 (Joueur 3)
```
- Schéma de numérotation logique
- Facile à mémoriser et à attribuer
- Extensible à l'infini (4284, 4285, etc.)

## 🚀 Déploiement Rapide

### 1. Prérequis
```bash
# Vérifier l'installation de Docker et Docker Compose
docker --version
docker-compose --version
```

### 2. Lancement des instances
```bash
# Dans le répertoire contenant compose.yml
docker-compose up -d

# Vérifier l'état des services
docker-compose ps
```

### 3. Accès aux instances
```
Étudiant 1 : http://localhost:4281
Étudiant 2 : http://localhost:4282  
Étudiant 3 : http://localhost:4283
```

### 4. Arrêt et nettoyage
```bash
# Arrêter les instances (conserve les données)
docker-compose stop

# Arrêter et supprimer les conteneurs (conserve les données)
docker-compose down

# Arrêter, supprimer et nettoyer TOUT (données incluses)
docker-compose down -v
```

## ⚙️ Configuration DVWA

### Identifiants par défaut
```
URL : http://localhost:428X
Login : admin
Mot de passe : password
```

### Réinitialisation de la base de données
Chaque instance permet la réinitialisation via l'interface web :
1. Se connecter avec `admin/password`
2. Cliquer sur "Setup / Reset DB"
3. Confirmer la réinitialisation

## 🔧 Flexibilité et Extensibilité

### Ajouter une nouvelle instance
Pour ajouter un 4ème joueur, il suffit de dupliquer le bloc :

```yaml
# ==========================================
# JOUEUR 4 (Port 4284)
# ==========================================
dvwa4:
  image: ghcr.io/digininja/dvwa:latest
  environment:
    - DB_SERVER=db4
  depends_on:
    - db4
  networks:
    - net_p4
  ports:
    - "0.0.0.0:4284:80"
  restart: unless-stopped

db4:
  image: docker.io/library/mariadb:10
  environment:
    - MYSQL_ROOT_PASSWORD=dvwa
    - MYSQL_DATABASE=dvwa
    - MYSQL_USER=dvwa
    - MYSQL_PASSWORD=p@ssw0rd
  volumes:
    - dvwa_db4:/var/lib/mysql
  networks:
    - net_p4
  restart: unless-stopped
```

Et ajouter les volumes/réseaux correspondants.

### Personnalisation des configurations
Chaque instance peut être configurée indépendamment :
- Variables d'environnement spécifiques
- Ressources CPU/Mémoire différentes
- Versions d'images personnalisées

## ⚠️ Limitations et Considérations

### 1. **Ressources Système**
- Chaque instance consomme ~200-300MB de RAM
- Multiplication des ressources avec le nombre d'instances
- **Recommandation** : 1-2GB RAM par instance pour de bonnes performances

### 2. **Gestion à Grande Échelle**
- Au-delà de 10 instances, considérer un orchestrateur (Kubernetes)
- Gestion des logs centralisée recommandée
- Surveillance des ressources nécessaire

### 3. **Sécurité en Production**
- **NE PAS UTILISER EN PRODUCTION**
- Mots de passe par défaut à changer en environnement réel
- Exposition sur `0.0.0.0` à restreindre selon les besoins
- Isoler le réseau Docker de l'hôte

### 4. **Persistance des Données**
- Les volumes Docker persistent par défaut
- Sauvegardes régulières recommandées pour les données importantes
- Nettoyage manuel nécessaire pour libérer l'espace

## 🎓 Scénarios d'Utilisation Pédagogique

### 1. **Formation en Classe**
- Chaque étudiant a sa propre instance
- Travaux pratiques simultanés
- Évaluation individuelle des compétences

### 2. **Compétitions CTF**
- Environnements identiques pour tous les participants
- Isolation garantissant l'équité
- Réinitialisation facile entre les épreuves

### 3. **Laboratoires de Recherche**
- Tests reproductibles
- Environnements jetables
- Comparaison de résultats

### 4. **Démonstrations Live**
- Instances dédiées pour les démonstrations
- Pas d'interférence avec les environnements existants
- Nettoyage rapide après utilisation

## 🔒 Bonnes Pratiques de Sécurité

### Pour l'Environnement de Formation
```bash
# 1. Changer les mots de passe par défaut
# Modifier dans compose.yml avant le déploiement

# 2. Restreindre l'accès réseau
# Remplacer "0.0.0.0" par l'IP spécifique si nécessaire

# 3. Mettre à jour régulièrement
docker-compose pull
docker-compose up -d

# 4. Journalisation et monitoring
docker-compose logs -f
```

### Pour les Étudiants
- Ne pas exposer les instances sur Internet
- Réinitialiser les bases de données après utilisation
- Signaler les vulnérabilités découvertes
- Respecter les politiques d'utilisation acceptable

## 🛠️ Commandes Utiles

### Surveillance
```bash
# Voir les logs en temps réel
docker-compose logs -f dvwa1

# Consommation des ressources
docker stats

# État des conteneurs
docker-compose ps
```

### Maintenance
```bash
# Mettre à jour toutes les images
docker-compose pull

# Redémarrer une instance spécifique
docker-compose restart dvwa2

# Voir la configuration effective
docker-compose config
```

### Dépannage
```bash
# Accéder au shell d'un conteneur
docker-compose exec db1 bash

# Inspecter un conteneur
docker inspect dvwa-setup_dvwa1_1

# Voir les logs détaillés
docker-compose logs --tail=100 dvwa1
```

## 📚 Ressources Complémentaires

### Documentation Officielle
- [DVWA GitHub](https://github.com/digininja/DVWA)
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)

### Sécurité et Best Practices
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [DVWA Security Guide](https://github.com/digininja/DVWA#security)
- [Docker Security Best Practices](https://docs.docker.com/engine/security/)

## 📄 Licence

Ce projet utilise des images sous leurs licences respectives :
- **DVWA** : [License](https://github.com/digininja/DVWA/blob/master/LICENSE)
- **MariaDB** : [GPL v2](https://mariadb.com/kb/en/mariadb-license/)

**⚠️ Attention** : Ce système est conçu uniquement pour des environnements d'apprentissage contrôlés.

---

**🎓 Bonne formation et hack responsable !**
