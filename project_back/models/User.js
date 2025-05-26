const pool = require('../config/database');
const bcrypt = require('bcryptjs');

class User {
  constructor(data) {
    this.id = data.id;
    this.nom = data.nom;
    this.prenom = data.prenom;
    this.telephone = data.telephone;
    this.email = data.email;
    this.password = data.password;
    this.role = data.role;
    this.created_at = data.created_at;
    this.updated_at = data.updated_at;
  }

  // Créer un nouvel utilisateur
  static async create(userData) {
    const { nom, prenom, email, password, role, telephone } = userData;
    
    try {
      // Vérifier si l'email existe déjà
      const existingUser = await this.findByEmail(email);
      if (existingUser) {
        throw new Error('Un utilisateur avec cet email existe déjà');
      }

      // Hasher le mot de passe
      const saltRounds = 12;
      const hashedPassword = await bcrypt.hash(password, saltRounds);

      const query = `
        INSERT INTO users (nom, prenom, email, password, role, telephone)
        VALUES ($1, $2, $3, $4, $5, $6)
        RETURNING id, nom, prenom, email, role, telephone, created_at, updated_at
      `;
      
      const values = [nom, prenom, email, hashedPassword, role, telephone];
      const result = await pool.query(query, values);
      
      return new User(result.rows[0]);
    } catch (error) {
      console.error('Erreur lors de la création de l\'utilisateur:', error);
      throw error;
    }
  }

  // Trouver un utilisateur par email
  static async findByEmail(email) {
    try {
      const query = 'SELECT * FROM users WHERE email = $1';
      const result = await pool.query(query, [email]);
      
      if (result.rows.length === 0) {
        return null;
      }
      
      return new User(result.rows[0]);
    } catch (error) {
      console.error('Erreur lors de la recherche par email:', error);
      throw error;
    }
  }

  // Trouver un utilisateur par ID
  static async findById(id) {
    try {
      const query = 'SELECT * FROM users WHERE id = $1';
      const result = await pool.query(query, [id]);
      
      if (result.rows.length === 0) {
        return null;
      }
      
      return new User(result.rows[0]);
    } catch (error) {
      console.error('Erreur lors de la recherche par ID:', error);
      throw error;
    }
  }

  // Vérifier le mot de passe
  async verifyPassword(password) {
    try {
      return await bcrypt.compare(password, this.password);
    } catch (error) {
      console.error('Erreur lors de la vérification du mot de passe:', error);
      throw error;
    }
  }

  // Retourner les données utilisateur sans le mot de passe
  toJSON() {
    const { password, ...userWithoutPassword } = this;
    return userWithoutPassword;
  }

  // Obtenir tous les utilisateurs (pour l'administration)
  static async findAll() {
    try {
      const query = 'SELECT id, nom, prenom, email, role, telephone, created_at, updated_at FROM users ORDER BY created_at DESC';
      const result = await pool.query(query);
      
      return result.rows.map(row => new User(row));
    } catch (error) {
      console.error('Erreur lors de la récupération des utilisateurs:', error);
      throw error;
    }
  }
}

module.exports = User; 