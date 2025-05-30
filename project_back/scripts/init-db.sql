-- Création de la base de données (à exécuter en tant que superuser)
-- CREATE DATABASE reservation_db;

-- Connexion à la base de données reservation_db
\c reservation_db;

-- Extension pour UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Table des utilisateurs
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    telephone VARCHAR(20) NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('client', 'serveur')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);

-- Trigger pour mettre à jour updated_at automatiquement
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON users 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Table du menu
CREATE TABLE IF NOT EXISTS menu (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nom VARCHAR(100) NOT NULL UNIQUE,
    description TEXT NOT NULL,
    prix DECIMAL(10,2) NOT NULL CHECK (prix >= 0),
    image_url VARCHAR(500) NOT NULL,
    categorie VARCHAR(20) NOT NULL CHECK (categorie IN ('entree', 'plat_principal', 'dessert', 'boisson')),
    disponible BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Index pour améliorer les performances du menu
CREATE INDEX IF NOT EXISTS idx_menu_categorie ON menu(categorie);
CREATE INDEX IF NOT EXISTS idx_menu_disponible ON menu(disponible);
CREATE INDEX IF NOT EXISTS idx_menu_nom ON menu(nom);

-- Trigger pour mettre à jour updated_at automatiquement pour le menu
CREATE TRIGGER update_menu_updated_at 
    BEFORE UPDATE ON menu 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Table des réservations
CREATE TABLE IF NOT EXISTS reservations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    horaire TIMESTAMP WITH TIME ZONE NOT NULL,
    nombre_couverts INTEGER NOT NULL CHECK (nombre_couverts > 0),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL DEFAULT 'en attente' CHECK (status IN ('en attente', 'acceptée', 'refusée', 'acceptee', 'refusee')),
    date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Index pour les réservations
CREATE INDEX IF NOT EXISTS idx_reservations_user_id ON reservations(user_id);
CREATE INDEX IF NOT EXISTS idx_reservations_status ON reservations(status);
CREATE INDEX IF NOT EXISTS idx_reservations_horaire ON reservations(horaire);

-- Données de test (optionnel)
-- INSERT INTO users (nom, prenom, email, password, role) VALUES 
-- ('Doe', 'John', 'john.doe@example.com', '$2a$10$example_hash', 'client'),
-- ('Smith', 'Jane', 'jane.smith@example.com', '$2a$10$example_hash', 'serveur');