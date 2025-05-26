const Reservation = require('../models/Reservation');

// Créer une réservation
exports.createReservation = async (req, res) => {
  try {
    const { nom, telephone, nombreCouverts } = req.body;
    const reservation = new Reservation({ nom, telephone, nombreCouverts });
    await reservation.save();
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
      // Un serveur voit toutes les réservations
      reservations = await Reservation.find();
    } else {
      // Un client ne voit que ses propres réservations (par nom et téléphone)
      reservations = await Reservation.find({ nom: req.user.nom, telephone: req.user.telephone });
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
    // Vérification du droit : seul le client propriétaire peut supprimer
    if (
      req.user.role !== 'client' ||
      reservation.nom !== req.user.nom ||
      reservation.telephone !== req.user.telephone
    ) {
      return res.status(403).json({ error: 'Accès refusé' });
    }
    await Reservation.findByIdAndDelete(id);
    res.json({ message: 'Réservation supprimée' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
