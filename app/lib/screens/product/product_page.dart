import 'package:flutter/material.dart';
import 'package:formation_flutter/res/app_icons.dart';
import 'package:formation_flutter/screens/product/product_fetcher.dart';
import 'package:formation_flutter/screens/product/rappel_fetcher.dart';
import 'package:formation_flutter/screens/product/states/empty/product_page_empty.dart';
import 'package:formation_flutter/screens/product/states/error/product_page_error.dart';
import 'package:formation_flutter/screens/product/states/success/product_page_body.dart';
import 'package:formation_flutter/screens/product/states/success/recall_banner.dart';
import 'package:formation_flutter/screens/rappel/rappel_detail_screen.dart';
import 'package:provider/provider.dart';

class ProductPage extends StatelessWidget {
  final String barcode;

  const ProductPage({super.key, required this.barcode});

  @override
  Widget build(BuildContext context) {
    final MaterialLocalizations materialLocalizations =
        MaterialLocalizations.of(context);

    return MultiProvider(
      providers: [
        // Fetcher produit OpenFoodFacts
        ChangeNotifierProvider<ProductFetcher>(
          create: (_) => ProductFetcher(barcode: barcode),
        ),
        // 3️⃣ Fetcher rappel PocketBase
        ChangeNotifierProvider<RappelFetcher>(
          create: (_) => RappelFetcher(barcode: barcode),
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Consumer<ProductFetcher>(
              builder: (BuildContext context, ProductFetcher notifier, _) {
                return switch (notifier.state) {
                  ProductFetcherLoading() => const ProductPageEmpty(),
                  ProductFetcherError(error: var err) => _buildErrorView(
                    context,
                    err,
                  ),
                  ProductFetcherSuccess() => ProductPageBody(),
                };
              },
            ),
            PositionedDirectional(
              top: 0.0,
              start: 0.0,
              child: _HeaderIcon(
                icon: AppIcons.close,
                tooltip: materialLocalizations.closeButtonTooltip,
                onPressed: Navigator.of(context).pop,
              ),
            ),
            PositionedDirectional(
              top: 0.0,
              end: 0.0,
              child: _HeaderIcon(
                icon: AppIcons.share,
                tooltip: materialLocalizations.shareButtonLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, dynamic err) {
    final errorString = err.toString();
    String friendlyMessage =
        "Une erreur est survenue lors du chargement du produit.";

    if (errorString.contains('404')) {
      friendlyMessage =
          "Ce produit n'est pas répertorié dans la base OpenFoodFacts.";
    } else if (errorString.contains('XMLHttpRequest') ||
        errorString.contains('connection')) {
      friendlyMessage =
          "Erreur de connexion. Vérifiez que votre serveur PocketBase est bien lancé et accessible.";
    }

    return Column(
      children: [
        const SizedBox(height: 90), // Espace sous les boutons du haut
        // Bandeau de rappel toujours affiché si trouvé, même si le produit n'est pas sur OFF
        Consumer<RappelFetcher>(
          builder: (_, fetcher, __) {
            final state = fetcher.state;
            if (state is RappelFetcherFound) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          RappelDetailScreen(rappel: state.rappel),
                    ),
                  );
                },
                child: RecallBanner(rappel: state.rappel),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 20),
                  Text(
                    friendlyMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.icon, required this.tooltip, this.onPressed})
    : assert(tooltip.length > 0);

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(8.0),
        child: Material(
          type: MaterialType.transparency,
          child: Tooltip(
            message: tooltip,
            child: InkWell(
              onTap: onPressed ?? () {},
              customBorder: const CircleBorder(),
              child: Ink(
                padding: const EdgeInsetsDirectional.all(12.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.0),
                ),
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10.0,
                        offset: Offset(0.0, 0.0),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
