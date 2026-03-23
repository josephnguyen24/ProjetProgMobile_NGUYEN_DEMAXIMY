import 'package:flutter/material.dart';
import 'package:formation_flutter/res/app_colors.dart';

/// Carte produit réutilisable dans l'historique et les favoris.
///
/// Fournissez [barcode], [productName] et optionnellement [productImage].
/// [onTap] est appelé quand l'utilisateur tape sur la carte.
/// [trailing] permet d'ajouter un widget en fin de ligne (ex: bouton étoile).
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.barcode,
    this.productName,
    this.productImage,
    this.subtitle,
    this.onTap,
    this.trailing,
  });

  final String barcode;
  final String? productName;
  final String? productImage;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // ── Image ───────────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: productImage != null && productImage!.isNotEmpty
                      ? Image.network(
                          productImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder(),
                        )
                      : _placeholder(),
                ),
              ),
              const SizedBox(width: 14),

              // ── Texte ────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName ?? barcode,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blue,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.grey3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // ── Trailing (étoile, chevron…) ──────────────────
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ] else
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.grey2,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.grey1,
      child: const Icon(Icons.fastfood_outlined, color: AppColors.grey2),
    );
  }
}