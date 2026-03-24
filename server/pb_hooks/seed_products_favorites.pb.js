/// <reference path="../pb_data/types.d.ts" />

// ================================================================
// 1. Déverse tous les rappels dans la table "products"
//    (barcode = premier segment de identification_lots)
// 2. Crée 2 favoris de test pour test@openfoodfacts.fr
// ================================================================

onBootstrap(function (e) {
  e.next();

  // ── Helpers ───────────────────────────────────────────────────

  function findOrCreate(collectionName, filterExpr, buildRecord) {
    try {
      return $app.findFirstRecordByFilter(collectionName, filterExpr);
    } catch (_) {}

    var col = $app.findCollectionByNameOrId(collectionName);
    var rec = new Record(col);
    buildRecord(rec);
    $app.save(rec);
    return rec;
  }

  // ── 1. Sync rappels → products ─────────────────────────────────

  try {
    var rappels = $app.findAllRecords("rappels");
    var productsCol = $app.findCollectionByNameOrId("products");
    var created = 0;
    var skipped = 0;

    for (var i = 0; i < rappels.length; i++) {
      var r = rappels[i];

      var lots    = r.getString("identification_lots") || "";
      var barcode = lots.split("$")[0] || "";

      if (!barcode) { skipped++; continue; }

      // Vérifie si le produit existe déjà
      var existing = null;
      try {
        existing = $app.findFirstRecordByFilter(
          "products",
          "barcode = '" + barcode.replace(/'/g, "\\'") + "'"
        );
      } catch (_) {}

      if (existing) { skipped++; continue; }

      var rec = new Record(productsCol);
      rec.set("barcode",    barcode);
      rec.set("name",       r.getString("libelle_produit") || barcode);
      rec.set("brand",      r.getString("marque") || "");
      rec.set("image_url",  r.getString("photo_url") || "");
      rec.set("nutriscore", "");
      $app.save(rec);
      created++;
    }

    console.log("[seed_products] " + created + " produits créés depuis rappels, " + skipped + " ignorés ✅");
  } catch (err) {
    console.error("[seed_products] Erreur sync rappels→products :", err);
  }

  // ── 2. Seed favoris pour test@openfoodfacts.fr ──────────────────

  try {
    // Trouve l'utilisateur test
    var testUser = null;
    try {
      testUser = $app.findFirstRecordByFilter(
        "users",
        "email = 'test@openfoodfacts.fr'"
      );
    } catch (_) {
      console.log("[seed_favorites] Utilisateur test@openfoodfacts.fr introuvable, skip");
      return;
    }

    // Prend les 2 premiers produits issus des rappels
    var rappels = $app.findAllRecords("rappels");
    var favsCol = $app.findCollectionByNameOrId("favorites");
    var added = 0;

    for (var i = 0; i < rappels.length && added < 2; i++) {
      var r = rappels[i];
      var lots    = r.getString("identification_lots") || "";
      var barcode = lots.split("$")[0] || "";
      if (!barcode) continue;

      // Pas de doublon dans les favoris
      var existingFav = null;
      try {
        existingFav = $app.findFirstRecordByFilter(
          "favorites",
          "user_id = '" + testUser.id + "' && barcode = '" + barcode.replace(/'/g, "\\'") + "'"
        );
      } catch (_) {}
      if (existingFav) { added++; continue; }

      var fav = new Record(favsCol);
      fav.set("user_id",       testUser.id);
      fav.set("barcode",       barcode);
      fav.set("product_name",  r.getString("libelle_produit") || barcode);
      fav.set("product_image", r.getString("photo_url") || "");
      $app.save(fav);
      added++;
      console.log("[seed_favorites] Favori ajouté : " + r.getString("libelle_produit"));
    }

    console.log("[seed_favorites] " + added + " favoris ajoutés pour test@openfoodfacts.fr ✅");
  } catch (err) {
    console.error("[seed_favorites] Erreur :", err);
  }
});