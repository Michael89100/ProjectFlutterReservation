const express = require('express');
const router = express.Router();
const reservationController = require('../controllers/reservationController');
const { authenticateToken } = require('../middleware/auth');

/**
 * @swagger
 * tags:
 *   name: Réservations
 *   description: Gestion des réservations
 */

/**
 * @swagger
 * /api/reservations:
 *   post:
 *     summary: Créer une réservation
 *     tags: [Réservations]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - nom
 *               - telephone
 *               - nombreCouverts
 *             properties:
 *               nom:
 *                 type: string
 *               telephone:
 *                 type: string
 *               nombreCouverts:
 *                 type: integer
 *     responses:
 *       201:
 *         description: Réservation créée
 *       400:
 *         description: Erreur de validation
 *       401:
 *         description: Non authentifié
 */
router.post('/', authenticateToken, reservationController.createReservation);

/**
 * @swagger
 * /api/reservations:
 *   get:
 *     summary: Obtenir les réservations (selon le rôle)
 *     tags: [Réservations]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Liste des réservations
 *       401:
 *         description: Non authentifié
 */
router.get('/', authenticateToken, reservationController.getReservations);

/**
 * @swagger
 * /api/reservations/{id}:
 *   delete:
 *     summary: Supprimer une réservation (client propriétaire uniquement)
 *     tags: [Réservations]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         schema:
 *           type: integer
 *         required: true
 *         description: ID de la réservation
 *     responses:
 *       200:
 *         description: Réservation supprimée
 *       401:
 *         description: Non authentifié
 *       403:
 *         description: Accès refusé
 *       404:
 *         description: Réservation non trouvée
 */
router.delete('/:id', authenticateToken, reservationController.deleteReservation);

module.exports = router;
