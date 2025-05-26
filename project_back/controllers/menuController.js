const Menu = require('../models/Menu');

class MenuController {
  // Récupérer tous les plats du menu
  static async getMenu(req, res) {
    try {
      const plats = await Menu.findAll();

      res.status(200).json({
        success: true,
        message: 'Menu récupéré avec succès',
        data: {
          plats: plats.map(plat => plat.toJSON()),
          total: plats.length
        }
      });

    } catch (error) {
      console.error('Erreur lors de la récupération du menu:', error);
      
      res.status(500).json({
        success: false,
        message: 'Erreur interne du serveur lors de la récupération du menu'
      });
    }
  }

  // Récupérer les plats par catégorie
  static async getMenuByCategory(req, res) {
    try {
      const { categorie } = req.params;
      const plats = await Menu.findByCategory(categorie);

      res.status(200).json({
        success: true,
        message: `Plats de la catégorie "${categorie}" récupérés avec succès`,
        data: {
          plats: plats.map(plat => plat.toJSON()),
          categorie,
          total: plats.length
        }
      });

    } catch (error) {
      console.error('Erreur lors de la récupération des plats par catégorie:', error);
      
      res.status(500).json({
        success: false,
        message: 'Erreur interne du serveur lors de la récupération des plats'
      });
    }
  }

  // Récupérer un plat par ID
  static async getPlatById(req, res) {
    try {
      const { id } = req.params;
      const plat = await Menu.findById(id);

      if (!plat) {
        return res.status(404).json({
          success: false,
          message: 'Plat non trouvé'
        });
      }

      res.status(200).json({
        success: true,
        message: 'Plat récupéré avec succès',
        data: {
          plat: plat.toJSON()
        }
      });

    } catch (error) {
      console.error('Erreur lors de la récupération du plat:', error);
      
      res.status(500).json({
        success: false,
        message: 'Erreur interne du serveur lors de la récupération du plat'
      });
    }
  }

  // Créer un nouveau plat (pour l'administration)
  static async createPlat(req, res) {
    try {
      const { nom, description, prix, image_url, categorie, disponible } = req.body;

      const plat = await Menu.create({
        nom,
        description,
        prix,
        image_url,
        categorie,
        disponible
      });

      res.status(201).json({
        success: true,
        message: 'Plat créé avec succès',
        data: {
          plat: plat.toJSON()
        }
      });

    } catch (error) {
      console.error('Erreur lors de la création du plat:', error);

      // Gestion des erreurs de contrainte de base de données
      if (error.code === '23505') {
        return res.status(409).json({
          success: false,
          message: 'Un plat avec ce nom existe déjà'
        });
      }

      res.status(500).json({
        success: false,
        message: 'Erreur interne du serveur lors de la création du plat'
      });
    }
  }

  // Mettre à jour la disponibilité d'un plat (pour l'administration)
  static async updatePlatAvailability(req, res) {
    try {
      const { id } = req.params;
      const { disponible } = req.body;

      const plat = await Menu.updateAvailability(id, disponible);

      if (!plat) {
        return res.status(404).json({
          success: false,
          message: 'Plat non trouvé'
        });
      }

      res.status(200).json({
        success: true,
        message: 'Disponibilité du plat mise à jour avec succès',
        data: {
          plat: plat.toJSON()
        }
      });

    } catch (error) {
      console.error('Erreur lors de la mise à jour de la disponibilité:', error);
      
      res.status(500).json({
        success: false,
        message: 'Erreur interne du serveur lors de la mise à jour'
      });
    }
  }

  // Récupérer tous les plats pour l'administration (y compris non disponibles)
  static async getMenuAdmin(req, res) {
    try {
      const plats = await Menu.findAllAdmin();

      res.status(200).json({
        success: true,
        message: 'Menu complet récupéré avec succès',
        data: {
          plats: plats.map(plat => plat.toJSON()),
          total: plats.length
        }
      });

    } catch (error) {
      console.error('Erreur lors de la récupération du menu complet:', error);
      
      res.status(500).json({
        success: false,
        message: 'Erreur interne du serveur lors de la récupération du menu'
      });
    }
  }
}

module.exports = MenuController; 