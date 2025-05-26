const User = require('../models/User');
const { generateToken } = require('../middleware/auth');

class AuthController {
  // Inscription d'un nouvel utilisateur
  static async register(req, res) {
    try {
      const { nom, prenom, email, password, telephone, role } = req.body;

      // Créer l'utilisateur
      const user = await User.create({
        nom,
        prenom,
        email,
        password,
        telephone,
        role: role || 'client'
      });

      // Générer le token JWT
      const token = generateToken(user.id);

      // Réponse de succès
      res.status(201).json({
        success: true,
        message: 'Utilisateur créé avec succès',
        data: {
          user: user.toJSON(),
          token
        }
      });

    } catch (error) {
      console.error('Erreur lors de l\'inscription:', error);

      // Gestion des erreurs spécifiques
      if (error.message === 'Un utilisateur avec cet email existe déjà') {
        return res.status(409).json({
          success: false,
          message: error.message
        });
      }

      // Erreur de contrainte de base de données
      if (error.code === '23505') { // Code PostgreSQL pour violation de contrainte unique
        return res.status(409).json({
          success: false,
          message: 'Un utilisateur avec cet email existe déjà'
        });
      }

      res.status(500).json({
        success: false,
        message: 'Erreur interne du serveur lors de l\'inscription'
      });
    }
  }

  // Connexion d'un utilisateur
  static async login(req, res) {
    try {
      const { email, password } = req.body;

      // Rechercher l'utilisateur par email
      const user = await User.findByEmail(email);
      if (!user) {
        return res.status(401).json({
          success: false,
          message: 'Email ou mot de passe incorrect'
        });
      }

      // Vérifier le mot de passe
      const isPasswordValid = await user.verifyPassword(password);
      if (!isPasswordValid) {
        return res.status(401).json({
          success: false,
          message: 'Email ou mot de passe incorrect'
        });
      }

      // Générer le token JWT
      const token = generateToken(user.id);

      // Réponse de succès
      res.status(200).json({
        success: true,
        message: 'Connexion réussie',
        data: {
          user: user.toJSON(),
          token
        }
      });

    } catch (error) {
      console.error('Erreur lors de la connexion:', error);
      
      res.status(500).json({
        success: false,
        message: 'Erreur interne du serveur lors de la connexion'
      });
    }
  }

  // Obtenir le profil de l'utilisateur connecté
  static async getProfile(req, res) {
    try {
      // L'utilisateur est déjà disponible via le middleware d'authentification
      res.status(200).json({
        success: true,
        message: 'Profil récupéré avec succès',
        data: {
          user: req.user.toJSON()
        }
      });
    } catch (error) {
      console.error('Erreur lors de la récupération du profil:', error);
      
      res.status(500).json({
        success: false,
        message: 'Erreur interne du serveur'
      });
    }
  }

  // Vérifier la validité du token
  static async verifyToken(req, res) {
    try {
      // Si on arrive ici, c'est que le token est valide (middleware d'auth)
      res.status(200).json({
        success: true,
        message: 'Token valide',
        data: {
          user: req.user.toJSON()
        }
      });
    } catch (error) {
      console.error('Erreur lors de la vérification du token:', error);
      
      res.status(500).json({
        success: false,
        message: 'Erreur interne du serveur'
      });
    }
  }
}

module.exports = AuthController; 