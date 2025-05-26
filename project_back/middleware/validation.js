const Joi = require('joi');

// Schéma de validation pour l'inscription
const registerSchema = Joi.object({
  nom: Joi.string()
    .min(2)
    .max(100)
    .required()
    .messages({
      'string.empty': 'Le nom est requis',
      'string.min': 'Le nom doit contenir au moins 2 caractères',
      'string.max': 'Le nom ne peut pas dépasser 100 caractères'
    }),
  
  prenom: Joi.string()
    .min(2)
    .max(100)
    .required()
    .messages({
      'string.empty': 'Le prénom est requis',
      'string.min': 'Le prénom doit contenir au moins 2 caractères',
      'string.max': 'Le prénom ne peut pas dépasser 100 caractères'
    }),
  
  email: Joi.string()
    .email()
    .required()
    .messages({
      'string.empty': 'L\'email est requis',
      'string.email': 'L\'email doit être valide'
    }),
  
  password: Joi.string()
    .min(8)
    .pattern(new RegExp('^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]'))
    .required()
    .messages({
      'string.empty': 'Le mot de passe est requis',
      'string.min': 'Le mot de passe doit contenir au moins 8 caractères',
      'string.pattern.base': 'Le mot de passe doit contenir au moins une majuscule, une minuscule, un chiffre et un caractère spécial'
    }),
  
  role: Joi.string()
    .valid('client', 'serveur')
    .required()
    .messages({
      'any.only': 'Le rôle doit être "client" ou "serveur"',
      'string.empty': 'Le rôle est requis'
    })
});

// Schéma de validation pour la connexion
const loginSchema = Joi.object({
  email: Joi.string()
    .email()
    .required()
    .messages({
      'string.empty': 'L\'email est requis',
      'string.email': 'L\'email doit être valide'
    }),
  
  password: Joi.string()
    .required()
    .messages({
      'string.empty': 'Le mot de passe est requis'
    })
});

// Middleware de validation générique
const validate = (schema) => {
  return (req, res, next) => {
    const { error, value } = schema.validate(req.body, {
      abortEarly: false, // Retourner toutes les erreurs
      stripUnknown: true // Supprimer les champs non définis dans le schéma
    });

    if (error) {
      const errors = error.details.map(detail => ({
        field: detail.path.join('.'),
        message: detail.message
      }));

      return res.status(400).json({
        success: false,
        message: 'Données invalides',
        errors
      });
    }

    // Remplacer req.body par les données validées et nettoyées
    req.body = value;
    next();
  };
};

// Middlewares spécifiques
const validateRegister = validate(registerSchema);
const validateLogin = validate(loginSchema);

module.exports = {
  validateRegister,
  validateLogin,
  validate
}; 