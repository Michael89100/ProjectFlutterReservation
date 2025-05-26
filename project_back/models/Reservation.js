const pool = require('../config/database');

class Reservation {
  constructor(data) {
    this.id = data.id;
    this.nom = data.nom;
    this.telephone = data.telephone;
    this.nombreCouverts = data.nombre_couverts;
    this.date = data.date;
    this.user_id = data.user_id;
  }

  static async create({ nom, telephone, nombreCouverts, userId }) {
    const query = `
      INSERT INTO reservations (nom, telephone, nombre_couverts, user_id)
      VALUES ($1, $2, $3, $4)
      RETURNING id, nom, telephone, nombre_couverts, date, user_id
    `;
    const values = [nom, telephone, nombreCouverts, userId];
    const result = await pool.query(query, values);
    return new Reservation(result.rows[0]);
  }

  static async findAll() {
    const query = 'SELECT * FROM reservations ORDER BY date DESC';
    const result = await pool.query(query);
    return result.rows.map(row => new Reservation(row));
  }

  static async findByUser(userId) {
    const query = 'SELECT * FROM reservations WHERE user_id = $1 ORDER BY date DESC';
    const result = await pool.query(query, [userId]);
    return result.rows.map(row => new Reservation(row));
  }

  static async findById(id) {
    const query = 'SELECT * FROM reservations WHERE id = $1';
    const result = await pool.query(query, [id]);
    if (result.rows.length === 0) return null;
    return new Reservation(result.rows[0]);
  }

  static async deleteById(id) {
    const query = 'DELETE FROM reservations WHERE id = $1';
    await pool.query(query, [id]);
  }
}

module.exports = Reservation;
