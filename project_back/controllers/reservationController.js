const Reservation = require('../models/Reservation');
const User = require('../models/User');

// Créer une réservation
exports.createReservation = async (req, res) => {
  try {
    let userId;
    let user;
    // Si on reçoit un objet user complet, on crée le compte
    if (req.body.user && req.body.user.email) {
      // Si toutes les infos user sont envoyées, on ne vérifie pas le token
      const { nom, prenom, email, telephone, password, role } = req.body.user;
      user = await User.create({ nom, prenom, email, telephone, password, role: role || 'client' });
      userId = user.id;
    } else if (req.body.userId) {
      // Si userId fourni, on attend un token (authentifié)
      if (!req.user || req.user.id !== req.body.userId) {
        return res.status(401).json({ error: 'Token invalide ou manquant pour ce client' });
      }
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
      if (!['en attente', 'acceptée', 'refusée'].includes(status)) {
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

// GET /api/reservations/available-slots
exports.getAvailableSlots = async (req, res) => {
  try {
    const { date } = req.query;
    if (!date) {
      return res.status(400).json({ error: 'Date requise (YYYY-MM-DD)' });
    }
    // Créneaux : 11h00 à 13h30 et 18h00 à 21h30, toutes les 30 min
    const slots = [];
    const addSlots = (startHour, endHour) => {
      for (let h = startHour; h <= endHour; h++) {
        for (let m = 0; m < 60; m += 30) {
          const hourStr = h.toString().padStart(2, '0');
          const minStr = m.toString().padStart(2, '0');
          slots.push(`${hourStr}:${minStr}`);
        }
      }
    };
    addSlots(11, 13); // 11:00 à 13:30
    slots.push('13:30');
    addSlots(18, 21); // 18:00 à 21:30
    slots.push('21:30');

    // Récupérer toutes les réservations du jour
    const reservationsQuery = `SELECT horaire, nombre_couverts FROM reservations WHERE horaire::date = $1`;
    const reservationsResult = await require('../config/database').query(reservationsQuery, [date]);
    // Pour chaque créneau, calculer le nombre de places restantes
    const slotPlaces = {};
    slots.forEach(slot => slotPlaces[slot] = 20);
    for (const row of reservationsResult.rows) {
      const resTime = new Date(row.horaire);
      const resHour = resTime.getHours();
      const resMin = resTime.getMinutes();
      // Créneau de la réservation (ex: 12:00)
      const resSlot = `${resHour.toString().padStart(2, '0')}:${resMin.toString().padStart(2, '0')}`;
      // Bloquer le créneau de la réservation et le suivant (1h)
      const slotIdx = slots.indexOf(resSlot);
      for (let i = slotIdx; i <= slotIdx + 1 && i < slots.length; i++) {
        if (i >= 0) slotPlaces[slots[i]] -= row.nombre_couverts;
      }
    }
    // Retourner les créneaux avec places dispo > 0
    const available = slots.map(slot => ({
      heure: slot,
      places_disponibles: slotPlaces[slot] > 0 ? slotPlaces[slot] : 0
    }));
    res.json({ slots: available });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
