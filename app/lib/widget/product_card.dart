import 'package:flutter/material.dart';
import 'package:formation_flutter/model/dummy_product.dart';

class ProductCard extends StatelessWidget {
  final DummyProduct product;

  const ProductCard({super.key, required this.product});

  Color _getNutriscoreColor(String score) {
    switch (score.toUpperCase()) {
      case 'A':
        return const Color(0xFF008B45); // Vert foncé
      case 'B':
        return const Color(0xFF85C441); // Vert clair
      case 'C':
        return const Color(0xFFFFC107); // Jaune
      case 'D':
        return const Color(0xFFFF8C00); // Orange
      case 'E':
        return const Color(0xFFE53935); // Rouge
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          // Image du produit
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            child: Image.network(
              product.imageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          // Informations du produit
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF001F5B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.brand,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getNutriscoreColor(product.nutriscore),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Nutriscore : ${product.nutriscore}',
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
    );
  }
}
