const pool = require('../config/database');
const bcrypt = require('bcryptjs');

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

// Données des utilisateurs par défaut
const usersData = [
  {
    nom: 'Martin',
    prenom: 'Jean',
    email: 'client@restaurant.com',
    password: 'Client123!',
    telephone: '0123456789',
    role: 'client'
  },
  {
    nom: 'Dubois',
    prenom: 'Marie',
    email: 'serveur@restaurant.com',
    password: 'Serveur123!',
    telephone: '0987654321',
    role: 'serveur'
  }
];

async function populateMenu() {
  try {
    // Vérifier si la table menu existe
    const tableExists = await pool.query(`
      SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'menu'
      );
    `);

    if (!tableExists.rows[0].exists) {
      console.log('❌ La table menu n\'existe pas. Veuillez d\'abord exécuter le script init-db.sql');
      return;
    }

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

async function populateUsers() {
  try {
    // Vérifier si la table users existe
    const tableExists = await pool.query(`
      SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'users'
      );
    `);

    if (!tableExists.rows[0].exists) {
      console.log('❌ La table users n\'existe pas. Veuillez d\'abord exécuter le script init-db.sql');
      return;
    }

    // Vérifier si des utilisateurs existent déjà
    const existingUsers = await pool.query('SELECT COUNT(*) FROM users');
    const count = parseInt(existingUsers.rows[0].count);

    if (count > 0) {
      console.log(`ℹ️  ${count} utilisateurs déjà présents dans la base de données`);
      const response = await new Promise((resolve) => {
        const readline = require('readline');
        const rl = readline.createInterface({
          input: process.stdin,
          output: process.stdout
        });

        rl.question('Voulez-vous supprimer les utilisateurs existants et les remplacer ? (y/N): ', (answer) => {
          rl.close();
          resolve(answer.toLowerCase() === 'y' || answer.toLowerCase() === 'yes');
        });
      });

      if (response) {
        await pool.query('DELETE FROM users');
        console.log('🗑️  Utilisateurs existants supprimés');
      } else {
        console.log('⏭️  Conservation des utilisateurs existants');
        return;
      }
    }

    // Insérer les nouveaux utilisateurs
    const insertQuery = `
      INSERT INTO users (nom, prenom, email, password, telephone, role)
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING id, email, role
    `;

    let insertedCount = 0;
    for (const user of usersData) {
      try {
        // Hasher le mot de passe
        const hashedPassword = await bcrypt.hash(user.password, 12);

        const result = await pool.query(insertQuery, [
          user.nom,
          user.prenom,
          user.email,
          hashedPassword,
          user.telephone,
          user.role
        ]);

        console.log(`✅ Utilisateur ajouté: ${result.rows[0].email} (${result.rows[0].role})`);
        insertedCount++;
      } catch (error) {
        if (error.code === '23505') { // Contrainte unique violée
          console.log(`⚠️  Utilisateur déjà existant: ${user.email}`);
        } else {
          console.error(`❌ Erreur lors de l'insertion de ${user.email}:`, error.message);
        }
      }
    }

    console.log(`\n🎉 ${insertedCount} utilisateurs ajoutés avec succès !`);

    // Afficher un résumé par rôle
    const summary = await pool.query(`
      SELECT role, COUNT(*) as count 
      FROM users 
      GROUP BY role 
      ORDER BY role
    `);

    console.log('\n👥 Résumé des utilisateurs par rôle:');
    summary.rows.forEach(row => {
      console.log(`   ${row.role}: ${row.count} utilisateur(s)`);
    });

    // Afficher les informations de connexion
    console.log('\n🔑 Informations de connexion:');
    console.log('   Client: client@restaurant.com / client123');
    console.log('   Serveur: serveur@restaurant.com / serveur123');

  } catch (error) {
    console.error('❌ Erreur lors du peuplement des utilisateurs:', error);
    throw error;
  }
}

async function main() {
  try {
    console.log('🚀 Peuplement de la base de données...\n');

    // Peupler avec les données
    await populateUsers();
    await populateMenu();

    console.log('\n✅ Peuplement de la base de données terminé avec succès !');
    
  } catch (error) {
    console.error('\n❌ Erreur lors du peuplement:', error);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

// Exécuter le script si appelé directement
if (require.main === module) {
  main();
}

module.exports = { populateMenu, populateUsers }; 