import 'package:flutter/material.dart';
import 'package:formation_flutter/model/product_old.dart';
import 'package:provider/provider.dart';

enum NutrientLevel { low, moderate, high, unknown }

class ProductTab2 extends StatelessWidget {
  const ProductTab2({super.key});

  Color _getColorForLevel(NutrientLevel level) {
    switch (level) {
      case NutrientLevel.low:
        return const Color(0xFF4CAF50); // Vert
      case NutrientLevel.moderate:
        return const Color(0xFFFFB300); // Orange
      case NutrientLevel.high:
        return const Color(0xFFD32F2F); // Rouge
      case NutrientLevel.unknown:
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = context.read<ProductOld>();

    // On va chercher les données exactement là où elles sont dans votre modèle Product
    final facts = product.nutritionFacts;
    final levels = product.nutrientLevels;

    final fat = facts?.fat?.per100g;
    final fatLevel = levels?.fat;
    final saturatedFat = facts?.saturatedFat?.per100g;
    final saturatedFatLevel = levels?.saturatedFat;
    final sugars = facts?.sugar?.per100g; // 'sugar' dans NutritionFacts
    final sugarsLevel = levels?.sugars; // 'sugars' dans NutrientLevels
    final salt = facts?.salt?.per100g;
    final saltLevel = levels?.salt;

    final nutrientsData = [
      _buildNutrientData('Matières grasses / lipides', fat, fatLevel),
      _buildNutrientData(
        'Acides gras saturés',
        saturatedFat,
        saturatedFatLevel,
      ),
      _buildNutrientData('Sucres', sugars, sugarsLevel),
      _buildNutrientData('Sel', salt, saltLevel),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 24.0),
            child: Text(
              'Repères nutritionnels pour 100g',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          ...nutrientsData.map(
            (nut) => Column(
              children: [
                _buildNutritionRow(
                  nut['name'] as String,
                  nut['amount'] as String,
                  nut['level'] as NutrientLevel,
                  nut['levelText'] as String,
                ),
                const Divider(height: 30, color: Color(0xFFEEEEEE)),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Map<String, dynamic> _buildNutrientData(
    String name,
    dynamic amount,
    dynamic levelEnum,
  ) {
    // Gère la quantité d'affichage
    String amountStr = (amount != null && amount.toString().isNotEmpty)
        ? '${amount}g'
        : '?';

    // Gère la traduction du niveau en texte lisible
    NutrientLevel level = NutrientLevel.unknown;
    String levelText = 'Inconnu';

    final levelStr = levelEnum?.toString().toLowerCase() ?? '';
    if (levelStr.contains('low') || levelStr.contains('faible')) {
      level = NutrientLevel.low;
      levelText = 'Faible quantité';
    } else if (levelStr.contains('moderate') || levelStr.contains('modérée')) {
      level = NutrientLevel.moderate;
      levelText = 'Quantité modérée';
    } else if (levelStr.contains('high') || levelStr.contains('élevée')) {
      level = NutrientLevel.high;
      levelText = 'Quantité élevée';
    }

    return {
      'name': name,
      'amount': amountStr,
      'level': level,
      'levelText': levelText,
    };
  }

  Widget _buildNutritionRow(
    String name,
    String amount,
    NutrientLevel level,
    String levelText,
  ) {
    final color = _getColorForLevel(level);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF001F5B),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              amount,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: color,
              ),
            ),
            Text(levelText, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      ],
    );
  }
}
