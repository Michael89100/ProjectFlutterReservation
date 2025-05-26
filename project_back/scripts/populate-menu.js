const pool = require('../config/database');

// Données des plats avec images Pexels libres de droit
const platsData = [
  // ENTRÉES
  {
    nom: 'Salade César',
    description: 'Salade romaine fraîche, croûtons dorés, copeaux de parmesan et notre sauce César maison',
    prix: 12.50,
    image_url: 'https://images.pexels.com/photos/1059905/pexels-photo-1059905.jpeg?auto=compress&cs=tinysrgb&w=800',
    categorie: 'entree'
  },
  {
    nom: 'Bruschetta Italienne',
    description: 'Pain grillé garni de tomates fraîches, basilic, ail et huile d\'olive extra vierge',
    prix: 9.80,
    image_url: 'https://images.pexels.com/photos/1438672/pexels-photo-1438672.jpeg?auto=compress&cs=tinysrgb&w=800',
    categorie: 'entree'
  },
  {
    nom: 'Soupe à l\'Oignon Gratinée',
    description: 'Soupe traditionnelle française aux oignons caramélisés, gratinée au fromage',
    prix: 11.20,
    image_url: 'https://images.pexels.com/photos/539451/pexels-photo-539451.jpeg?auto=compress&cs=tinysrgb&w=800',
    categorie: 'entree'
  },

  // PLATS PRINCIPAUX
  {
    nom: 'Saumon Grillé aux Herbes',
    description: 'Filet de saumon grillé, légumes de saison et sauce à l\'aneth',
    prix: 24.90,
    image_url: 'https://images.pexels.com/photos/1516415/pexels-photo-1516415.jpeg?auto=compress&cs=tinysrgb&w=800',
    categorie: 'plat_principal'
  },
  {
    nom: 'Bœuf Bourguignon',
    description: 'Bœuf mijoté au vin rouge avec carottes, champignons et pommes de terre',
    prix: 22.50,
    image_url: 'https://images.pexels.com/photos/8477/food-dinner-beef-meat.jpg?auto=compress&cs=tinysrgb&w=800',
    categorie: 'plat_principal'
  },
  {
    nom: 'Risotto aux Champignons',
    description: 'Riz arborio crémeux aux champignons de saison et parmesan',
    prix: 18.70,
    image_url: 'https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg?auto=compress&cs=tinysrgb&w=800',
    categorie: 'plat_principal'
  },
  {
    nom: 'Pizza Margherita',
    description: 'Pizza traditionnelle avec sauce tomate, mozzarella fraîche et basilic',
    prix: 16.90,
    image_url: 'https://images.pexels.com/photos/315755/pexels-photo-315755.jpeg?auto=compress&cs=tinysrgb&w=800',
    categorie: 'plat_principal'
  },

  // DESSERTS
  {
    nom: 'Tiramisu Maison',
    description: 'Dessert italien traditionnel au café et mascarpone',
    prix: 8.50,
    image_url: 'https://images.pexels.com/photos/6880219/pexels-photo-6880219.jpeg?auto=compress&cs=tinysrgb&w=800',
    categorie: 'dessert'
  },
  {
    nom: 'Tarte Tatin',
    description: 'Tarte aux pommes caramélisées servie tiède avec une boule de glace vanille',
    prix: 9.20,
    image_url: 'https://images.pexels.com/photos/1126359/pexels-photo-1126359.jpeg?auto=compress&cs=tinysrgb&w=800',
    categorie: 'dessert'
  },
  {
    nom: 'Mousse au Chocolat',
    description: 'Mousse onctueuse au chocolat noir 70% avec chantilly maison',
    prix: 7.80,
    image_url: 'https://images.pexels.com/photos/2067396/pexels-photo-2067396.jpeg?auto=compress&cs=tinysrgb&w=800',
    categorie: 'dessert'
  },

  // BOISSONS
  {
    nom: 'Vin Rouge - Côtes du Rhône',
    description: 'Vin rouge français AOC, bouteille 75cl',
    prix: 28.00,
    image_url: 'https://images.pexels.com/photos/434311/pexels-photo-434311.jpeg?auto=compress&cs=tinysrgb&w=800',
    categorie: 'boisson'
  },
  {
    nom: 'Café Espresso',
    description: 'Café italien traditionnel servi dans une tasse en porcelaine',
    prix: 3.50,
    image_url: 'https://images.pexels.com/photos/302899/pexels-photo-302899.jpeg?auto=compress&cs=tinysrgb&w=800',
    categorie: 'boisson'
  }
];

async function createMenuTable() {
  const createTableQuery = `
    CREATE TABLE IF NOT EXISTS menu (
      id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
      nom VARCHAR(100) NOT NULL UNIQUE,
      description TEXT NOT NULL,
      prix DECIMAL(10,2) NOT NULL CHECK (prix >= 0),
      image_url VARCHAR(500) NOT NULL,
      categorie VARCHAR(20) NOT NULL CHECK (categorie IN ('entree', 'plat_principal', 'dessert', 'boisson')),
      disponible BOOLEAN DEFAULT true,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
    );
  `;

  const createIndexesQuery = `
    CREATE INDEX IF NOT EXISTS idx_menu_categorie ON menu(categorie);
    CREATE INDEX IF NOT EXISTS idx_menu_disponible ON menu(disponible);
    CREATE INDEX IF NOT EXISTS idx_menu_nom ON menu(nom);
  `;

  const createTriggerQuery = `
    CREATE TRIGGER update_menu_updated_at 
      BEFORE UPDATE ON menu 
      FOR EACH ROW 
      EXECUTE FUNCTION update_updated_at_column();
  `;

  try {
    await pool.query(createTableQuery);
    console.log('✅ Table menu créée avec succès');

    await pool.query(createIndexesQuery);
    console.log('✅ Index créés avec succès');

    // Vérifier si le trigger existe déjà
    const triggerExists = await pool.query(`
      SELECT 1 FROM pg_trigger WHERE tgname = 'update_menu_updated_at'
    `);

    if (triggerExists.rows.length === 0) {
      await pool.query(createTriggerQuery);
      console.log('✅ Trigger créé avec succès');
    } else {
      console.log('ℹ️  Trigger déjà existant');
    }

  } catch (error) {
    console.error('❌ Erreur lors de la création de la table:', error);
    throw error;
  }
}

async function populateMenu() {
  try {
    // Vérifier si des plats existent déjà
    const existingPlats = await pool.query('SELECT COUNT(*) FROM menu');
    const count = parseInt(existingPlats.rows[0].count);

    if (count > 0) {
      console.log(`ℹ️  ${count} plats déjà présents dans la base de données`);
      const response = await new Promise((resolve) => {
        const readline = require('readline');
        const rl = readline.createInterface({
          input: process.stdin,
          output: process.stdout
        });

        rl.question('Voulez-vous supprimer les données existantes et les remplacer ? (y/N): ', (answer) => {
          rl.close();
          resolve(answer.toLowerCase() === 'y' || answer.toLowerCase() === 'yes');
        });
      });

      if (response) {
        await pool.query('DELETE FROM menu');
        console.log('🗑️  Données existantes supprimées');
      } else {
        console.log('⏭️  Conservation des données existantes');
        return;
      }
    }

    // Insérer les nouveaux plats
    const insertQuery = `
      INSERT INTO menu (nom, description, prix, image_url, categorie, disponible)
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING id, nom, categorie
    `;

    let insertedCount = 0;
    for (const plat of platsData) {
      try {
        const result = await pool.query(insertQuery, [
          plat.nom,
          plat.description,
          plat.prix,
          plat.image_url,
          plat.categorie,
          true
        ]);

        console.log(`✅ Plat ajouté: ${result.rows[0].nom} (${result.rows[0].categorie})`);
        insertedCount++;
      } catch (error) {
        if (error.code === '23505') { // Contrainte unique violée
          console.log(`⚠️  Plat déjà existant: ${plat.nom}`);
        } else {
          console.error(`❌ Erreur lors de l'insertion de ${plat.nom}:`, error.message);
        }
      }
    }

    console.log(`\n🎉 ${insertedCount} plats ajoutés avec succès au menu !`);

    // Afficher un résumé par catégorie
    const summary = await pool.query(`
      SELECT categorie, COUNT(*) as count 
      FROM menu 
      GROUP BY categorie 
      ORDER BY categorie
    `);

    console.log('\n📊 Résumé du menu par catégorie:');
    summary.rows.forEach(row => {
      console.log(`   ${row.categorie}: ${row.count} plat(s)`);
    });

  } catch (error) {
    console.error('❌ Erreur lors du peuplement du menu:', error);
    throw error;
  }
}

async function main() {
  try {
    console.log('🚀 Initialisation du menu...\n');

    // Créer la table et les index
    await createMenuTable();

    // Peupler avec les données
    await populateMenu();

    console.log('\n✅ Initialisation du menu terminée avec succès !');
    
  } catch (error) {
    console.error('\n❌ Erreur lors de l\'initialisation:', error);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

// Exécuter le script si appelé directement
if (require.main === module) {
  main();
}

module.exports = { createMenuTable, populateMenu }; 