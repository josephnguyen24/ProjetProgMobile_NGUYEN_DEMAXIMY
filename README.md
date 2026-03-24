# Open Food Facts

Documentation technique du projet — NGUYEN · DEMAXIMY

---

## Table des matières

1. [Présentation](#1-présentation)
2. [Prérequis](#2-prérequis)
3. [Installation et lancement](#3-installation-et-lancement)
4. [Architecture](#4-architecture)
5. [Base de données](#5-base-de-données)
6. [Fonctionnement de l'application](#6-fonctionnement-de-lapplication)
7. [Notes techniques](#7-notes-techniques)

---

## 1. Présentation

Open Food Facts est une application mobile Flutter connectée à un backend PocketBase. Elle permet à un utilisateur authentifié de :

- **Scanner** des codes-barres de produits alimentaires
- **Consulter** la fiche nutritionnelle d'un produit (Nutri-Score, NOVA, Green-Score, ingrédients, allergènes, etc.)
- **Gérer** un historique personnel de scans et une liste de favoris
- **Être alerté** en cas de rappel produit actif, avec accès à la fiche PDF officielle Rappel Conso

Les données nutritionnelles proviennent de l'API OpenFoodFacts. Les rappels produits sont synchronisés automatiquement deux fois par jour depuis l'API officielle Rappel Conso.

---

## 2. Prérequis

Avant de démarrer, assurez-vous d'avoir installé les outils suivants.

### Outils obligatoires

| Outil | Version | Lien |
|---|---|---|
| Flutter SDK | ≥ 3.10.7 | https://docs.flutter.dev/get-started/install |
| Android SDK | inclus avec Android Studio | https://developer.android.com/studio |
| Java (JDK) | ≥ 17 | inclus avec Android Studio |

### Matériel nécessaire

- Un **téléphone Android** avec le **mode développeur activé** (voir ci-dessous)
- Un **câble USB** pour connecter le téléphone au PC
- Le téléphone et le PC doivent être sur le **même réseau Wi-Fi**

### Activer le mode développeur sur Android

1. Aller dans **Paramètres → À propos du téléphone**
2. Appuyer **7 fois** sur **Numéro de build**
3. Revenir dans **Paramètres → Options pour les développeurs**
4. Activer **Débogage USB**
5. Connecter le téléphone par câble — accepter l'autorisation sur l'écran du téléphone

> PocketBase est inclus dans le dossier `server/` du projet, aucune installation séparée n'est nécessaire.

---

## 3. Installation et lancement

### Étape 1 — Récupérer le projet

Si vous avez reçu le projet sous forme d'archive, décompressez-la. Sinon, clonez le dépôt :

```bash
git clone <url-du-dépôt>
cd ProjetProgMobile_NGUYEN_DEMAXIMY
```

### Étape 2 — Trouver l'adresse IP de votre PC

L'application mobile doit connaître l'adresse IP locale de votre PC pour communiquer avec PocketBase.

Ouvrez un terminal et exécutez :

```powershell
ipconfig
```

Repérez la ligne **Adresse IPv4** de votre connexion Wi-Fi. Elle ressemble à `192.168.1.42`.

### Étape 3 — Configurer l'adresse IP dans le projet

Ouvrez le fichier suivant dans un éditeur de texte :

```
app/lib/pocketbase/pocketbase_client.dart
```

Remplacez la valeur de `baseUrl` par votre IP :

```dart
static const String baseUrl = 'http://192.168.1.42:8090';
//                                    ↑ remplacez par votre IP
```

### Étape 4 — Lancer PocketBase

Ouvrez un terminal dans le dossier `server/` et exécutez :

```powershell
./pocketbase serve --http=0.0.0.0:8090
```

> L'option `--http=0.0.0.0:8090` est indispensable pour que le téléphone puisse se connecter.

Au **premier démarrage**, PocketBase crée automatiquement toutes les tables et insère les données de test. Vous devriez voir dans le terminal des messages comme :

```
[rappels] Collection créée ✅
[products] Collection 'products' créée ✅
[dashboard] Collection 'scans' créée ✅
[auth_seed] ✅ User de seed créé : test@openfoodfacts.fr / Test1234!
```

L'interface d'administration est accessible à l'adresse : **http://127.0.0.1:8090/_/**

> Laissez ce terminal ouvert pendant toute la session.

### Étape 5 — Installer les dépendances Flutter

Ouvrez un **second terminal** dans le dossier `app/` :

```bash
flutter pub get
```

### Étape 6 — Lancer l'application sur le téléphone

Avec le téléphone connecté en USB :

```bash
flutter run
```

Flutter détecte automatiquement le téléphone. Si plusieurs appareils sont connectés, il vous demande de choisir. Sélectionnez votre téléphone Android.

La première compilation prend plusieurs minutes. Les compilations suivantes sont beaucoup plus rapides.

### Compte de test

Un compte utilisateur est créé automatiquement au premier démarrage de PocketBase :

```
Email       : test@openfoodfacts.fr
Mot de passe : Test1234!
```

Ce compte possède des scans et des favoris pré-remplis pour tester toutes les fonctionnalités immédiatement.

---

## 4. Architecture

### Stack technique

| Composant | Technologie |
|---|---|
| Application mobile | Flutter / Dart |
| Backend & base de données | PocketBase 0.36.3 |
| Données nutritionnelles | API OpenFoodFacts (via proxy formation-flutter.fr) |
| Données de rappels | API Rappel Conso (data.rappel.conso.gouv.fr) |
| Gestion d'état | Provider (ChangeNotifier) |

### Structure du projet Flutter

```
app/lib/
├── api/                        → Appels HTTP vers l'API OpenFoodFacts
├── model/                      → Modèles de données
│   ├── product.dart            → Modèle riche (fiche nutritionnelle complète)
│   ├── product_model.dart      → Modèle léger (dashboard, historique, favoris)
│   ├── scan_record.dart        → Enregistrement d'un scan
│   ├── favorite_record.dart    → Enregistrement d'un favori
│   └── rappel.dart             → Données de rappel produit
├── pocketbase/
│   └── pocketbase_client.dart  → Instance PocketBase partagée (singleton)
├── services/                   → Logique métier
│   ├── auth_service.dart       → Connexion, inscription, déconnexion
│   ├── scan_service.dart       → Chargement et ajout de scans
│   ├── favorite_service.dart   → Gestion des favoris (toggle)
│   └── product_service.dart    → Upsert produit + enregistrement du scan
├── screens/
│   ├── auth/                   → Pages de connexion et d'inscription
│   ├── homepage/               → Tableau de bord (vide / historique)
│   ├── product/                → Fiche produit OpenFoodFacts
│   ├── favorites/              → Liste des favoris
│   └── rappel/                 → Détail d'un rappel produit
├── widget/                     → Widgets réutilisables
│   ├── product_card.dart       → Carte produit (historique, favoris)
│   ├── custom_button.dart      → Bouton stylisé
│   └── custom_input_field.dart → Champ de saisie avec icône
└── res/                        → Ressources (couleurs, icônes, thème, SVG)
```

### Structure du backend PocketBase

```
server/
├── pocketbase.exe                    → Exécutable PocketBase (Windows)
├── rappels.json                      → Données initiales de rappels (3 entrées)
├── pb_data/                          → Base SQLite (générée automatiquement)
└── pb_hooks/                         → Hooks JavaScript
    ├── rappels.pb.js                 → Crée la collection rappels, importe le JSON,
    │                                   lance le CRON de sync API (2x/jour)
    ├── auth_seed.pb.js               → Crée le compte utilisateur de test
    ├── products_collection.pb.js     → Crée la collection products
    ├── dashboard_seed.pb.js          → Crée scans et favorites, seed mock
    └── seed_products_favorites.pb.js → Déverse rappels → products,
                                        crée des favoris de test
```

---

## 5. Base de données

Le schéma détaillé est disponible dans le fichier [`DATABASE_SCHEMA.md`](./DATABASE_SCHEMA.md).

### Vue d'ensemble des tables

| Table | Rôle |
|---|---|
| `users` | Comptes utilisateurs (gérée nativement par PocketBase) |
| `products` | Catalogue de produits alimentaires (alimenté par l'API et les rappels) |
| `rappels` | Rappels produits officiels (sync API Rappel Conso) |
| `scans` | Historique des scans par utilisateur |
| `favorites` | Produits mis en favoris par utilisateur |

### Relations

- `scans.user_id` → `users.id` — un utilisateur possède plusieurs scans
- `favorites.user_id` → `users.id` — un utilisateur possède plusieurs favoris
- `scans.barcode` → `products.barcode` — un scan référence un produit
- `favorites.barcode` → `products.barcode` — un favori référence un produit
- `rappels.identification_lots` contient le code-barres en premier segment (`EAN$lot$...`), utilisé pour l'alimentation de `products` et la détection des alertes

> Les tables `scans` et `favorites` dupliquent volontairement `product_name` et `product_image` pour que l'historique reste cohérent même si un produit est modifié.

---

## 6. Fonctionnement de l'application

### Authentification

Au démarrage, l'application vérifie si un token de session valide est stocké localement. Si oui, l'utilisateur est directement redirigé vers son tableau de bord. Sinon, la page de connexion s'affiche.

La déconnexion efface le token et réinitialise l'état de tous les services.

### Tableau de bord

Après connexion, l'application interroge PocketBase pour récupérer les scans et favoris de l'utilisateur :

- **Aucun scan** → écran vide avec le bouton **COMMENCER** (qui lance le scanner)
- **Au moins un scan** → historique des scans, du plus récent au plus ancien

### Scanner un produit

1. L'application affiche un message de confirmation avant d'ouvrir la caméra
2. La caméra lit le code-barres EAN
3. La fiche produit s'ouvre **immédiatement**
4. En arrière-plan, l'application vérifie si le produit existe déjà en base
   - S'il est inconnu : appel à l'API OpenFoodFacts pour récupérer nom et photo, puis insertion dans `products`
5. Le scan est enregistré dans `scans` et apparaît instantanément dans l'historique

> Le scanner est disponible uniquement sur Android et iOS. Il ne fonctionne pas sur navigateur web.

### Favoris

L'icône étoile sur chaque fiche produit ajoute ou retire le produit des favoris. L'état est mis à jour en temps réel dans toute l'application.

### Rappels produits

Si un produit scanné fait l'objet d'un rappel actif, un **bandeau rouge** s'affiche sur sa fiche. En appuyant dessus, l'utilisateur accède au détail du rappel et peut ouvrir la fiche PDF officielle depuis le bouton en haut à droite de l'écran.

---

## 7. Notes techniques

### Le scanner ne s'ouvre pas

La bibliothèque `barcode_scan2` utilise la caméra native. Elle **ne fonctionne pas sur navigateur web**. Pour tester le scanner, utilisez impérativement un appareil Android physique ou un émulateur avec accès caméra.

### Erreur de build Android sous Windows

Si `flutter run` échoue avec une erreur du type `Unable to delete directory`, c'est qu'un processus Windows verrouille un fichier temporaire de build. La solution :

1. Fermez tous les terminaux Flutter ouverts
2. Exécutez dans le dossier `app/` :

```bash
flutter clean
flutter pub get
flutter run
```

Un redémarrage du PC résout également ce problème.

### PocketBase retourne 404 sur `/`

L'URL `http://127.0.0.1:8090/` affiche une erreur 404 par conception — PocketBase ne sert pas de page à la racine. Ce comportement est normal et n'affecte pas le fonctionnement de l'application.

- Interface d'administration : `http://127.0.0.1:8090/_/`
- API REST : `http://127.0.0.1:8090/api/`

### Variables à modifier avant le lancement

| Fichier | Variable | Description |
|---|---|---|
| `app/lib/pocketbase/pocketbase_client.dart` | `baseUrl` | IP locale du PC qui héberge PocketBase |

---

*Open Food Facts — NGUYEN · DEMAXIMY*