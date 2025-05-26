const Reservation = require('../models/Reservation');
const User = require('../models/User');
const { sendMail } = require('../config/mailer');

// Créer une réservation
exports.createReservation = async (req, res) => {
  try {
    let userId;
    let user;
    let createdUser = false;
    // Si on reçoit un objet user complet, on crée le compte
    if (req.body.user && req.body.user.email) {
      const { nom, prenom, email, telephone, password, role } = req.body.user;
      user = await User.create({ nom, prenom, email, telephone, password, role: role || 'client' });
      userId = user.id;
      createdUser = true;
    } else if (req.body.userId) {
      if (!req.user || req.user.id !== req.body.userId) {
        return res.status(401).json({ error: 'Token invalide ou manquant pour ce client' });
      }
      userId = req.body.userId;
      user = await User.findById(userId);
    } else if (req.user && req.user.id) {
      userId = req.user.id;
      user = await User.findById(userId);
    } else {
      return res.status(400).json({ error: 'Aucun utilisateur fourni' });
    }
    const { horaire, nombreCouverts } = req.body;
    const reservation = await Reservation.create({
      horaire,
      nombreCouverts,
      userId
    });
    // Envoi des emails
    try {
      const adminMail = 'kylian.deley@gmail.com';
      const clientMail = user.email;
      const subject = 'Nouvelle réservation - Le Petit Bistrot';
      const text = `Bonjour ${user.prenom || user.nom},\nVotre réservation pour ${nombreCouverts} couvert(s) le ${horaire} a bien été enregistrée.\nMerci et à bientôt !`;
      const html = `<p>Bonjour ${user.prenom || user.nom},<br>Votre réservation pour <b>${nombreCouverts} couvert(s)</b> le <b>${horaire}</b> a bien été enregistrée.<br>Merci et à bientôt !</p>`;
      // Mail client
      await sendMail({ to: clientMail, subject, text, html });
      // Mail admin
      await sendMail({ to: adminMail, subject: 'Nouvelle réservation reçue', text: `Nouvelle réservation de ${user.nom} ${user.prenom || ''} (${user.email}) pour ${nombreCouverts} couvert(s) le ${horaire}.`, html: `<b>Nouvelle réservation de ${user.nom} ${user.prenom || ''} (${user.email})</b><br>Pour ${nombreCouverts} couvert(s) le <b>${horaire}</b>.` });
    } catch (mailErr) {
      console.error('Erreur lors de l\'envoi du mail :', mailErr);
    }
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
    // Tous les créneaux sont disponibles à 20 places
    const available = slots.map(slot => ({
      heure: slot,
      places_disponibles: 20
    }));
    res.json({ slots: available });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
