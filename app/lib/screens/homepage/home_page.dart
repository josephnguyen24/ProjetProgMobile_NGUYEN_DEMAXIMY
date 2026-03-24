import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:formation_flutter/l10n/app_localizations.dart';
import 'package:formation_flutter/res/app_icons.dart';
import 'package:formation_flutter/screens/homepage/homepage_empty.dart';
import 'package:formation_flutter/screens/homepage/homepage_history.dart';
import 'package:formation_flutter/screens/product/product_page.dart';
import 'package:formation_flutter/services/auth_service.dart';
import 'package:formation_flutter/services/favorite_service.dart';
import 'package:formation_flutter/services/product_service.dart';
import 'package:formation_flutter/services/scan_service.dart';
import 'package:provider/provider.dart';

// ================================================================
// FUSION DE home_page.dart ET homepage_screen.dart
//
// Comportement :
//   • À l'init : charge les scans (BDD) + favoris de l'utilisateur
//   • Pendant le chargement → spinner
//   • 0 scan en BDD          → HomePageEmpty  (bouton COMMENCER = scanner)
//   • ≥ 1 scan en BDD        → HomePageHistoryScreen (avec AppBar intégrée)
//
// Le scanner (AppBar + bouton "COMMENCER") :
//   1. Affiche "Tentative d'ouverture du scan" (SnackBar)
//   2. Lance BarcodeScanner
//   3. Vérifie que le résultat est un EAN/code non vide
//   4. Navigue immédiatement vers ProductPage
//   5. En arrière-plan : upsert produit dans `products` (via API si inconnu)
//      puis insert dans `scans`
//   6. Ajoute le scan en tête de liste (ScanService.addScan → rebuild UI)
// ================================================================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _processing = false;

  // ── Initialisation ──────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    // Charge scans + favoris dès l'arrivée sur la page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScanService>().load();
      context.read<FavoriteService>().load();
    });
  }

  // ── Scan ────────────────────────────────────────────────────────

  Future<void> _openScanner() async {
    // Message de debug visible par l'utilisateur
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📷 Tentative d\'ouverture du scan…'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    // 1. Ouverture de la caméra
    String barcode;
    try {
      final result = await BarcodeScanner.scan();
      barcode = result.rawContent.trim();
    } catch (e) {
      debugPrint('[Scanner] Erreur : $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '❌ Scanner indisponible sur cette plateforme.\n($e)',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    // 2. Vérification du code obtenu
    if (barcode.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Scan annulé ou code vide.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    debugPrint('[Scanner] EAN reçu : $barcode');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Code scanné : $barcode'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    }

    // 3. Navigation immédiate vers la fiche produit
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductPage(barcode: barcode)),
      );
    }

    // 4. Traitement en arrière-plan (API + BDD)
    if (_processing) return;
    if (mounted) setState(() => _processing = true);

    try {
      final scanRecord = await ProductService().processScan(barcode);
      if (mounted) context.read<ScanService>().addScan(scanRecord);
    } catch (e) {
      debugPrint('[HomePage] Erreur traitement scan : $e');
      // L'UX n'est pas bloquée, la fiche est déjà ouverte
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

  // ── AppBar commune ───────────────────────────────────────────────

  AppBar _buildAppBar({required bool hasScans, required String title}) {
    return AppBar(
      title: Text(title),
      centerTitle: false,
      automaticallyImplyLeading: false,
      actions: [
        // Icône scanner : toujours présente, désactivée si traitement en cours
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Padding(
                padding: EdgeInsetsDirectional.only(end: 4),
                child: Icon(AppIcons.barcode),
              ),
              onPressed: _processing ? null : _openScanner,
              tooltip: 'Scanner un produit',
            ),
            if (_processing)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.star_outline),
          onPressed: () => Navigator.pushNamed(context, '/favorites'),
          tooltip: 'Mes favoris',
        ),
        IconButton(
          icon: const Icon(Icons.exit_to_app),
          onPressed: _logout,
          tooltip: 'Se déconnecter',
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ── Build ───────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final scanService   = context.watch<ScanService>();

    // ── Chargement initial ──────────────────────────────────────
    if (scanService.isLoading) {
      return Scaffold(
        appBar: _buildAppBar(
          hasScans: false,
          title: localizations.my_scans_screen_title,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // ── Historique vide → écran vide ─────────────────────────────
    if (!scanService.hasScans) {
      return Scaffold(
        appBar: _buildAppBar(
          hasScans: false,
          title: localizations.my_scans_screen_title,
        ),
        body: HomePageEmpty(onScan: _openScanner),
      );
    }

    // ── Scans existants → historique ─────────────────────────────
    // HomePageHistoryScreen gère son propre corps (liste des scans).
    // On lui passe showAppBar: false et on wrappe dans un Scaffold
    // pour contrôler l'AppBar depuis ici (avec le bon _openScanner).
    return Scaffold(
      appBar: _buildAppBar(
        hasScans: true,
        title: localizations.my_scans_screen_title,
      ),
      body: HomePageHistoryScreen(
        showAppBar: false,
        onScan: _openScanner,
      ),
    );
  }
}
