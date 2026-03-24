import 'package:flutter/material.dart';
import 'package:formation_flutter/api/open_food_facts_api.dart';
import 'package:formation_flutter/model/product_old.dart' as rich;
import 'package:formation_flutter/model/product_model.dart';
import 'package:formation_flutter/model/scan_record.dart';
import 'package:formation_flutter/pocketbase/pocketbase_client.dart';
import 'package:pocketbase/pocketbase.dart';

/// Orchestre le flux complet après un scan :
///
///  1. Vérifie si le produit (barcode) existe dans la table `products` PocketBase
///  2. Si non → appelle l'API OpenFoodFacts pour récupérer nom + image
///  3. Insère le produit dans `products` (upsert)
///  4. Enregistre un nouveau scan dans `scans` pour l'utilisateur courant
///  5. Retourne le [ScanRecord] créé (pour mise à jour immédiate de l'UI)
class ProductService {
  final _pb = PocketBaseClient.instance;

  // ── Point d'entrée public ───────────────────────────────────────

  /// Traite un scan complet et retourne le [ScanRecord] persisté.
  /// Lance une exception si l'utilisateur n'est pas connecté.
  Future<ScanRecord> processScan(String barcode) async {
    final userId = _pb.authStore.record?.id;
    if (userId == null) throw Exception('Utilisateur non connecté');

    // 1 & 2 & 3 — Upsert produit
    final product = await _upsertProduct(barcode);

    // 4 — Enregistrement du scan
    final scanRecord = await _pb.collection('scans').create(body: {
      'user_id':       userId,
      'barcode':       product.barcode,
      'product_name':  product.name,
      'product_image': product.imageUrl,
    });

    return ScanRecord.fromRecord(scanRecord);
  }

  // ── Helpers privés ──────────────────────────────────────────────

  /// Retourne le [ProductModel] existant ou le crée après appel API.
  Future<ProductModel> _upsertProduct(String barcode) async {
    // 1. Cherche dans PocketBase
    try {
      final existing = await _pb
          .collection('products')
          .getFirstListItem("barcode = '$barcode'");
      debugPrint('[ProductService] Produit trouvé en BDD : $barcode');
      return ProductModel.fromRecord(existing);
    } on ClientException catch (e) {
      // 404 = pas trouvé → on continue ; autre erreur → on remonte
      if (e.statusCode != 404) rethrow;
    }

    // 2. Appel API OpenFoodFacts
    debugPrint('[ProductService] Produit inconnu, appel API : $barcode');
    String name      = barcode; // fallback = le code lui-même
    String imageUrl  = '';
    String brand     = '';
    String nutriscore = '';

    try {
      final rich.ProductOld apiProduct =
          await OpenFoodFactsAPI().getProduct(barcode);
      name       = apiProduct.name ?? barcode;
      imageUrl   = apiProduct.picture ?? '';
      brand      = apiProduct.brands?.join(', ') ?? '';
      nutriscore = apiProduct.nutriScore?.name ?? '';
    } catch (e) {
      debugPrint('[ProductService] API introuvable pour $barcode : $e');
      // Produit inconnu mais on continue : on sauvegarde avec le barcode
    }

    // 3. Insert dans PocketBase
    final RecordModel created = await _pb.collection('products').create(body: {
      'barcode':    barcode,
      'name':       name,
      'brand':      brand,
      'image_url':  imageUrl,
      'nutriscore': nutriscore,
    });

    debugPrint('[ProductService] Produit créé en BDD : $name ($barcode)');
    return ProductModel.fromRecord(created);
  }
}