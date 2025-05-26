const Reservation = require('../models/Reservation');
const User = require('../models/User');

// Créer une réservation
exports.createReservation = async (req, res) => {
  try {
    let userId;
    let user;
    // Si on reçoit un objet user complet, on crée le compte
    if (req.body.user && req.body.user.email) {
      const { nom, prenom, email, telephone, password, role } = req.body.user;
      user = await User.create({ nom, prenom, email, telephone, password, role: role || 'client' });
      userId = user.id;
    } else if (req.body.userId) {
      userId = req.body.userId;
    } else if (req.user && req.user.id) {
      userId = req.user.id;
    } else {
      return res.status(400).json({ error: 'Aucun utilisateur fourni' });
    }
    const { horaire, nombreCouverts } = req.body;
    const reservation = await Reservation.create({
      horaire,
      nombreCouverts,
      userId
    });
    res.status(201).json(reservation);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// Obtenir les réservations (filtrage par rôle)
exports.getReservations = async (req, res) => {
  try {
    let reservations;
    if (req.user.role === 'serveur') {
      reservations = await Reservation.findAll();
    } else {
      reservations = await Reservation.findByUser(req.user.id);
    }
    res.json(reservations);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Supprimer une réservation (seul le client propriétaire peut supprimer)
exports.deleteReservation = async (req, res) => {
  try {
    const { id } = req.params;
    const reservation = await Reservation.findById(id);
    if (!reservation) {
      return res.status(404).json({ error: 'Réservation non trouvée' });
    }
    if (
      req.user.role !== 'client' ||
      reservation.user_id !== req.user.id
    ) {
      return res.status(403).json({ error: 'Accès refusé' });
    }
    await Reservation.deleteById(id);
    res.json({ message: 'Réservation supprimée' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Modifier une réservation
exports.updateReservation = async (req, res) => {
  try {
    const { id } = req.params;
    const reservation = await Reservation.findById(id);
    if (!reservation) {
      return res.status(404).json({ error: 'Réservation non trouvée' });
    }
    // Si client : peut modifier horaire/nombreCouverts uniquement sa propre réservation
    if (req.user.role === 'client') {
      if (reservation.user_id !== req.user.id) {
        return res.status(403).json({ error: 'Accès refusé' });
      }
      const { horaire, nombreCouverts } = req.body;
      await Reservation.updateFields(id, { horaire, nombreCouverts });
      const updated = await Reservation.findById(id);
      return res.json(updated);
    }
    // Si serveur : peut modifier le status
    if (req.user.role === 'serveur') {
      const { status } = req.body;
      if (!['en attente', 'acceptée', 'refusée', 'acceptee', 'refusee'].includes(status)) {
        return res.status(400).json({ error: 'Status invalide' });
      }
      await Reservation.updateFields(id, { status });
      const updated = await Reservation.findById(id);
      return res.json(updated);
    }
    return res.status(403).json({ error: 'Accès refusé' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
