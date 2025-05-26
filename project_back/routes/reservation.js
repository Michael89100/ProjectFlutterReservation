const express = require('express');
const router = express.Router();
const reservationController = require('../controllers/reservationController');
const { authenticateToken } = require('../middleware/auth');

// Créer une réservation (authentifié)
router.post('/', authenticateToken, reservationController.createReservation);

// Obtenir les réservations (authentifié, filtrage par rôle)
router.get('/', authenticateToken, reservationController.getReservations);

// Supprimer une réservation (authentifié, contrôle d'accès dans le contrôleur)
router.delete('/:id', authenticateToken, reservationController.deleteReservation);

module.exports = router;
