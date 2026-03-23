import 'package:flutter/material.dart';
import 'package:formation_flutter/model/dummy_product.dart';
import 'package:formation_flutter/widget/product_card.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // On filtre la liste pour ne garder que les favoris
    final favoriteProducts = dummyProducts.where((p) => p.isFavorite).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Mes favoris')),
      body: favoriteProducts.isEmpty
          ? const Center(child: Text('Aucun favori pour le moment.'))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: favoriteProducts.length,
              itemBuilder: (context, index) {
                return ProductCard(product: favoriteProducts[index]);
              },
            ),
    );
  }
}
