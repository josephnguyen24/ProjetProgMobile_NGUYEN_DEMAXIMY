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
/// Peut être affiché avec ou sans AppBar propre ([showAppBar]).
/// Lorsque [showAppBar] est false, l'AppBar doit être fournie par le parent.
class HomePageHistoryScreen extends StatelessWidget {
  const HomePageHistoryScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final scanService = context.watch<ScanService>();
    final scans = scanService.scans;
    final dateFormat = DateFormat('dd/MM/yyyy', 'fr_FR');

    Widget body;

    if (scanService.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (scans.isEmpty) {
      body = HomePageEmpty(
        onScan: () {
          // TODO: action scan si besoin
        },
      );
    } else {
      body = ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: scans.length,
        itemBuilder: (context, index) {
          final scan = scans[index];

          final product = ProductModel(
            id: scan.id ?? '',
            barcode: scan.barcode,
            name: scan.productName ?? '',
            brand: '',
            imageUrl: scan.productImage ?? '',
            nutriscore: 'unknown',
          );

          return ProductCard(product: product);
        },
      );
    }

    if (!showAppBar) return body;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.my_scans_screen_title),
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {},
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