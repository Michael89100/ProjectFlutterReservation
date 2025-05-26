const mongoose = require('mongoose');

const reservationSchema = new mongoose.Schema({
  nom: {
    type: String,
    required: true
  },
  telephone: {
    type: String,
    required: true
  },
  nombreCouverts: {
    type: Number,
    required: true
  },
  date: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('Reservation', reservationSchema);
