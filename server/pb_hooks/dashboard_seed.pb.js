/// <reference path="../pb_data/types.d.ts" />

// ================================================================
// Crée les collections "scans" et "favorites", puis seed
// 2 scans mock pour le user de test (test@yukka.fr).
// Les mock scans utilisent les rappels dont les IDs sont fournis.
// ================================================================

onBootstrap(function (e) {
  e.next();

  // ── 1. Collection "scans" ──────────────────────────────────────
  try {
    $app.findCollectionByNameOrId("scans");
    console.log("[dashboard] Collection 'scans' déjà existante ✅");
  } catch (_) {
    var scansCol = new Collection({
      name: "scans",
      type: "base",
      fields: [
        { name: "user_id",       type: "text", required: true },
        { name: "barcode",       type: "text" },
        { name: "product_name",  type: "text" },
        { name: "product_image", type: "text" },
      ],
    });
    $app.save(scansCol);
    console.log("[dashboard] Collection 'scans' créée ✅");
  }

  // ── 2. Collection "favorites" ──────────────────────────────────
  try {
    $app.findCollectionByNameOrId("favorites");
    console.log("[dashboard] Collection 'favorites' déjà existante ✅");
  } catch (_) {
    var favsCol = new Collection({
      name: "favorites",
      type: "base",
      fields: [
        { name: "user_id",       type: "text", required: true },
        { name: "barcode",       type: "text" },
        { name: "product_name",  type: "text" },
        { name: "product_image", type: "text" },
      ],
    });
    $app.save(favsCol);
    console.log("[dashboard] Collection 'favorites' créée ✅");
  }

  // ── 3. Seed mock scans ─────────────────────────────────────────
  // IDs des rappels utilisés comme produits mock
  var MOCK_RAPPEL_IDS = ["wjtnizfxhgw9sgv", "jxf4oiqgfevtfbn"];

  try {
    // Récupère le user de test (premier user trouvé par email)
    var testUser = null;
    try {
      testUser = $app.findFirstRecordByFilter("users", "email != ''");
    } catch (_) {
      console.log("[dashboard] Aucun user trouvé, skip seed scans");
      return;
    }

    var scansCollection = $app.findCollectionByNameOrId("scans");

    // Vérifie si des scans existent déjà pour ce user
    var existingScans = null;
    try {
      existingScans = $app.findFirstRecordByFilter(
        "scans",
        "user_id = '" + testUser.id + "'"
      );
    } catch (_) {}

    if (existingScans) {
      console.log("[dashboard] Mock scans déjà présents ✅");
      return;
    }

    // Crée un scan pour chaque rappel mock
    for (var i = 0; i < MOCK_RAPPEL_IDS.length; i++) {
      var rappelId = MOCK_RAPPEL_IDS[i];
      var rappel = null;

      try {
        rappel = $app.findRecordById("rappels", rappelId);
      } catch (_) {
        console.log("[dashboard] Rappel introuvable : " + rappelId + ", skip");
        continue;
      }

      // Extrait le code-barres (premier segment de identification_lots)
      var lots = rappel.getString("identification_lots") || "";
      var barcode = lots.split("$")[0] || rappelId;

      var scan = new Record(scansCollection);
      scan.set("user_id",       testUser.id);
      scan.set("barcode",       barcode);
      scan.set("product_name",  rappel.getString("libelle_produit") || "Produit inconnu");
      scan.set("product_image", rappel.getString("photo_url") || "");

      $app.save(scan);
      console.log("[dashboard] Scan mock créé : " + barcode);
    }

    console.log("[dashboard] ✅ Seed scans terminé");
  } catch (err) {
    console.error("[dashboard] ❌ Erreur seed :", err);
  }
});