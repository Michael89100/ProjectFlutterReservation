# 🍽️ Application de Réservation Restaurant

Application mobile Flutter complète avec backend Node.js pour la gestion des réservations de restaurant. L'application permet aux clients de consulter le menu, faire des réservations et aux serveurs de gérer les commandes et réservations.

## 📱 Aperçu du Projet

Cette application se compose de deux parties principales :
- **Frontend Flutter** (`project_front/`) - Application mobile cross-platform
- **Backend Node.js** (`project_back/`) - API REST avec base de données PostgreSQL

## 🚀 Fonctionnalités Réalisées

### 🔐 Authentification et Gestion des Utilisateurs
- ✅ Inscription et connexion sécurisées
- ✅ Gestion des rôles (Client/Serveur)
- ✅ Authentification JWT
- ✅ Validation des formulaires
- ✅ Gestion de session persistante

### 🍽️ Gestion du Menu
- ✅ Affichage du menu par catégories (Entrées, Plats, Desserts, Boissons)
- ✅ Interface moderne avec cartes visuelles
- ✅ Recherche et filtrage des plats
- ✅ Gestion CRUD complète pour les serveurs
- ✅ Ajout/modification/suppression de plats

### 📅 Système de Réservation
- ✅ Interface de réservation intuitive
- ✅ Sélection de date et heure
- ✅ Choix du nombre de personnes
- ✅ Gestion des réservations par les serveurs
- ✅ Historique des réservations

### 🎨 Interface Utilisateur
- ✅ Design moderne et responsive
- ✅ Navigation fluide avec bottom navigation
- ✅ Thème cohérent avec couleurs personnalisées
- ✅ Animations et transitions
- ✅ Indicateurs de chargement

### 🔒 Sécurité
- ✅ Hashage des mots de passe (bcrypt)
- ✅ Protection CORS
- ✅ Limitation de taux (Rate limiting)
- ✅ Validation des données côté serveur
- ✅ Gestion d'erreurs robuste

## 🛠️ Technologies Utilisées

### Frontend (Flutter)
- **Flutter** 3.7.0+ - Framework de développement mobile
- **Provider** - Gestion d'état
- **HTTP** - Requêtes API
- **SharedPreferences** - Stockage local
- **EmailValidator** - Validation d'email
- **FlutterSpinKit** - Indicateurs de chargement
- **Intl** - Formatage des dates

### Backend (Node.js)
- **Node.js** + **Express** - Serveur API REST
- **PostgreSQL** - Base de données
- **JWT** - Authentification
- **Bcrypt** - Hashage des mots de passe
- **Joi** - Validation des données
- **Helmet** - Sécurité HTTP
- **Swagger** - Documentation API
- **CORS** - Gestion des origines croisées

## 📋 Prérequis

### Pour le Frontend Flutter
- **Flutter SDK** 3.7.0 ou supérieur
- **Dart SDK** 3.0.0 ou supérieur
- **Android Studio** ou **VS Code** avec extensions Flutter
- **Émulateur Android/iOS** ou appareil physique

### Pour le Backend
- **Node.js** 18.0 ou supérieur
- **PostgreSQL** 12.0 ou supérieur
- **npm** ou **yarn**

## 🚀 Instructions de Lancement

### 1. Configuration du Backend

#### Installation des dépendances
```bash
cd project_back
npm install
```

#### Configuration de l'environnement
```bash
# Copiez le fichier de configuration
cp config.env .env

# Modifiez le fichier .env avec vos paramètres
```

#### Configuration de PostgreSQL
```bash
# Créez la base de données (executez ligne par ligne)
psql -U postgres

# Possible que le copier coller ne fonctionne pas
CREATE DATABASE reservation_db;
\q

# Initialisez les tables

# Depuis le dossier project_back pour windows
psql -U postgres -d reservation_db -f scripts/init-db.sql

# Depuis le dossier project_back pour mac/linux
psql -d reservation_db -f scripts/init-db.sql

# Peuplez les données de démonstration
npm run fixtures
```

#### Démarrage du serveur
```bash
# Mode développement
npm run dev
```

Le serveur sera accessible sur : **http://localhost:3000**

Documentation API : **http://localhost:3000/api-docs**

### 2. Configuration du Frontend Flutter

#### Installation des dépendances
```bash
cd project_front
flutter pub get
```

#### Configuration de l'API
Assurez-vous que l'URL de l'API dans le code Flutter correspond à votre serveur backend (par défaut : `http://localhost:3000`).

#### Lancement de l'application
```bash
# Vérifiez les appareils disponibles
flutter devices

# Lancez l'application
flutter run

# Ou pour un appareil spécifique
flutter run -d <device_id>

# Pour le web
flutter run -d chrome
```

## 🔑 Comptes de Démonstration

Le système est livré avec des comptes de test :

### Client
- **Email :** `client@restaurant.com`
- **Mot de passe :** `Client123!`

### Serveur
- **Email :** `serveur@restaurant.com`
- **Mot de passe :** `Serveur123!`

## 📱 Utilisation de l'Application

### Pour les Clients
1. **Inscription/Connexion** - Créez un compte ou connectez-vous
2. **Consultation du Menu** - Parcourez les plats par catégorie
3. **Réservation** - Sélectionnez date, heure et nombre de personnes
4. **Historique** - Consultez vos réservations passées

### Pour les Serveurs
1. **Connexion** - Utilisez un compte serveur
2. **Gestion du Menu** - Ajoutez, modifiez ou supprimez des plats
3. **Gestion des Réservations** - Visualisez et gérez toutes les réservations
4. **Administration** - Accès aux fonctionnalités d'administration

## 🏗️ Architecture du Projet

```
ProjectFlutterReservation/
├── project_front/          # Application Flutter
│   ├── lib/
│   │   ├── models/         # Modèles de données
│   │   ├── services/       # Services API
│   │   ├── viewmodels/     # Logique métier
│   │   └── views/          # Interfaces utilisateur
│   │       ├── auth/       # Authentification
│   │       ├── home/       # Écran d'accueil
│   │       ├── menu/       # Gestion du menu
│   │       └── reservations/ # Gestion des réservations
│   └── pubspec.yaml        # Dépendances Flutter
├── project_back/           # API Backend
│   ├── controllers/        # Contrôleurs API
│   ├── models/            # Modèles de données
│   ├── routes/            # Routes API
│   ├── middleware/        # Middlewares
│   ├── config/            # Configuration
│   └── scripts/           # Scripts utilitaires
└── README.md              # Ce fichier
```

## 📄 Documentation

- **Documentation API** : Disponible sur `/api-docs` une fois le serveur démarré
- **Documentation Flutter** : Consultez les commentaires dans le code source
- **Base de données** : Schéma disponible dans `project_back/scripts/init-db.sql`
