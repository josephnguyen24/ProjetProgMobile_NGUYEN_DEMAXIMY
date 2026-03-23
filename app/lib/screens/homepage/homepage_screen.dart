import 'package:flutter/material.dart';
import 'package:formation_flutter/l10n/app_localizations.dart';
import 'package:formation_flutter/res/app_icons.dart';
import 'package:formation_flutter/screens/homepage/homepage_empty.dart';
import 'package:formation_flutter/screens/homepage/homepage_history.dart';
import 'package:formation_flutter/services/auth_service.dart';
import 'package:formation_flutter/services/favorite_service.dart';
import 'package:formation_flutter/services/scan_service.dart';
import 'package:provider/provider.dart';

/// Écran principal du dashboard.
///
/// - Si aucun scan n'est enregistré → affiche [HomePageEmpty]
///   (le bouton "Commencer" navigue vers l'historique)
/// - Si des scans existent → affiche [HomePageHistoryScreen] directement
class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  @override
  void initState() {
    super.initState();
    // Charge les scans et les favoris au premier affichage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScanService>().load();
      context.read<FavoriteService>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final scanService = context.watch<ScanService>();

    // Pendant le chargement initial, affiche un spinner
    if (scanService.isLoading) {
      return Scaffold(
        appBar: _buildAppBar(localizations, hasScans: false),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Si des scans existent → on affiche directement l'historique
    if (scanService.hasScans) {
      return HomePageHistoryScreen(showAppBar: true);
    }

    // Sinon → écran vide
    return Scaffold(
      appBar: _buildAppBar(localizations, hasScans: false),
      body: HomePageEmpty(
        onScan: () => Navigator.pushNamed(context, '/history'),
      ),
    );
  }

  AppBar _buildAppBar(AppLocalizations loc, {required bool hasScans}) {
    return AppBar(
      title: Text(loc.my_scans_screen_title),
      centerTitle: false,
      automaticallyImplyLeading: false,
      actions: [
        if (hasScans)
          IconButton(
            onPressed: () {},
            icon: const Padding(
              padding: EdgeInsetsDirectional.only(end: 4),
              child: Icon(AppIcons.barcode),
            ),
          ),
        IconButton(
          icon: const Icon(Icons.star_outline),
          onPressed: () => Navigator.pushNamed(context, '/favorites'),
          tooltip: 'Mes favoris',
        ),
        IconButton(
          icon: const Icon(Icons.exit_to_app),
          onPressed: () => _logout(context),
          tooltip: 'Se déconnecter',
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  void _logout(BuildContext context) {
    context.read<AuthService>().logout();
    context.read<ScanService>().clear();
    context.read<FavoriteService>().clear();
    Navigator.pushReplacementNamed(context, '/login');
  }
}