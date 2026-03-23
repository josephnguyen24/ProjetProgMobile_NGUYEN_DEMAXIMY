import 'package:flutter/material.dart';
import 'package:formation_flutter/model/product.dart';
import 'package:provider/provider.dart';

class ProductTab1 extends StatelessWidget {
  const ProductTab1({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. On récupère le vrai produit depuis l'API via le Provider
    final product = context.read<Product>();

    // On utilise directement les bons types définis dans le modèle Product
    final List<String> ingredients = product.ingredients ?? [];
    final List<String> allergens = product.allergens ?? [];
    final Map<String, String> additives = product.additives ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader('Ingrédients'),
        if (ingredients.isEmpty)
          _buildSimpleTextRow('Aucun ingrédient spécifié'),
        ...ingredients.map((ing) => _buildIngredientRow(ing, '')),

        _buildSectionHeader('Substances allergènes'),
        if (allergens.isEmpty) _buildSimpleTextRow('Aucune'),
        ...allergens.map((all) => _buildSimpleTextRow(all)),

        _buildSectionHeader('Additifs'),
        if (additives.isEmpty) _buildSimpleTextRow('Aucun'),
        // Pour un Map, on itère sur les entrées (clés/valeurs)
        ...additives.entries.map(
          (add) =>
              _buildSimpleTextRow('${add.key.toUpperCase()} : ${add.value}'),
        ),

        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      color: const Color(0xFFF3F5F9), // Gris/Bleu très clair
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF001F5B), // Harmonisé avec votre application
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildIngredientRow(String name, String details) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF001F5B),
              ),
            ),
          ),
          if (details.isNotEmpty)
            Expanded(
              flex: 3,
              child: Text(
                details,
                textAlign: TextAlign.right,
                style: const TextStyle(color: Colors.black54),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSimpleTextRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Text(text, style: const TextStyle(color: Color(0xFF001F5B))),
    );
  }
}
