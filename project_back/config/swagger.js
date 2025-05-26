const swaggerJsdoc = require('swagger-jsdoc');
const swaggerUi = require('swagger-ui-express');
const path = require('path');

const options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'API de Réservation',
      version: '1.0.0',
      description: 'API REST pour l\'application de réservation avec authentification JWT',
      contact: {
        name: 'Équipe de développement',
        email: 'dev@reservation.com'
      },
      license: {
        name: 'MIT',
        url: 'https://opensource.org/licenses/MIT'
      }
    },
    servers: [
      {
        url: 'http://localhost:3000',
        description: 'Serveur de développement'
      }
    ],
    tags: [
      {
        name: 'Authentification',
        description: 'Endpoints pour l\'authentification des utilisateurs'
      },
      {
        name: 'Menu',
        description: 'Endpoints publics pour consulter le menu du restaurant'
      },
      {
        name: 'Menu - Administration',
        description: 'Endpoints d\'administration pour gérer le menu (authentification requise)'
      },
      {
        name: 'Réservations',
        description: 'Endpoints pour la gestion des réservations'
      }
    ]
  },
  apis: [
    path.join(__dirname, '../routes/auth.js'),
    path.join(__dirname, '../routes/menu.js'),
    path.join(__dirname, '../routes/reservation.js')
  ]
};

const specs = swaggerJsdoc(options);

// Configuration simplifiée de Swagger UI
const swaggerOptions = {
  explorer: true,
  swaggerOptions: {
    persistAuthorization: true,
    displayRequestDuration: true,
    docExpansion: 'none'
  },
  customSiteTitle: 'API de Réservation - Documentation'
};

module.exports = {
  specs,
  swaggerUi,
  swaggerOptions
};