# API de Réservation - Backend

API REST pour l'application de réservation avec authentification JWT, développée avec Node.js, Express et PostgreSQL.

## 🚀 Fonctionnalités

- ✅ Authentification JWT sécurisée
- ✅ Inscription et connexion des utilisateurs
- ✅ Gestion des rôles (client/serveur)
- ✅ Validation des données avec Joi
- ✅ Sécurité renforcée avec Helmet
- ✅ Limitation de taux (Rate limiting)
- ✅ Documentation Swagger interactive
- ✅ Hashage sécurisé des mots de passe
- ✅ Gestion d'erreurs robuste
- ✅ Logs de sécurité

## 📋 Prérequis

- **Node.js** (version 18 ou supérieure)
- **PostgreSQL** (version 12 ou supérieure)
- **npm** ou **yarn**

## 🛠️ Installation

### 1. Cloner le projet et installer les dépendances

```bash
cd project_back
npm install
```

### 2. Configuration de l'environnement

Copiez le fichier de configuration et adaptez-le :

```bash
cp config.env .env
```

Modifiez le fichier `.env` avec vos paramètres :

```env
# Configuration du serveur
PORT=3000
NODE_ENV=development

# Configuration de la base de données PostgreSQL
DB_HOST=localhost
DB_PORT=5432
DB_NAME=reservation_db
DB_USER=postgres
DB_PASSWORD=votre_mot_de_passe

# Configuration JWT
JWT_SECRET=votre_secret_jwt_super_securise_changez_moi_en_production
JWT_EXPIRES_IN=24h

# Configuration CORS
CORS_ORIGIN=http://localhost:3000
```

## 🗄️ Configuration de la base de données

### Installation de PostgreSQL

#### Windows
1. Téléchargez PostgreSQL depuis [postgresql.org](https://www.postgresql.org/download/windows/)
2. Suivez l'assistant d'installation
3. Notez le mot de passe du superutilisateur `postgres`

#### macOS (avec Homebrew)
```bash
brew install postgresql
brew services start postgresql
```

#### Ubuntu/Debian
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

### Création de la base de données

1. **Connectez-vous à PostgreSQL :**
```bash
# Windows
psql -U postgres

# macOS/Linux
sudo -u postgres psql
```

2. **Créez la base de données :**
```sql
CREATE DATABASE reservation_db;
\q
```

3. **Initialisez les tables :**
```bash
# Depuis le dossier project_back
psql -U postgres -d reservation_db -f scripts/init-db.sql
psql -d reservation_db -f scripts/init-db.sql
```

Ou manuellement :
```bash
psql -U postgres -d reservation_db
```
Puis copiez-collez le contenu du fichier `scripts/init-db.sql`.

## 🚀 Démarrage

### Mode développement (avec rechargement automatique)
```bash
npm run dev
```

### Mode production
```bash
npm start
```

Le serveur sera accessible sur : http://localhost:3000

## 📚 Documentation API

Une fois le serveur démarré, accédez à la documentation Swagger interactive :

**🔗 http://localhost:3000/api-docs**

## 🔗 Endpoints disponibles

### Authentification
- `POST /api/auth/register` - Inscription d'un nouvel utilisateur
- `POST /api/auth/login` - Connexion d'un utilisateur
- `GET /api/auth/profile` - Profil de l'utilisateur connecté (authentifié)
- `GET /api/auth/verify` - Vérification du token JWT (authentifié)

### Utilitaires
- `GET /` - Informations sur l'API
- `GET /health` - État de santé du serveur

## 🧪 Test des endpoints

### 1. Inscription d'un utilisateur

```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "nom": "Dupont",
    "prenom": "Jean",
    "email": "jean.dupont@example.com",
    "password": "MonMotDePasse123!",
    "role": "client"
  }'
```

### 2. Connexion

```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "jean.dupont@example.com",
    "password": "MonMotDePasse123!"
  }'
```

### 3. Accès au profil (avec token)

```bash
curl -X GET http://localhost:3000/api/auth/profile \
  -H "Authorization: Bearer VOTRE_TOKEN_JWT"
```

## 🔒 Sécurité

### Exigences pour les mots de passe
- Minimum 8 caractères
- Au moins 1 majuscule
- Au moins 1 minuscule  
- Au moins 1 chiffre
- Au moins 1 caractère spécial (@$!%*?&)

### Limitation de taux
- **Authentification** : 5 tentatives par 15 minutes par IP/email
- **API générale** : 100 requêtes par 15 minutes par IP

### Sécurité des headers
- Protection CSRF
- Headers de sécurité avec Helmet
- CORS configuré
- Validation stricte des données

## 🗂️ Structure du projet

```
project_back/
├── config/
│   ├── database.js          # Configuration PostgreSQL
│   └── swagger.js           # Configuration Swagger
├── controllers/
│   └── authController.js    # Contrôleur d'authentification
├── middleware/
│   ├── auth.js             # Middleware JWT
│   ├── security.js         # Middlewares de sécurité
│   └── validation.js       # Validation des données
├── models/
│   └── User.js             # Modèle utilisateur
├── routes/
│   └── auth.js             # Routes d'authentification
├── scripts/
│   └── init-db.sql         # Script d'initialisation DB
├── config.env              # Variables d'environnement
├── index.js                # Point d'entrée
├── package.json            # Dépendances
└── README.md              # Documentation
```

## 🐛 Dépannage

### Erreur de connexion à PostgreSQL
1. Vérifiez que PostgreSQL est démarré
2. Vérifiez les paramètres de connexion dans `.env`
3. Testez la connexion manuellement :
```bash
psql -U postgres -h localhost -p 5432 -d reservation_db
```

### Port déjà utilisé
```bash
# Trouver le processus utilisant le port 3000
lsof -i :3000  # macOS/Linux
netstat -ano | findstr :3000  # Windows

# Tuer le processus
kill -9 PID  # macOS/Linux
taskkill /PID PID /F  # Windows
```

### Erreurs de dépendances
```bash
# Nettoyer et réinstaller
rm -rf node_modules package-lock.json
npm install
```

## 🔧 Variables d'environnement

| Variable | Description | Valeur par défaut |
|----------|-------------|-------------------|
| `PORT` | Port du serveur | `3000` |
| `NODE_ENV` | Environnement | `development` |
| `DB_HOST` | Hôte PostgreSQL | `localhost` |
| `DB_PORT` | Port PostgreSQL | `5432` |
| `DB_NAME` | Nom de la base | `reservation_db` |
| `DB_USER` | Utilisateur DB | `postgres` |
| `DB_PASSWORD` | Mot de passe DB | `password` |
| `JWT_SECRET` | Secret JWT | ⚠️ **À changer** |
| `JWT_EXPIRES_IN` | Durée du token | `24h` |
| `CORS_ORIGIN` | Origine CORS | `http://localhost:3000` |

## 📝 Logs

Les logs incluent :
- ✅ Connexions à la base de données
- ⚠️ Tentatives de connexion suspectes
- ❌ Erreurs d'authentification
- 🚨 Activités malveillantes détectées
- 📊 Limitations de taux atteintes

## 🤝 Contribution

1. Fork le projet
2. Créez une branche feature (`git checkout -b feature/nouvelle-fonctionnalite`)
3. Committez vos changements (`git commit -m 'Ajout nouvelle fonctionnalité'`)
4. Push vers la branche (`git push origin feature/nouvelle-fonctionnalite`)
5. Ouvrez une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

---

**🎯 Prêt à développer !** Votre API de réservation est maintenant configurée et prête à l'emploi. 