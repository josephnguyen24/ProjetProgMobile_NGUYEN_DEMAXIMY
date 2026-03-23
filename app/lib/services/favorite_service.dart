import 'package:flutter/material.dart';
import 'package:formation_flutter/model/favorite_record.dart';
import 'package:formation_flutter/pocketbase/pocketbase_client.dart';

/// Gère les favoris de l'utilisateur connecté.
///
/// Usage :
///   context.watch<FavoriteService>().isFavorite('barcode') → bool
///   context.watch<FavoriteService>().favorites             → liste
///   context.read<FavoriteService>().toggle(barcode, name, image)
class FavoriteService extends ChangeNotifier {
  /// Map barcode → FavoriteRecord (pour lookup O(1))
  final Map<String, FavoriteRecord> _byBarcode = {};
  bool _isLoading = false;
  bool _loaded = false;

  List<FavoriteRecord> get favorites => _byBarcode.values.toList();
  bool get isLoading => _isLoading;
  bool isFavorite(String barcode) => _byBarcode.containsKey(barcode);

  /// Charge tous les favoris de l'utilisateur.
  Future<void> load({bool force = false}) async {
    if (_loaded && !force) return;

    final userId = PocketBaseClient.instance.authStore.record?.id;
    if (userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final records = await PocketBaseClient.instance
          .collection('favorites')
          .getFullList(filter: "user_id = '$userId'");

      _byBarcode.clear();
      for (final r in records) {
        final fav = FavoriteRecord.fromRecord(r);
        _byBarcode[fav.barcode] = fav;
      }
      _loaded = true;
    } catch (e) {
      debugPrint('[FavoriteService] Erreur chargement : $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Ajoute ou retire [barcode] des favoris.
  Future<void> toggle(
    String barcode, {
    String? productName,
    String? productImage,
  }) async {
    final userId = PocketBaseClient.instance.authStore.record?.id;
    if (userId == null) return;

    if (isFavorite(barcode)) {
      // ── Retrait ─────────────────────────────────────────────
      final id = _byBarcode[barcode]!.id;
      try {
        await PocketBaseClient.instance.collection('favorites').delete(id);
        _byBarcode.remove(barcode);
        notifyListeners();
      } catch (e) {
        debugPrint('[FavoriteService] Erreur suppression : $e');
      }
    } else {
      // ── Ajout ────────────────────────────────────────────────
      try {
        final record = await PocketBaseClient.instance
            .collection('favorites')
            .create(body: {
          'user_id':       userId,
          'barcode':       barcode,
          'product_name':  productName ?? '',
          'product_image': productImage ?? '',
        });
        _byBarcode[barcode] = FavoriteRecord.fromRecord(record);
        notifyListeners();
      } catch (e) {
        debugPrint('[FavoriteService] Erreur ajout : $e');
      }
    }
  }

  /// Réinitialise le service (à la déconnexion).
  void clear() {
    _byBarcode.clear();
    _loaded = false;
    notifyListeners();
  }
}