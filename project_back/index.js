const express = require('express');
const cors = require('cors');
require('dotenv').config({ path: './.env' });

// Import des middlewares de sécurité
const { 
  apiLimiter, 
  helmetConfig, 
  logSuspiciousActivity, 
  sanitizeInput 
} = require('./middleware/security');

// Import de la configuration Swagger
const { specs, swaggerUi, swaggerOptions } = require('./config/swagger');

// Import des routes
const authRoutes = require('./routes/auth');

// Initialisation de l'application Express
const app = express();
const port = process.env.PORT || 3000;

// Trust proxy pour obtenir la vraie IP derrière un reverse proxy
app.set('trust proxy', 1);

// Middlewares de sécurité
app.use(helmetConfig);
app.use(logSuspiciousActivity);

// Configuration CORS
const corsOptions = {
  origin: function (origin, callback) {
    console.log(`🔍 Requête CORS depuis: ${origin || 'sans origine'}`);
    
    // Autoriser les requêtes sans origine (ex: applications mobiles, Postman)
    if (!origin) {
      console.log('✅ Requête sans origine autorisée');
      return callback(null, true);
    }
    
    // En développement, autoriser tous les localhost
    if (process.env.NODE_ENV === 'development' || !process.env.NODE_ENV) {
      if (origin.includes('localhost') || origin.includes('127.0.0.1')) {
        console.log(`✅ Origine localhost autorisée: ${origin}`);
        return callback(null, true);
      }
    }
    
    console.warn(`❌ Origine CORS refusée: ${origin}`);
    callback(null, false);
  },
  credentials: true,
  optionsSuccessStatus: 200,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS', 'PATCH'],
  allowedHeaders: [
    'Content-Type', 
    'Authorization', 
    'X-Requested-With',
    'Accept',
    'Origin',
    'Access-Control-Request-Method',
    'Access-Control-Request-Headers'
  ],
  exposedHeaders: ['Authorization']
};
app.use(cors(corsOptions));

// Middleware pour gérer les requêtes preflight OPTIONS
app.options('*', cors(corsOptions));

// Middlewares pour parser le JSON et nettoyer les données
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));
app.use(sanitizeInput);

// Limitation de taux globale
app.use('/api', apiLimiter);

// Documentation Swagger
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(specs, swaggerOptions));

// Routes principales
app.use('/api/auth', authRoutes);

// Route de base
app.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'API de Réservation - Serveur en fonctionnement',
    version: '1.0.0',
    documentation: '/api-docs',
    endpoints: {
      auth: '/api/auth',
      swagger: '/api-docs'
    }
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

// Middleware pour gérer les routes non trouvées
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route non trouvée',
    path: req.originalUrl,
    method: req.method,
    suggestion: 'Consultez la documentation à /api-docs'
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

// Gestion des erreurs non capturées
process.on('uncaughtException', (error) => {
  console.error('❌ Exception non capturée:', error);
  process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('❌ Promesse rejetée non gérée:', reason);
  process.exit(1);
});

// Démarrage du serveur
app.listen(port, () => {
  console.log(`🚀 Serveur démarré sur http://localhost:${port}`);
  console.log(`📚 Documentation Swagger: http://localhost:${port}/api-docs`);
  console.log(`🏥 Endpoint de santé: http://localhost:${port}/health`);
  console.log(`🌍 Environnement: ${process.env.NODE_ENV || 'development'}`);
  console.log(`🗄️ Base de données: ${process.env.DB_USER}@${process.env.DB_HOST}:${process.env.DB_PORT}/${process.env.DB_NAME}`);
});

module.exports = app;
