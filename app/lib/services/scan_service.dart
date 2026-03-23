import 'package:flutter/material.dart';
import 'package:formation_flutter/model/scan_record.dart';
import 'package:formation_flutter/pocketbase/pocketbase_client.dart';

/// Gère la liste des scans de l'utilisateur connecté.
///
/// Usage :
///   context.watch<ScanService>().scans   → liste des scans (desc)
///   context.watch<ScanService>().hasScans → bool
///   context.read<ScanService>().load()   → rechargement manuel
class ScanService extends ChangeNotifier {
  List<ScanRecord> _scans = [];
  bool _isLoading = false;
  bool _loaded = false;

  List<ScanRecord> get scans => _scans;
  bool get hasScans => _scans.isNotEmpty;
  bool get isLoading => _isLoading;

  /// Charge les scans depuis PocketBase.
  /// Si [force] est false, ne recharge pas si déjà chargé.
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

  /// Réinitialise le service (à la déconnexion).
  void clear() {
    _scans = [];
    _loaded = false;
    notifyListeners();
  }
}