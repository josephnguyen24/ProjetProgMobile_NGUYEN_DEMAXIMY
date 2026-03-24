import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:formation_flutter/widget/product_card.dart';
import 'package:formation_flutter/model/favorite_record.dart';
import 'package:formation_flutter/model/product_model.dart';
import 'package:formation_flutter/services/favorite_service.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoriteService>().favorites;

    return Scaffold(
      appBar: AppBar(title: const Text('Mes favoris')),
      body: favorites.isEmpty
          ? const Center(child: Text('Aucun favori pour le moment.'))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final fav = favorites[index];

                final product = ProductModel(
                  id: fav.id,
                  barcode: fav.barcode,
                  name: fav.productName ?? '',
                  brand: '',
                  imageUrl: fav.productImage ?? '',
                  nutriscore: 'unknown',
                );

                return ProductCard(product: product);
              },
            ),
    );
  }
}