const express = require('express');

// Initialisation de l'application Express
const app = express();
const port = 3000;

// Middleware de base
app.use(express.json());

// Route de test simple
app.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'Serveur minimal fonctionnel',
    timestamp: new Date().toISOString()
  });
});

app.get('/test', (req, res) => {
  res.json({
    success: true,
    message: 'Test endpoint',
    express: 'v5.x',
    node: process.version
  });
});

// Démarrage du serveur
app.listen(port, () => {
  console.log(`🚀 Serveur minimal démarré sur http://localhost:${port}`);
});

module.exports = app; 