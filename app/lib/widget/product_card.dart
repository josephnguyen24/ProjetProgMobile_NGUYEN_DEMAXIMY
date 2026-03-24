import 'package:flutter/material.dart';
import 'package:formation_flutter/model/product_model.dart';
import 'package:formation_flutter/res/app_colors.dart';
import 'package:formation_flutter/screens/product/product_page.dart';

/// Carte produit réutilisable dans l'historique et les favoris.
///
/// Version unifiée basée sur ProductModel.
/// Supporte :
class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final String? subtitle;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.subtitle,
  });

  Color _getNutriscoreColor(String score) {
    switch (score.toUpperCase()) {
      case 'A':
        return const Color(0xFF038141);
      case 'B':
        return const Color(0xFF85BB2F);
      case 'C':
        return const Color(0xFFFECB02);
      case 'D':
        return const Color(0xFFEE8100);
      case 'E':
        return const Color(0xFFE63E11);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ??
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ProductPage(barcode: product.barcode),
              ),
            );
          },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // ─── Image ───────────────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: product.imageUrl.isNotEmpty
                  ? Image.network(
                      product.imageUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),

            const SizedBox(width: 16),

            // ─── Infos ───────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    product.name.isNotEmpty
                        ? product.name
                        : product.barcode,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF001F5B),
                    ),
                  ),

                  const SizedBox(height: 4),

                  if (product.brand.isNotEmpty)
                    Text(
                      product.brand,
                      style:
                          const TextStyle(fontSize: 14, color: Colors.grey),
                    ),

                  // ─── Subtitle (ex: date scan) ────────────────
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color:
                              _getNutriscoreColor(product.nutriscore),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        product.nutriscore.isNotEmpty
                            ? 'Nutriscore : ${product.nutriscore}'
                            : 'Nutriscore inconnu',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 100,
      height: 100,
      color: AppColors.grey1,
      child: const Icon(Icons.fastfood_outlined, color: AppColors.grey2),
    );
  }
}