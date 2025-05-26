const pool = require('../config/database');

class Reservation {
  constructor(data) {
    this.id = data.id;
    this.horaire = data.horaire;
    this.nombreCouverts = data.nombre_couverts;
    this.user_id = data.user_id;
    this.status = data.status;
    this.date = data.date;
  }

  static async create({ horaire, nombreCouverts, userId, status = 'en attente' }) {
    const query = `
      INSERT INTO reservations (horaire, nombre_couverts, user_id, status)
      VALUES ($1, $2, $3, $4)
      RETURNING id, horaire, nombre_couverts, user_id, status, date
    `;
    const values = [horaire, nombreCouverts, userId, status];
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

  static async updateFields(id, fields) {
    const allowed = ['horaire', 'nombre_couverts', 'status'];
    const set = [];
    const values = [];
    let idx = 1;
    for (const key in fields) {
      if (fields[key] !== undefined && allowed.includes(key === 'nombreCouverts' ? 'nombre_couverts' : key)) {
        set.push(`${key === 'nombreCouverts' ? 'nombre_couverts' : key} = $${idx}`);
        values.push(fields[key]);
        idx++;
      }
    }
    if (set.length === 0) return;
    const query = `UPDATE reservations SET ${set.join(', ')} WHERE id = $${idx}`;
    values.push(id);
    await pool.query(query, values);
  }
}

module.exports = Reservation;
