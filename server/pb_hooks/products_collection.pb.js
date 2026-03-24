/// <reference path="../pb_data/types.d.ts" />

// ================================================================
// Crée la collection "products" si elle n'existe pas.
// Un produit = un barcode unique avec nom, marque, image, nutriscore.
// ================================================================

onBootstrap(function (e) {
  e.next();

  try {
    $app.findCollectionByNameOrId("products");
    console.log("[products] Collection 'products' déjà existante ✅");
    return;
  } catch (_) {}

  var col = new Collection({
    name: "products",
    type: "base",
    fields: [
      { name: "barcode",    type: "text", required: true },
      { name: "name",       type: "text" },
      { name: "brand",      type: "text" },
      { name: "image_url",  type: "text" },
      { name: "nutriscore", type: "text" },
    ],
    indexes: [
      // Index unique sur barcode pour éviter les doublons
      "CREATE UNIQUE INDEX idx_products_barcode ON products (barcode)"
    ],
  });

  $app.save(col);
  console.log("[products] ✅ Collection 'products' créée");
});