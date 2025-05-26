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
// Route POST /api/reservations :
// - Si user connecté (token présent), authentification requise
// - Si user non connecté (création de compte), pas d'authentification requise
router.post('/', (req, res, next) => {
  // Si le body contient un user complet, on ne vérifie pas le token
  if (req.body.user && req.body.user.email) {
    return reservationController.createReservation(req, res);
  } else {
    // Sinon, authentification requise
    authenticateToken(req, res, () => reservationController.createReservation(req, res));
  }
});

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

/**
 * @swagger
 * /api/reservations/{id}:
 *   patch:
 *     summary: Modifier une réservation
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
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               horaire:
 *                 type: string
 *                 description: Nouvel horaire (client)
 *               nombreCouverts:
 *                 type: integer
 *                 description: Nouveau nombre de couverts (client)
 *               status:
 *                 type: string
 *                 enum: [en attente, acceptée, refusée]
 *                 description: Nouveau statut (serveur)
 *     responses:
 *       200:
 *         description: Réservation modifiée
 *       400:
 *         description: Erreur de validation
 *       401:
 *         description: Non authentifié
 *       403:
 *         description: Accès refusé
 *       404:
 *         description: Réservation non trouvée
 */
router.patch('/:id', authenticateToken, reservationController.updateReservation);

/**
 * @swagger
 * /api/reservations/available-slots:
 *   get:
 *     summary: Obtenir les créneaux horaires disponibles pour une date donnée
 *     tags: [Réservations]
 *     parameters:
 *       - in: query
 *         name: date
 *         schema:
 *           type: string
 *           format: date
 *         required: true
 *         description: Date au format YYYY-MM-DD
 *     responses:
 *       200:
 *         description: Liste des créneaux disponibles
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 slots:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       heure:
 *                         type: string
 *                         example: "12:00"
 *                       places_disponibles:
 *                         type: integer
 *                         example: 8
 *       400:
 *         description: Date manquante ou invalide
 */
router.get('/available-slots', reservationController.getAvailableSlots);

module.exports = router;
