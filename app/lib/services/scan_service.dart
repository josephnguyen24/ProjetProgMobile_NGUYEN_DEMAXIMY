import 'package:flutter/material.dart';
import 'package:formation_flutter/model/scan_record.dart';
import 'package:formation_flutter/pocketbase/pocketbase_client.dart';

/// Gère la liste des scans de l'utilisateur connecté.
///
/// - [scans]    : liste triée du plus récent au plus ancien
/// - [hasScans] : bool (au moins 1 scan)
/// - [isLoading]: chargement initial en cours
/// - [load()]   : charge depuis PocketBase
/// - [addScan()] : ajoute en tête de liste (mise à jour instantanée de l'UI)
/// - [clear()]  : réinitialise à la déconnexion
class ScanService extends ChangeNotifier {
  List<ScanRecord> _scans = [];
  bool _isLoading = false;
  bool _loaded = false;

  List<ScanRecord> get scans => List.unmodifiable(_scans);
  bool get hasScans => _scans.isNotEmpty;
  bool get isLoading => _isLoading;

  /// Charge les scans depuis PocketBase (triés desc par date de création).
  /// Si [force] est false et déjà chargé, ne refait pas la requête.
  Future<void> load({bool force = false}) async {
    if (_loaded && !force) return;

    final userId = PocketBaseClient.instance.authStore.record?.id;
    if (userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final records = await PocketBaseClient.instance
          .collection('scans')
          .getFullList(
            filter: "user_id = '$userId'",
            sort: '-created',
          );

      _scans = records.map(ScanRecord.fromRecord).toList();
      _loaded = true;
    } catch (e) {
      debugPrint('[ScanService] Erreur chargement : $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Ajoute un scan en tête de liste sans recharger toute la BDD.
  /// Appelé par [HomePage] après un scan réussi.
  void addScan(ScanRecord scan) {
    _scans.insert(0, scan);
    _loaded = true; // marque comme chargé si ce n'était pas le cas
    notifyListeners();
  }

  /// Réinitialise le service (à la déconnexion).
  void clear() {
    _scans = [];
    _loaded = false;
    notifyListeners();
  }
}