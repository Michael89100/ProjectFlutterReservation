const rateLimit = require('express-rate-limit');
const helmet = require('helmet');

// Limitation de taux pour les endpoints d'authentification
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // Maximum 5 tentatives par IP
  message: {
    success: false,
    message: 'Trop de tentatives de connexion. Réessayez dans 15 minutes.',
    retryAfter: 15 * 60 // en secondes
  },
  standardHeaders: true,
  legacyHeaders: false,
  // Personnaliser la clé pour inclure l'email si disponible
  keyGenerator: (req) => {
    return req.body?.email || req.ip;
  },
  // Ignorer les requêtes réussies pour le compteur
  skipSuccessfulRequests: true,
  // Handler pour les limites atteintes (nouvelle syntaxe v7)
  handler: (req, res) => {
    console.warn(`Limite de taux atteinte pour ${req.ip} - ${req.body?.email || 'email non fourni'}`);
    res.status(429).json({
      success: false,
      message: 'Trop de tentatives de connexion. Réessayez dans 15 minutes.',
      retryAfter: 15 * 60
    });
  }
});

// Limitation de taux générale pour l'API
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Maximum 100 requêtes par IP
  message: {
    success: false,
    message: 'Trop de requêtes. Réessayez plus tard.',
    retryAfter: 15 * 60
  },
  standardHeaders: true,
  legacyHeaders: false
});

// Configuration Helmet simplifiée pour éviter les conflits
const helmetConfig = helmet({
  contentSecurityPolicy: false, // Désactivé temporairement pour Swagger
  crossOriginEmbedderPolicy: false
});

// Middleware pour logger les tentatives de connexion suspectes
const logSuspiciousActivity = (req, res, next) => {
  const suspiciousPatterns = [
    /admin/i,
    /root/i,
    /test/i,
    /\.php$/,
    /\.asp$/,
    /\.jsp$/,
    /\.\./,
    /<script/i,
    /union.*select/i,
    /drop.*table/i
  ];

  const userAgent = req.get('User-Agent') || '';
  const url = req.originalUrl;
  const body = JSON.stringify(req.body);

  const isSuspicious = suspiciousPatterns.some(pattern => 
    pattern.test(url) || pattern.test(body) || pattern.test(userAgent)
  );

  if (isSuspicious) {
    console.warn(`🚨 Activité suspecte détectée:`, {
      ip: req.ip,
      userAgent,
      url,
      body: req.body,
      timestamp: new Date().toISOString()
    });
  }

  next();
};

// Middleware pour nettoyer les données d'entrée
const sanitizeInput = (req, res, next) => {
  if (req.body) {
    // Supprimer les espaces en début et fin pour les chaînes
    Object.keys(req.body).forEach(key => {
      if (typeof req.body[key] === 'string') {
        req.body[key] = req.body[key].trim();
      }
    });
  }
  next();
};

module.exports = {
  authLimiter,
  apiLimiter,
  helmetConfig,
  logSuspiciousActivity,
  sanitizeInput
}; 