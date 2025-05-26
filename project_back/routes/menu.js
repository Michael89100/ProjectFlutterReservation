const express = require('express');
const router = express.Router();
const MenuController = require('../controllers/menuController');
const { authenticateToken } = require('../middleware/auth');

/**
 * @swagger
 * components:
 *   schemas:
 *     Plat:
 *       type: object
 *       properties:
 *         id:
 *           type: string
 *           format: uuid
 *           description: ID unique du plat
 *         nom:
 *           type: string
 *           description: Nom du plat
 *         description:
 *           type: string
 *           description: Description du plat
 *         prix:
 *           type: number
 *           format: float
 *           description: Prix du plat en euros
 *         image_url:
 *           type: string
 *           format: uri
 *           description: URL de l'image du plat
 *         categorie:
 *           type: string
 *           enum: [entree, plat_principal, dessert, boisson]
 *           description: Catégorie du plat
 *         disponible:
 *           type: boolean
 *           description: Disponibilité du plat
 *         created_at:
 *           type: string
 *           format: date-time
 *           description: Date de création
 *         updated_at:
 *           type: string
 *           format: date-time
 *           description: Date de dernière modification
 *     
 *     CreatePlatRequest:
 *       type: object
 *       required:
 *         - nom
 *         - description
 *         - prix
 *         - image_url
 *         - categorie
 *       properties:
 *         nom:
 *           type: string
 *           minLength: 2
 *           maxLength: 100
 *           description: Nom du plat
 *         description:
 *           type: string
 *           minLength: 10
 *           maxLength: 500
 *           description: Description du plat
 *         prix:
 *           type: number
 *           format: float
 *           minimum: 0
 *           description: Prix du plat en euros
 *         image_url:
 *           type: string
 *           format: uri
 *           description: URL de l'image du plat
 *         categorie:
 *           type: string
 *           enum: [entree, plat_principal, dessert, boisson]
 *           description: Catégorie du plat
 *         disponible:
 *           type: boolean
 *           default: true
 *           description: Disponibilité du plat
 *     
 *     MenuResponse:
 *       type: object
 *       properties:
 *         success:
 *           type: boolean
 *           description: Statut de la réponse
 *         message:
 *           type: string
 *           description: Message de réponse
 *         data:
 *           type: object
 *           properties:
 *             plats:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Plat'
 *             total:
 *               type: integer
 *               description: Nombre total de plats
 *     
 *     PlatResponse:
 *       type: object
 *       properties:
 *         success:
 *           type: boolean
 *           description: Statut de la réponse
 *         message:
 *           type: string
 *           description: Message de réponse
 *         data:
 *           type: object
 *           properties:
 *             plat:
 *               $ref: '#/components/schemas/Plat'
 */

/**
 * @swagger
 * /api/menu:
 *   get:
 *     summary: Récupérer tous les plats disponibles du menu
 *     tags: [Menu]
 *     responses:
 *       200:
 *         description: Menu récupéré avec succès
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/MenuResponse'
 *       500:
 *         description: Erreur interne du serveur
 */
router.get('/', MenuController.getMenu);

/**
 * @swagger
 * /api/menu/category/{categorie}:
 *   get:
 *     summary: Récupérer les plats par catégorie
 *     tags: [Menu]
 *     parameters:
 *       - in: path
 *         name: categorie
 *         required: true
 *         schema:
 *           type: string
 *           enum: [entree, plat_principal, dessert, boisson]
 *         description: Catégorie des plats à récupérer
 *     responses:
 *       200:
 *         description: Plats de la catégorie récupérés avec succès
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/MenuResponse'
 *       500:
 *         description: Erreur interne du serveur
 */
router.get('/category/:categorie', MenuController.getMenuByCategory);

/**
 * @swagger
 * /api/menu/{id}:
 *   get:
 *     summary: Récupérer un plat par son ID
 *     tags: [Menu]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *         description: ID du plat
 *     responses:
 *       200:
 *         description: Plat récupéré avec succès
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/PlatResponse'
 *       404:
 *         description: Plat non trouvé
 *       500:
 *         description: Erreur interne du serveur
 */
router.get('/:id', MenuController.getPlatById);

/**
 * @swagger
 * /api/menu/admin/all:
 *   get:
 *     summary: Récupérer tous les plats (y compris non disponibles) - Administration
 *     tags: [Menu - Administration]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Menu complet récupéré avec succès
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/MenuResponse'
 *       401:
 *         description: Token manquant ou invalide
 *       500:
 *         description: Erreur interne du serveur
 */
router.get('/admin/all', authenticateToken, MenuController.getMenuAdmin);

/**
 * @swagger
 * /api/menu:
 *   post:
 *     summary: Créer un nouveau plat - Administration
 *     tags: [Menu - Administration]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/CreatePlatRequest'
 *           example:
 *             nom: "Salade César"
 *             description: "Salade fraîche avec croûtons, parmesan et sauce César maison"
 *             prix: 12.50
 *             image_url: "https://images.pexels.com/photos/1059905/pexels-photo-1059905.jpeg"
 *             categorie: "entree"
 *             disponible: true
 *     responses:
 *       201:
 *         description: Plat créé avec succès
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/PlatResponse'
 *       400:
 *         description: Données invalides
 *       401:
 *         description: Token manquant ou invalide
 *       409:
 *         description: Un plat avec ce nom existe déjà
 *       500:
 *         description: Erreur interne du serveur
 */
router.post('/', authenticateToken, MenuController.createPlat);

/**
 * @swagger
 * /api/menu/{id}/availability:
 *   patch:
 *     summary: Mettre à jour la disponibilité d'un plat - Administration
 *     tags: [Menu - Administration]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *         description: ID du plat
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - disponible
 *             properties:
 *               disponible:
 *                 type: boolean
 *                 description: Nouvelle disponibilité du plat
 *           example:
 *             disponible: false
 *     responses:
 *       200:
 *         description: Disponibilité mise à jour avec succès
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/PlatResponse'
 *       400:
 *         description: Données invalides
 *       401:
 *         description: Token manquant ou invalide
 *       404:
 *         description: Plat non trouvé
 *       500:
 *         description: Erreur interne du serveur
 */
router.patch('/:id/availability', authenticateToken, MenuController.updatePlatAvailability);

module.exports = router; 