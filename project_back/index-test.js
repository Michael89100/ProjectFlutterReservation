const express = require('express');
const cors = require('cors');
require('dotenv').config({ path: './config.env' });

// Import des middlewares de sécurité (sans helmet pour simplifier)
const { apiLimiter, sanitizeInput } = require('./middleware/security');

// Import des routes
const authRoutes = require('./routes/auth');

// Initialisation de l'application Express
const app = express();
const port = process.env.PORT || 3000;

// Trust proxy pour obtenir la vraie IP derrière un reverse proxy
app.set('trust proxy', 1);

// Configuration CORS
const corsOptions = {
  origin: process.env.CORS_ORIGIN || 'http://localhost:3000',
  credentials: true,
  optionsSuccessStatus: 200,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With']
};
app.use(cors(corsOptions));

// Middlewares pour parser le JSON et nettoyer les données
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));
app.use(sanitizeInput);

// Limitation de taux globale
app.use('/api', apiLimiter);

// Routes principales
app.use('/api/auth', authRoutes);

// Route de base
app.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'API de Réservation - Serveur en fonctionnement (version test)',
    version: '1.0.0',
    endpoints: {
      auth: '/api/auth',
      register: '/api/auth/register',
      login: '/api/auth/login',
      profile: '/api/auth/profile',
      verify: '/api/auth/verify'
    },
    note: 'Version de test sans Swagger - PostgreSQL requis pour les endpoints auth'
  });
});

// Route de santé pour le monitoring
app.get('/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Serveur en bonne santé',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'development'
  });
});

// Route de test simple (sans base de données)
app.get('/test', (req, res) => {
  res.json({
    success: true,
    message: 'Test endpoint fonctionnel',
    timestamp: new Date().toISOString(),
    server: 'Express 5.x',
    node: process.version
  });
});

// Middleware pour gérer les routes non trouvées
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route non trouvée',
    path: req.originalUrl,
    method: req.method,
    availableRoutes: [
      'GET /',
      'GET /health',
      'GET /test',
      'POST /api/auth/register',
      'POST /api/auth/login',
      'GET /api/auth/profile',
      'GET /api/auth/verify'
    ]
  });
});

// Middleware de gestion d'erreurs globales
app.use((error, req, res, next) => {
  console.error('❌ Erreur non gérée:', {
    error: error.message,
    stack: error.stack,
    url: req.originalUrl,
    method: req.method,
    ip: req.ip,
    timestamp: new Date().toISOString()
  });

  // Ne pas exposer les détails de l'erreur en production
  const isDevelopment = process.env.NODE_ENV === 'development';
  
  res.status(error.status || 500).json({
    success: false,
    message: isDevelopment ? error.message : 'Erreur interne du serveur',
    ...(isDevelopment && { stack: error.stack })
  });
});

// Démarrage du serveur
app.listen(port, () => {
  console.log(`🚀 Serveur de test démarré sur http://localhost:${port}`);
  console.log(`🏥 Endpoint de santé: http://localhost:${port}/health`);
  console.log(`🧪 Endpoint de test: http://localhost:${port}/test`);
  console.log(`🌍 Environnement: ${process.env.NODE_ENV || 'development'}`);
  console.log(`⚠️  Version sans Swagger - PostgreSQL requis pour l'authentification`);
});

module.exports = app; 