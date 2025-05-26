-- Migration pour mettre à jour la contrainte de vérification du statut
-- Supprimer l'ancienne contrainte
ALTER TABLE reservations DROP CONSTRAINT IF EXISTS reservations_status_check;

-- Ajouter la nouvelle contrainte avec les statuts sans accents
ALTER TABLE reservations ADD CONSTRAINT reservations_status_check 
CHECK (status IN ('en attente', 'acceptée', 'refusée', 'acceptee', 'refusee')); 