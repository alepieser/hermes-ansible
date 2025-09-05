# Unbound DNS Server Role

Ce rôle Ansible installe et configure Unbound, un serveur DNS récursif sécurisé et performant avec une architecture modulaire unifiée.

## 🚀 **Nouvelles fonctionnalités (v2)**

- ✅ **Architecture unifiée** : Tous les templates dans un seul dossier
- ✅ **Optimisations automatiques** : Cache et threads calculés selon les ressources système
- ✅ **Sécurité renforcée** : Protection avancée contre les attaques DNS
- ✅ **Privacy optimisée** : Configuration pour maximiser la confidentialité
- ✅ **Performance adaptative** : Ajustement automatique selon la RAM et CPU

## 📁 **Structure modulaire unifiée**

```
roles/unbound/
├── defaults/main.yml          # Variables et calculs automatiques
├── tasks/main.yml             # Tâches d'installation
├── handlers/main.yml          # Gestion des redémarrages
└── templates/                 # Templates Jinja2 dynamiques
    ├── unbound.conf.j2       # Configuration de base (réseau uniquement)
    ├── security.conf.j2      # 🛡️ Sécurité et protection
    ├── privacy.conf.j2       # 🔒 Privacy et confidentialité
    ├── dnssec.conf.j2        # 🔐 Configuration DNSSEC
    ├── optimizations.conf.j2 # ⚡ Performance et ressources
    ├── logging.conf.j2       # 📊 Logs et monitoring
    ├── local-zones.conf.j2   # Zones locales
    └── forward-zones.conf.j2 # Forward zones unifié (DoT + zones spécifiques)
```

## 🔧 **Variables**

### **Calculs automatiques**
- `unbound_host_memory`: RAM totale du système
- `unbound_host_threads`: Nombre de threads CPU
- `unbound_optimizations`: Cache et performance calculés automatiquement

### **Configuration réseau**
- `unbound_listen_addresses`: Adresses d'écoute (défaut: 127.0.0.1)
- `unbound_port`: Port DNS (défaut: 53)

### **Zones locales**
```yaml
unbound_local_zones:
  - name: "hermes.local"
    type: static
    records:
      - "hermes.hermes.local. IN A 192.168.1.10"
```

### **Zones de transfert**
```yaml
unbound_forward_zones:
  - name: "example.com"
    servers:
      - "8.8.8.8"
      - "8.8.4.4"
```

### **DNS over TLS (DoT)**
```yaml
unbound_dot_enabled: true
unbound_dot_providers:
  - name: "Cloudflare"
    servers:
      - "1.1.1.1@853#cloudflare-dns.com"
      - "1.0.0.1@853#cloudflare-dns.com"
  - name: "Quad9"
    servers:
      - "9.9.9.9@853#dns.quad9.net"
      - "149.112.112.112@853#dns.quad9.net"
```

**Exemple d'utilisation avancée :**
```yaml
# Configuration personnalisée avec d'autres fournisseurs
unbound_dot_providers:
  - name: "AdGuard DNS"
    servers:
      - "94.140.14.14@853#dns.adguard.com"
      - "94.140.15.15@853#dns.adguard.com"
  - name: "OpenDNS"
    servers:
      - "208.67.222.222@853#dns.opendns.com"
      - "208.67.220.220@853#dns.opendns.com"
```

### **Système de forward unifié**
Le fichier `forward-zones.conf.j2` gère automatiquement :
- **Forward global** : Toutes les requêtes via DNS over TLS (Cloudflare/Quad9)
- **Zones spécifiques** : Forward personnalisé pour des domaines particuliers
- **Priorité intelligente** : Les zones spécifiques ont la priorité sur le forward global

**Exemple de configuration complète :**
```yaml
# Forward global avec DoT (par défaut)
unbound_dot_enabled: true
unbound_dot_providers:
  - name: "Cloudflare"
    servers:
      - "1.1.1.1@853#cloudflare-dns.com"
      - "1.0.0.1@853#cloudflare-dns.com"

# Zones spécifiques avec priorité
unbound_forward_zones:
  - name: "internal.company.com"
    servers:
      - "10.0.0.10"
      - "10.0.0.11"
    forward_tls: false  # Pas de TLS pour les serveurs internes
  - name: "blocked-domain.com"
    servers:
      - "0.0.0.0"  # Blocage en redirigeant vers 0.0.0.0
```

## 🚀 **Utilisation**

### **Installation avec le setup complet**
```bash
make setup-unbound
```

### **Installation manuelle**
```bash
ansible-playbook -i inventory/hosts.yml playbooks/setup.yml --tags unbound
```

## 🏷️ **Tags**

- `unbound`: Toutes les tâches du rôle
- `install`: Installation des paquets
- `config`: Configuration des fichiers
- `service`: Gestion du service
- `test`: Tests de fonctionnement

## 🛡️ **Sécurité**

### **Protection avancée**
- **Rate limiting** : 1000 requêtes/seconde max
- **Cache poisoning protection** : Seuil de 10M réponses indésirables
- **DNSSEC validation** : Vérification cryptographique obligatoire
- **Query filtering** : Blocage des requêtes ANY malveillantes

### **Hardening DNS**
- `harden-algo-downgrade`: Protection contre la dégradation d'algorithmes
- `harden-below-nxdomain`: Protection RFC 8020
- `harden-dnssec-stripped`: Validation DNSSEC stricte
- `harden-glue`: Validation des enregistrements glue

### **DNS over TLS (DoT)**
- **Chiffrement TLS** : Toutes les requêtes DNS sortantes sont chiffrées
- **Serveurs sécurisés** : Cloudflare et Quad9 avec validation TLS
- **Privacy maximale** : Aucune interception possible des requêtes DNS
- **Fallback intelligent** : Basculement automatique entre serveurs

### **Privacy avancée (privacy.conf.j2)**
- **NSEC agressif** : Cache NSEC pour performance et privacy (RFC 8198)
- **QNAME minimisation** : Envoi minimal d'informations aux serveurs upstream
- **Delay-close** : Protection contre les attaques timing (10 secondes)
- **Cache négatif** : Cache des réponses NXDOMAIN (4M)
- **Préchargement intelligent** : Préchargement des enregistrements expirants
- **Préférence IPv4** : Évite les problèmes IPv6 pour la privacy
- **Contrôle distant désactivé** : Sécurité renforcée

### **Privacy ultra-avancée (nouvelles optimisations)**
- **QNAME minimisation stricte** : RFC 7816 complète
- **Réponses minimales** : Exposition minimale des données
- **Protection timing avancée** : Jitter aléatoire (200ms)
- **Cache expiré désactivé** : Pas de fuite d'informations
- **Protection rebinding** : Blocage des attaques DNS rebinding
- **Validation DNSSEC stricte** : Mode non-permissif

### **Sécurité renforcée (security.conf.j2)**
- **Contrôle d'accès strict** : Seulement localhost et LAN
- **Hardening DNS** : Protection contre les attaques algorithmiques
- **Rate limiting** : 1000 requêtes/seconde max
- **Protection amplification** : Limitation taille UDP (4KB)
- **Validation DNSSEC stricte** : Mode non-permissif
- **Protection rebinding** : Blocage des domaines invalides
- **Seuil anti-poisoning** : 10M réponses indésirables

## 🔒 **Privacy**

### **Confidentialité maximale**
- `qname-minimisation`: Envoi minimal d'informations aux serveurs upstream
- `aggressive-nsec`: Cache NSEC pour la performance et la privacy
- `delay-close`: Protection contre les attaques timing
- `prefetch`: Préchargement intelligent des enregistrements

## ⚡ **Performance**

### **Optimisations automatiques**
- **Cache adaptatif** : Taille basée sur la RAM disponible
- **Threads optimisés** : Nombre basé sur les CPU
- **Slabs calculés** : Optimisation mémoire selon les ressources
- **Buffer tuning** : Sockets et connexions TCP optimisés

### **Optimisations privacy-friendly**
- **Cache intelligent** : Évite les requêtes répétées
- **Préchargement** : Réduit la latence et les requêtes sortantes
- **NSEC agressif** : Réponses négatives depuis le cache
- **TLS persistant** : Connexions TLS réutilisées

### **Optimisations spécifiques RPi 4**
- **Allocation mémoire équilibrée** : Adaptée aux 5 services essentiels
- **Cache optimisé** : msg-cache: 94MB, rrset-cache: 188MB (total: ~282MB)
- **Buffers réseau équilibrés** : 3MB (compromis performance/mémoire)
- **Connexions TCP optimisées** : 8 (équilibre entre performance et ressources)
- **Cache négatif équilibré** : 3MB (performance et mémoire optimisées)

## 📊 **Monitoring**

### **Logs et statistiques**
- Intégration syslog
- Verbosité configurable
- Statistiques de cache
- Monitoring des performances

## 🧪 **Tests**

Le rôle inclut des tests automatiques :
- Vérification du port d'écoute
- Test de résolution DNS locale
- Test de résolution DNS externe
- Validation de la configuration