const Joi = require('joi');

// Catégories valides pour le menu
const CATEGORIES_VALIDES = ['entree', 'plat_principal', 'dessert', 'boisson'];

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
  
  telephone: Joi.string()
    .pattern(/^(?:\+33\s?[1-9](?:[\s.-]?\d{2}){4}|0[1-9](?:[\s.-]?\d{2}){4})$/)
    .allow(null, '')
    .optional()
    .messages({
      'string.pattern.base': 'Le numéro de téléphone doit être un numéro français valide (ex: 06 12 34 56 78, 0612345678, +33 6 12 34 56 78)'
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

// Schéma de validation pour la création d'un plat
const createPlatSchema = Joi.object({
  nom: Joi.string()
    .min(2)
    .max(100)
    .required()
    .messages({
      'string.empty': 'Le nom du plat est requis',
      'string.min': 'Le nom doit contenir au moins 2 caractères',
      'string.max': 'Le nom ne peut pas dépasser 100 caractères'
    }),
  
  description: Joi.string()
    .min(10)
    .max(1000)
    .required()
    .messages({
      'string.empty': 'La description est requise',
      'string.min': 'La description doit contenir au moins 10 caractères',
      'string.max': 'La description ne peut pas dépasser 1000 caractères'
    }),
  
  prix: Joi.number()
    .positive()
    .precision(2)
    .required()
    .messages({
      'number.base': 'Le prix doit être un nombre',
      'number.positive': 'Le prix doit être positif',
      'any.required': 'Le prix est requis'
    }),
  
  image_url: Joi.string()
    .uri()
    .max(500)
    .required()
    .messages({
      'string.empty': 'L\'URL de l\'image est requise',
      'string.uri': 'L\'URL de l\'image doit être valide',
      'string.max': 'L\'URL ne peut pas dépasser 500 caractères'
    }),
  
  categorie: Joi.string()
    .valid(...CATEGORIES_VALIDES)
    .required()
    .messages({
      'any.only': `La catégorie doit être l'une des suivantes: ${CATEGORIES_VALIDES.join(', ')}`,
      'string.empty': 'La catégorie est requise'
    }),
  
  disponible: Joi.boolean()
    .default(true)
    .messages({
      'boolean.base': 'La disponibilité doit être un booléen'
    })
});

// Schéma de validation pour la mise à jour de la disponibilité
const updateAvailabilitySchema = Joi.object({
  disponible: Joi.boolean()
    .required()
    .messages({
      'boolean.base': 'La disponibilité doit être un booléen',
      'any.required': 'La disponibilité est requise'
    })
});

// Schéma de validation pour les paramètres de catégorie
const categoryParamSchema = Joi.object({
  categorie: Joi.string()
    .valid(...CATEGORIES_VALIDES)
    .required()
    .messages({
      'any.only': `La catégorie doit être l'une des suivantes: ${CATEGORIES_VALIDES.join(', ')}`,
      'string.empty': 'La catégorie est requise'
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

// Middleware de validation pour les paramètres d'URL
const validateParams = (schema) => {
  return (req, res, next) => {
    const { error, value } = schema.validate(req.params, {
      abortEarly: false,
      stripUnknown: true
    });

    if (error) {
      const errors = error.details.map(detail => ({
        field: detail.path.join('.'),
        message: detail.message
      }));

      return res.status(400).json({
        success: false,
        message: 'Paramètres invalides',
        errors
      });
    }

    req.params = value;
    next();
  };
};

// Middlewares spécifiques
const validateRegister = validate(registerSchema);
const validateLogin = validate(loginSchema);
const validateCreatePlat = validate(createPlatSchema);
const validateUpdateAvailability = validate(updateAvailabilitySchema);
const validateCategoryParam = validateParams(categoryParamSchema);

module.exports = {
  validateRegister,
  validateLogin,
  validateCreatePlat,
  validateUpdateAvailability,
  validateCategoryParam,
  validate,
  validateParams,
  CATEGORIES_VALIDES
}; 