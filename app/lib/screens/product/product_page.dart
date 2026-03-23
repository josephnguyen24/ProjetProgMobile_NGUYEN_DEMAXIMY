import 'package:flutter/material.dart';
import 'package:formation_flutter/res/app_icons.dart';
import 'package:formation_flutter/screens/product/product_fetcher.dart';
import 'package:formation_flutter/screens/product/states/empty/product_page_empty.dart';
import 'package:formation_flutter/screens/product/states/error/product_page_error.dart';
import 'package:formation_flutter/screens/product/states/success/product_page_body.dart';
import 'package:formation_flutter/screens/product/states/success/recall_banner.dart';
import 'package:formation_flutter/screens/rappel/rappel_detail_screen.dart';
import 'package:formation_flutter/services/favorite_service.dart';
import 'package:provider/provider.dart';

class ProductPage extends StatefulWidget {
  final String barcode;

  const ProductPage({super.key, required this.barcode});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  int _currentIndex = 0;
  bool _isFavorite = false; // Gère l'état de l'étoile

  @override
  Widget build(BuildContext context) {
    final MaterialLocalizations mat = MaterialLocalizations.of(context);

    return MultiProvider(
      providers: [
        // Fetcher produit OpenFoodFacts
        ChangeNotifierProvider<ProductFetcher>(
          create: (_) => ProductFetcher(barcode: widget.barcode),
        ),
        // 3️⃣ Fetcher rappel PocketBase
        ChangeNotifierProvider<RappelFetcher>(
          create: (_) => RappelFetcher(barcode: widget.barcode),
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.info_outline),
              label: 'Fiche',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt),
              label: 'Caractéristiques',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.eco_outlined),
              label: 'Nutrition',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_on),
              label: 'Tableau',
            ),
          ],
        ),
        body: Stack(
          children: [
            // ── Corps principal ──────────────────────────────
            Consumer<ProductFetcher>(
              builder: (BuildContext context, ProductFetcher notifier, _) {
                return switch (notifier.state) {
                  ProductFetcherLoading() => const ProductPageEmpty(),
                  ProductFetcherError(error: var err) => _buildErrorView(
                    context,
                    err,
                  ),
                  // On passe l'onglet actuel au corps de la page !
                  ProductFetcherSuccess() => ProductPageBody(
                    currentIndex: _currentIndex,
                  ),
                };
              },
            ),
            PositionedDirectional(
              top: 0.0,
              start: 0.0,
              child: _HeaderIcon(
                icon: AppIcons.close,
                tooltip: mat.closeButtonTooltip,
                onPressed: Navigator.of(context).pop,
              ),
            ),

            // ── Bouton Favori / étoile (haut droite) ─────────
            PositionedDirectional(
              top: 0.0,
              end: 0.0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _HeaderIcon(
                    icon: _isFavorite ? Icons.star : Icons.star_border,
                    tooltip: 'Favoris',
                    onPressed: () => setState(() => _isFavorite = !_isFavorite),
                  ),
                  _HeaderIcon(
                    icon: AppIcons.share,
                    tooltip: materialLocalizations.shareButtonLabel,
                  ),
                ],
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

// ── Bouton étoile (favori) ───────────────────────────────────────

class _StarIcon extends StatelessWidget {
  const _StarIcon({required this.barcode});

  final String barcode;

  @override
  Widget build(BuildContext context) {
    final favService = context.watch<FavoriteService>();
    final isFav = favService.isFavorite(barcode);

    // Récupère le nom et l'image du produit depuis le fetcher (si chargé)
    String? productName;
    String? productImage;
    final state = context.watch<ProductFetcher>().state;
    if (state is ProductFetcherSuccess) {
      productName  = state.product.name;
      productImage = state.product.picture;
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(8.0),
        child: Material(
          type: MaterialType.transparency,
          child: Tooltip(
            message: isFav ? 'Retirer des favoris' : 'Ajouter aux favoris',
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => context.read<FavoriteService>().toggle(
                barcode,
                productName:  productName,
                productImage: productImage,
              ),
              child: Ink(
                padding: const EdgeInsetsDirectional.all(12.0),
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10.0,
                      ),
                    ],
                  ),
                  child: Icon(
                    isFav ? Icons.star : Icons.star_outline,
                    color: isFav ? const Color(0xFFFDB912) : Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Bouton générique en overlay ──────────────────────────────────

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({
    required this.icon,
    required this.tooltip,
    this.onPressed,
  }) : assert(tooltip.length > 0);

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
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10.0,
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
