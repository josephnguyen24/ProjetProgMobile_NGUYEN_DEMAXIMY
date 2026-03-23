/// <reference path="../pb_data/types.d.ts" />

// ============================================================
// Seed de la collection "users" (collection auth intégrée)
// S'exécute une seule fois au démarrage si aucun user n'existe.
// ============================================================

onBootstrap(function (e) {
  e.next();

  try {
    var usersCollection = $app.findCollectionByNameOrId("users");

    // Vérifie si le user de test existe déjà
    var existing = null;
    try {
      existing = $app.findFirstRecordByFilter(
        "users",
        "email = 'test@openfoodfacts.fr'"
      );
    } catch (_) {}

    if (existing) {
      console.log("[auth_seed] User de test déjà présent ✅");
      return;
    }

    // Création du user de seed
    var record = new Record(usersCollection);
    record.set("email",           "test@openfoodfacts.fr");
    record.set("password",        "Test1234!");
    record.set("passwordConfirm", "Test1234!");
    record.set("name",            "Utilisateur Test");
    record.set("verified",        true);

    $app.save(record);
    console.log("[auth_seed] ✅ User de seed créé : test@openfoodfacts.fr / Test1234!");

  } catch (err) {
    console.error("[auth_seed] ❌ Erreur :", err);
  }
});