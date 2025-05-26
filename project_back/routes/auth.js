const express = require('express');
const router = express.Router();
const AuthController = require('../controllers/authController');
const { validateRegister, validateLogin } = require('../middleware/validation');
const { authenticateToken } = require('../middleware/auth');

/**
 * @swagger
 * components:
 *   schemas:
 *     User:
 *       type: object
 *       properties:
 *         id:
 *           type: string
 *           format: uuid
 *           description: ID unique de l'utilisateur
 *         nom:
 *           type: string
 *           description: Nom de famille de l'utilisateur
 *         prenom:
 *           type: string
 *           description: Prénom de l'utilisateur
 *         email:
 *           type: string
 *           format: email
 *           description: Adresse email de l'utilisateur
 *         telephone:
 *           type: string
 *           description: Numéro de téléphone de l'utilisateur
 *         role:
 *           type: string
 *           enum: [client, serveur]
 *           description: Rôle de l'utilisateur
 *         created_at:
 *           type: string
 *           format: date-time
 *           description: Date de création du compte
 *         updated_at:
 *           type: string
 *           format: date-time
 *           description: Date de dernière modification
 *     
 *     RegisterRequest:
 *       type: object
 *       required:
 *         - nom
 *         - prenom
 *         - email
 *         - password
 *         - telephone
 *         - role
 *       properties:
 *         nom:
 *           type: string
 *           minLength: 2
 *           maxLength: 100
 *           description: Nom de famille
 *         prenom:
 *           type: string
 *           minLength: 2
 *           maxLength: 100
 *           description: Prénom
 *         email:
 *           type: string
 *           format: email
 *           description: Adresse email
 *         telephone:
 *           type: string
 *           description: Numéro de téléphone
 *         password:
 *           type: string
 *           minLength: 8
 *           pattern: '^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]'
 *           description: Mot de passe (min 8 caractères, 1 majuscule, 1 minuscule, 1 chiffre, 1 caractère spécial)
 *         role:
 *           type: string
 *           enum: [client, serveur]
 *           description: Rôle de l'utilisateur
 *     
 *     LoginRequest:
 *       type: object
 *       required:
 *         - email
 *         - password
 *       properties:
 *         email:
 *           type: string
 *           format: email
 *           description: Adresse email
 *         password:
 *           type: string
 *           description: Mot de passe
 *     
 *     AuthResponse:
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
 *             user:
 *               $ref: '#/components/schemas/User'
 *             token:
 *               type: string
 *               description: Token JWT
 *     
 *     ErrorResponse:
 *       type: object
 *       properties:
 *         success:
 *           type: boolean
 *           example: false
 *         message:
 *           type: string
 *           description: Message d'erreur
 *         errors:
 *           type: array
 *           items:
 *             type: object
 *             properties:
 *               field:
 *                 type: string
 *               message:
 *                 type: string
 *   
 *   securitySchemes:
 *     bearerAuth:
 *       type: http
 *       scheme: bearer
 *       bearerFormat: JWT
 */

/**
 * @swagger
 * /api/auth/register:
 *   post:
 *     summary: Inscription d'un nouvel utilisateur
 *     tags: [Authentification]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/RegisterRequest'
 *           example:
 *             nom: "Dupont"
 *             prenom: "Jean"
 *             email: "jean.dupont@example.com"
 *             telephone: "06 06 06 06 06"
 *             password: "MonMotDePasse123!"
 *             role: "client"
 *     responses:
 *       201:
 *         description: Utilisateur créé avec succès
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/AuthResponse'
 *       400:
 *         description: Données invalides
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 *       409:
 *         description: Un utilisateur avec cet email existe déjà
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 *       500:
 *         description: Erreur interne du serveur
 */
router.post('/register', validateRegister, AuthController.register);

/**
 * @swagger
 * /api/auth/login:
 *   post:
 *     summary: Connexion d'un utilisateur
 *     tags: [Authentification]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/LoginRequest'
 *           example:
 *             email: "jean.dupont@example.com"
 *             password: "MonMotDePasse123!"
 *     responses:
 *       200:
 *         description: Connexion réussie
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/AuthResponse'
 *       400:
 *         description: Données invalides
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 *       401:
 *         description: Email ou mot de passe incorrect
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 *       500:
 *         description: Erreur interne du serveur
 */
router.post('/login', validateLogin, AuthController.login);

/**
 * @swagger
 * /api/auth/profile:
 *   get:
 *     summary: Obtenir le profil de l'utilisateur connecté
 *     tags: [Authentification]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Profil récupéré avec succès
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 message:
 *                   type: string
 *                   example: "Profil récupéré avec succès"
 *                 data:
 *                   type: object
 *                   properties:
 *                     user:
 *                       $ref: '#/components/schemas/User'
 *       401:
 *         description: Token manquant ou invalide
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 *       500:
 *         description: Erreur interne du serveur
 */
router.get('/profile', authenticateToken, AuthController.getProfile);

/**
 * @swagger
 * /api/auth/verify:
 *   get:
 *     summary: Vérifier la validité du token JWT
 *     tags: [Authentification]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Token valide
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 message:
 *                   type: string
 *                   example: "Token valide"
 *                 data:
 *                   type: object
 *                   properties:
 *                     user:
 *                       $ref: '#/components/schemas/User'
 *       401:
 *         description: Token manquant, invalide ou expiré
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 *       500:
 *         description: Erreur interne du serveur
 */
router.get('/verify', authenticateToken, AuthController.verifyToken);

module.exports = router; 