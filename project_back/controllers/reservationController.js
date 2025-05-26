const Reservation = require('../models/Reservation');

// Créer une réservation
exports.createReservation = async (req, res) => {
  try {
    const { nom, telephone, nombreCouverts } = req.body;
    const reservation = await Reservation.create({
      nom,
      telephone,
      nombreCouverts,
      userId: req.user.id
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
