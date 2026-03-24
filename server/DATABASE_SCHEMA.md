# Schéma de la base de données

Base de données **PocketBase / SQLite** — Open Food Facts

---

## Tables

### `users` — Comptes utilisateurs
> Table native PocketBase (auth collection). Gérée automatiquement.

| Champ      | Type   | Rôle | Description                                      |
|------------|--------|------|--------------------------------------------------|
| `id`       | text   | PK   | Identifiant unique généré par PocketBase         |
| `email`    | text   |      | Adresse e-mail (unique, sert à la connexion)     |
| `password` | text   |      | Mot de passe hashé par PocketBase                |
| `name`     | text   |      | Nom d'affichage de l'utilisateur                 |
| `verified` | bool   |      | Compte vérifié (`true` pour les comptes seedés)  |
| `created`  | date   |      | Date de création du compte                       |

---

### `products` — Catalogue de produits alimentaires
> Alimenté par l'API OpenFoodFacts lors d'un scan, et par les rappels au démarrage.

| Champ        | Type | Rôle | Description                                      |
|--------------|------|------|--------------------------------------------------|
| `id`         | text | PK   | Identifiant unique généré par PocketBase         |
| `barcode`    | text | UK   | Code-barres EAN (unique, indexé)                 |
| `name`       | text |      | Nom du produit (issu de l'API OpenFoodFacts)     |
| `brand`      | text |      | Marque du produit                                |
| `image_url`  | text |      | URL de la photo du produit                       |
| `nutriscore` | text |      | Lettre du Nutri-Score (A–E, ou vide si inconnu)  |

---

### `rappels` — Rappels produits officiels
> Synchronisée depuis l'API Rappel Conso deux fois par jour (CRON 0h et 12h).
> Chargée initialement depuis `rappels.json` au démarrage.

| Champ                           | Type | Rôle | Description                                        |
|---------------------------------|------|------|----------------------------------------------------|
| `id`                            | text | PK   | Identifiant unique généré par PocketBase           |
| `libelle_produit`               | text |      | Nom du produit rappelé                             |
| `marque`                        | text |      | Marque du produit                                  |
| `identification_lots`           | text |      | EAN + lots au format `EAN$lot$type$date$`          |
| `photo_url`                     | text |      | URL de la photo du produit                         |
| `date_debut_commercialisation`  | text |      | Date de début de commercialisation                 |
| `date_fin_commercialisation`    | text |      | Date de fin de commercialisation                   |
| `distributeurs`                 | text |      | Liste des distributeurs concernés                  |
| `zone_geographique`             | text |      | Régions concernées (séparées par `\|`)              |
| `motif_rappel`                  | text |      | Raison du rappel (ex : présence de salmonelles)    |
| `risques_encourus`              | text |      | Description des risques sanitaires pour le consommateur |
| `informations_complementaires`  | text |      | Informations additionnelles (peut être `null`)     |
| `conduite_a_tenir`              | text |      | Actions recommandées (séparées par `\|`)            |
| `lien_pdf`                      | text |      | URL de la fiche PDF officielle Rappel Conso        |
| `numero_contact`                | text |      | Numéro de téléphone du service consommateur        |
| `modalites_compensation`        | text |      | Type de compensation proposée (ex : remboursement) |

---

### `scans` — Historique des scans par utilisateur

| Champ           | Type | Rôle | Description                                          |
|-----------------|------|------|------------------------------------------------------|
| `id`            | text | PK   | Identifiant unique généré par PocketBase             |
| `user_id`       | text | FK   | Référence vers `users.id`                            |
| `barcode`       | text |      | Code-barres EAN du produit scanné                    |
| `product_name`  | text |      | Nom du produit au moment du scan *(dénormalisé)*     |
| `product_image` | text |      | URL de l'image au moment du scan *(dénormalisé)*     |
| `created`       | date |      | Horodatage du scan (utilisé pour le tri chronologique) |

---

### `favorites` — Favoris par utilisateur

| Champ           | Type | Rôle | Description                                      |
|-----------------|------|------|--------------------------------------------------|
| `id`            | text | PK   | Identifiant unique généré par PocketBase         |
| `user_id`       | text | FK   | Référence vers `users.id`                        |
| `barcode`       | text |      | Code-barres EAN du produit mis en favori         |
| `product_name`  | text |      | Nom du produit *(dénormalisé)*                   |
| `product_image` | text |      | URL de l'image *(dénormalisé)*                   |

---

## Relations

```
users ──────────────────────────────────────────────────────┐
  │  id                                                      │
  │                                                          │
  ├──< scans                                                 │
  │      user_id ──────────────────────────────> users.id   │
  │      barcode ──────────────────────────────> products.barcode
  │      product_name  (copie dénormalisée)                  │
  │      product_image (copie dénormalisée)                  │
  │                                                          │
  └──< favorites                                             │
         user_id ───────────────────────────────> users.id  │
         barcode ───────────────────────────────> products.barcode
         product_name  (copie dénormalisée)
         product_image (copie dénormalisée)


products ◄──────────────────────────────────────────────────┤
  barcode (UK)                                               │
    ▲                                                        │
    │   alimenté au scan (API OpenFoodFacts)                 │
    │   alimenté au démarrage (depuis rappels)               │
    │                                                        │
rappels                                                      │
  identification_lots : "EAN$lot$type$date$"                 │
                          └── barcode = premier segment ─────┘
```

---

## Légende

| Symbole | Signification |
|---------|---------------|
| PK      | Clé primaire (Primary Key) |
| FK      | Clé étrangère (Foreign Key) — relation logique, non enforced par PocketBase |
| UK      | Contrainte d'unicité (Unique Key) — index unique |
| `──<`   | Relation un-à-plusieurs (1→N) |
| `──>`   | Référence vers une autre table |

---

## Notes de conception

**Dénormalisation de `scans` et `favorites`**
Les champs `product_name` et `product_image` sont copiés au moment de l'enregistrement. Cela garantit que l'historique et les favoris restent cohérents même si les données d'un produit sont mises à jour ultérieurement dans `products`.

**Pas de foreign keys enforced**
PocketBase ne supporte pas les contraintes de clé étrangère au niveau base de données. Les relations sont gérées par convention applicative dans les services Flutter (`ScanService`, `FavoriteService`).

**Index unique sur `products.barcode`**
Créé via la directive `indexes` dans le hook `products_collection.pb.js`, il empêche les doublons lors de l'upsert (scan d'un même produit par plusieurs utilisateurs).

**Extraction du barcode depuis `rappels`**
Le champ `identification_lots` suit le format `EAN$lot$type$date$`. Le barcode est extrait en prenant le premier segment (`split('$')[0]`), ce qui permet de croiser les données rappels avec le catalogue `products`.