-- Script d'initialisation de la table menu
-- À exécuter après init-db.sql

-- Connexion à la base de données reservation_db
\c reservation_db;

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

-- Index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_menu_categorie ON menu(categorie);
CREATE INDEX IF NOT EXISTS idx_menu_disponible ON menu(disponible);
CREATE INDEX IF NOT EXISTS idx_menu_nom ON menu(nom);

-- Trigger pour mettre à jour updated_at automatiquement
CREATE TRIGGER update_menu_updated_at 
    BEFORE UPDATE ON menu 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Insertion des plats de test avec des images Pexels libres de droit
INSERT INTO menu (nom, description, prix, image_url, categorie, disponible) VALUES 

-- ENTRÉES
('Salade César', 'Salade romaine fraîche, croûtons dorés, copeaux de parmesan et notre sauce César maison', 12.50, 'https://images.pexels.com/photos/1059905/pexels-photo-1059905.jpeg?auto=compress&cs=tinysrgb&w=800', 'entree', true),

('Bruschetta Italienne', 'Pain grillé garni de tomates fraîches, basilic, ail et huile d''olive extra vierge', 9.80, 'https://images.pexels.com/photos/1438672/pexels-photo-1438672.jpeg?auto=compress&cs=tinysrgb&w=800', 'entree', true),

('Soupe à l''Oignon Gratinée', 'Soupe traditionnelle française aux oignons caramélisés, gratinée au fromage', 11.20, 'https://images.pexels.com/photos/539451/pexels-photo-539451.jpeg?auto=compress&cs=tinysrgb&w=800', 'entree', true),

-- PLATS PRINCIPAUX
('Saumon Grillé aux Herbes', 'Filet de saumon grillé, légumes de saison et sauce à l''aneth', 24.90, 'https://images.pexels.com/photos/1516415/pexels-photo-1516415.jpeg?auto=compress&cs=tinysrgb&w=800', 'plat_principal', true),

('Bœuf Bourguignon', 'Bœuf mijoté au vin rouge avec carottes, champignons et pommes de terre', 22.50, 'https://images.pexels.com/photos/8477/food-dinner-beef-meat.jpg?auto=compress&cs=tinysrgb&w=800', 'plat_principal', true),

('Risotto aux Champignons', 'Riz arborio crémeux aux champignons de saison et parmesan', 18.70, 'https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg?auto=compress&cs=tinysrgb&w=800', 'plat_principal', true),

('Pizza Margherita', 'Pizza traditionnelle avec sauce tomate, mozzarella fraîche et basilic', 16.90, 'https://images.pexels.com/photos/315755/pexels-photo-315755.jpeg?auto=compress&cs=tinysrgb&w=800', 'plat_principal', true),

-- DESSERTS
('Tiramisu Maison', 'Dessert italien traditionnel au café et mascarpone', 8.50, 'https://images.pexels.com/photos/6880219/pexels-photo-6880219.jpeg?auto=compress&cs=tinysrgb&w=800', 'dessert', true),

('Tarte Tatin', 'Tarte aux pommes caramélisées servie tiède avec une boule de glace vanille', 9.20, 'https://images.pexels.com/photos/1126359/pexels-photo-1126359.jpeg?auto=compress&cs=tinysrgb&w=800', 'dessert', true),

('Mousse au Chocolat', 'Mousse onctueuse au chocolat noir 70% avec chantilly maison', 7.80, 'https://images.pexels.com/photos/2067396/pexels-photo-2067396.jpeg?auto=compress&cs=tinysrgb&w=800', 'dessert', true),

-- BOISSONS
('Vin Rouge - Côtes du Rhône', 'Vin rouge français AOC, bouteille 75cl', 28.00, 'https://images.pexels.com/photos/434311/pexels-photo-434311.jpeg?auto=compress&cs=tinysrgb&w=800', 'boisson', true),

('Café Espresso', 'Café italien traditionnel servi dans une tasse en porcelaine', 3.50, 'https://images.pexels.com/photos/302899/pexels-photo-302899.jpeg?auto=compress&cs=tinysrgb&w=800', 'boisson', true);

-- Affichage du résultat
SELECT 'Table menu créée et ' || COUNT(*) || ' plats insérés avec succès!' as resultat FROM menu; 