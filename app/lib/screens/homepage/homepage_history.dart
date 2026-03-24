import 'package:flutter/material.dart';
import 'package:formation_flutter/l10n/app_localizations.dart';
import 'package:formation_flutter/res/app_icons.dart';
import 'package:formation_flutter/screens/product/product_page.dart';
import 'package:formation_flutter/screens/homepage/homepage_empty.dart';
import 'package:formation_flutter/services/auth_service.dart';
import 'package:formation_flutter/services/favorite_service.dart';
import 'package:formation_flutter/services/scan_service.dart';
import 'package:formation_flutter/widget/product_card.dart';
import 'package:formation_flutter/model/product_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Écran d'historique des scans, trié du plus récent au plus ancien.
///
/// [showAppBar] : si false, pas de Scaffold ni AppBar propre.
///               Le parent (HomePage) fournit l'AppBar.
/// [onScan]    : callback pour le bouton scanner (fourni par HomePage).
class HomePageHistoryScreen extends StatelessWidget {
  const HomePageHistoryScreen({
    super.key,
    this.showAppBar = true,
    this.onScan,
  });

  final bool showAppBar;
  final VoidCallback? onScan;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final scanService   = context.watch<ScanService>();
    final scans         = scanService.scans;
    final dateFormat    = DateFormat('dd/MM/yyyy', 'fr_FR');

    Widget body;

    if (scanService.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (scans.isEmpty) {
      body = HomePageEmpty(onScan: onScan);
    } else {
      body = ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: scans.length,
        itemBuilder: (context, index) {
          final scan = scans[index];

          final product = ProductModel(
            id:        scan.id,
            barcode:   scan.barcode,
            name:      scan.productName ?? '',
            brand:     '',
            imageUrl:  scan.productImage ?? '',
            nutriscore: '',
          );

          return ProductCard(
            product: product,
            subtitle: 'Scanné le ${dateFormat.format(scan.created)}',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductPage(barcode: product.barcode),
              ),
            ),
          );
        },
      );
    }

    // Mode sans AppBar : utilisé quand HomePage wrap ce widget
    if (!showAppBar) return body;

    // Mode autonome (route /history directe)
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.my_scans_screen_title),
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: onScan,
            icon: const Padding(
              padding: EdgeInsetsDirectional.only(end: 4),
              child: Icon(AppIcons.barcode),
            ),
            tooltip: 'Scanner',
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
      ),
      body: body,
    );
  }

  void _logout(BuildContext context) {
    context.read<AuthService>().logout();
    context.read<ScanService>().clear();
    context.read<FavoriteService>().clear();
    Navigator.pushReplacementNamed(context, '/login');
  }
}