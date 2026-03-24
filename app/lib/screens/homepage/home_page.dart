import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:formation_flutter/screens/homepage/homepage_empty.dart';
import 'package:formation_flutter/screens/homepage/homepage_history.dart';
import 'package:formation_flutter/screens/product/product_page.dart';
import 'package:formation_flutter/services/auth_service.dart';
import 'package:formation_flutter/services/favorite_service.dart';
import 'package:formation_flutter/services/product_service.dart';
import 'package:formation_flutter/services/scan_service.dart';
import 'package:provider/provider.dart';

/// Dashboard principal.
///
/// Comportement :
///   - Si la table `scans` est vide pour cet user → [HomePageEmpty]
///   - Si elle contient au moins 1 scan             → [HomePageHistoryScreen]
///
/// Le bouton scanner (AppBar + bouton "COMMENCER") déclenche [_scanBarcode] :
///   1. Lecture du code-barres via la caméra
///   2. Navigation vers la fiche produit
///   3. En arrière-plan : appel API + upsert BDD + enregistrement du scan
///   4. Mise à jour instantanée de l'historique (via [ScanService.addScan])
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// En cours de traitement (appel API + écriture BDD)
  bool _processing = false;

  // ── Scan ────────────────────────────────────────────────────────

  Future<void> _scanBarcode() async {
    String barcode;

    // 1. Lecture via la caméra
    try {
      final result = await BarcodeScanner.scan();
      barcode = result.rawContent;
      if (barcode.isEmpty) return; // annulé par l'utilisateur
    } catch (e) {
      debugPrint('Erreur scanner : $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Impossible d'ouvrir la caméra (disponible uniquement sur mobile).",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // 2. Navigation immédiate vers la fiche produit
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductPage(barcode: barcode)),
      );
    }

    // 3. Traitement en arrière-plan (API + BDD)
    if (_processing) return; // évite les doubles appels simultanés
    setState(() => _processing = true);

    try {
      final scanRecord = await ProductService().processScan(barcode);

      // 4. Mise à jour instantanée de l'historique
      if (mounted) {
        context.read<ScanService>().addScan(scanRecord);
      }
    } catch (e) {
      debugPrint('[HomePage] Erreur traitement scan : $e');
      // On n'interrompt pas l'UX : la fiche produit est déjà ouverte
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  // ── Déconnexion ─────────────────────────────────────────────────

  void _logout() {
    context.read<AuthService>().logout();
    context.read<ScanService>().clear();
    context.read<FavoriteService>().clear();
    Navigator.pushReplacementNamed(context, '/login');
  }

  // ── Build ───────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final scanService = context.watch<ScanService>();
    final hasScans    = scanService.hasScans;
    final isLoading   = scanService.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes scans'),
        automaticallyImplyLeading: false,
        actions: [
          // Bouton scanner visible seulement quand il y a déjà des scans
          if (hasScans)
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.qr_code_scanner, size: 28),
                  onPressed: _processing ? null : _scanBarcode,
                ),
                if (_processing)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          IconButton(
            icon: const Icon(Icons.star_outline, size: 26),
            onPressed: () => Navigator.pushNamed(context, '/favorites'),
            tooltip: 'Mes favoris',
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app, size: 26),
            onPressed: _logout,
            tooltip: 'Se déconnecter',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: isLoading
          // ── Chargement initial ──────────────────────────────────
          ? const Center(child: CircularProgressIndicator())

          // ── Historique vide ────────────────────────────────────
          : !hasScans
              ? HomePageEmpty(onScan: _scanBarcode)

              // ── Historique avec scans ──────────────────────────
              : HomePageHistoryScreen(showAppBar: false),
    );
  }
}