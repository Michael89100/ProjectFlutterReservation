const pool = require('../config/database');

class Menu {
  constructor(data) {
    this.id = data.id;
    this.nom = data.nom;
    this.description = data.description;
    this.prix = data.prix;
    this.image_url = data.image_url;
    this.categorie = data.categorie;
    this.disponible = data.disponible;
    this.created_at = data.created_at;
    this.updated_at = data.updated_at;
  }

  // Créer un nouveau plat
  static async create(platData) {
    const { nom, description, prix, image_url, categorie, disponible = true } = platData;
    
    try {
      const query = `
        INSERT INTO menu (nom, description, prix, image_url, categorie, disponible)
        VALUES ($1, $2, $3, $4, $5, $6)
        RETURNING *
      `;
      
      const values = [nom, description, prix, image_url, categorie, disponible];
      const result = await pool.query(query, values);
      
      return new Menu(result.rows[0]);
    } catch (error) {
      console.error('Erreur lors de la création du plat:', error);
      throw error;
    }
  }

  // Récupérer tous les plats du menu
  static async findAll() {
    try {
      const query = `
        SELECT * FROM menu 
        WHERE disponible = true 
        ORDER BY categorie, nom
      `;
      const result = await pool.query(query);
      
      return result.rows.map(row => new Menu(row));
    } catch (error) {
      console.error('Erreur lors de la récupération du menu:', error);
      throw error;
    }
  }

  // Récupérer tous les plats (y compris non disponibles) pour l'administration
  static async findAllAdmin() {
    try {
      const query = `
        SELECT * FROM menu 
        ORDER BY categorie, nom
      `;
      const result = await pool.query(query);
      
      return result.rows.map(row => new Menu(row));
    } catch (error) {
      console.error('Erreur lors de la récupération du menu complet:', error);
      throw error;
    }
  }

  // Récupérer un plat par ID
  static async findById(id) {
    try {
      const query = 'SELECT * FROM menu WHERE id = $1';
      const result = await pool.query(query, [id]);
      
      if (result.rows.length === 0) {
        return null;
      }
      
      return new Menu(result.rows[0]);
    } catch (error) {
      console.error('Erreur lors de la recherche du plat par ID:', error);
      throw error;
    }
  }

  // Récupérer les plats par catégorie
  static async findByCategory(categorie) {
    try {
      const query = `
        SELECT * FROM menu 
        WHERE categorie = $1 AND disponible = true 
        ORDER BY nom
      `;
      const result = await pool.query(query, [categorie]);
      
      return result.rows.map(row => new Menu(row));
    } catch (error) {
      console.error('Erreur lors de la recherche par catégorie:', error);
      throw error;
    }
  }

  // Mettre à jour la disponibilité d'un plat
  static async updateAvailability(id, disponible) {
    try {
      const query = `
        UPDATE menu 
        SET disponible = $1, updated_at = CURRENT_TIMESTAMP 
        WHERE id = $2 
        RETURNING *
      `;
      const result = await pool.query(query, [disponible, id]);
      
      if (result.rows.length === 0) {
        return null;
      }
      
      return new Menu(result.rows[0]);
    } catch (error) {
      console.error('Erreur lors de la mise à jour de la disponibilité:', error);
      throw error;
    }
  }

  // Retourner les données du plat formatées
  toJSON() {
    return {
      id: this.id,
      nom: this.nom,
      description: this.description,
      prix: parseFloat(this.prix),
      image_url: this.image_url,
      categorie: this.categorie,
      disponible: this.disponible,
      created_at: this.created_at,
      updated_at: this.updated_at
    };
  }
}

module.exports = Menu; 