import 'package:flutter/material.dart';
import 'package:formation_flutter/res/app_icons.dart';
import 'package:formation_flutter/screens/product/product_fetcher.dart';
import 'package:formation_flutter/screens/product/states/empty/product_page_empty.dart';
import 'package:formation_flutter/screens/product/states/error/product_page_error.dart';
import 'package:formation_flutter/screens/product/states/success/product_page_body.dart';
import 'package:formation_flutter/services/favorite_service.dart';
import 'package:provider/provider.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({super.key, this.barcode = '5000159484695'});

  /// Code-barres du produit à afficher.
  /// Valeur par défaut conservée pour la compatibilité lors des tests.
  final String barcode;

  @override
  Widget build(BuildContext context) {
    final MaterialLocalizations mat = MaterialLocalizations.of(context);

    return ChangeNotifierProvider<ProductFetcher>(
      create: (_) => ProductFetcher(barcode: barcode),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // ── Corps principal ──────────────────────────────
            Consumer<ProductFetcher>(
              builder: (_, notifier, __) => switch (notifier.state) {
                ProductFetcherLoading()              => const ProductPageEmpty(),
                ProductFetcherError(error: var err) => ProductPageError(error: err),
                ProductFetcherSuccess()              => ProductPageBody(),
              },
            ),

            // ── Bouton Fermer (haut gauche) ──────────────────
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
              child: _StarIcon(barcode: barcode),
            ),
          ],
        ),
      ),
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