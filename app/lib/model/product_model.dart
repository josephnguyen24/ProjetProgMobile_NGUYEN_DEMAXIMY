import 'package:pocketbase/pocketbase.dart';

/// Modèle simplifié d'un produit alimentaire,
/// utilisé par le dashboard (historique, favoris, cartes).
///
/// Distinct du modèle riche [Product] (lib/model/product.dart)
/// utilisé par la fiche détaillée OpenFoodFacts.
class ProductModel {
  const ProductModel({
    required this.id,
    required this.barcode,
    required this.name,
    this.brand = '',
    this.imageUrl = '',
    this.nutriscore = '',
  });

  /// ID PocketBase (vide si non encore persisté)
  final String id;
  final String barcode;
  final String name;
  final String brand;
  final String imageUrl;
  final String nutriscore;

  /// Depuis un enregistrement PocketBase (collection `products`)
  factory ProductModel.fromRecord(RecordModel r) {
    return ProductModel(
      id:        r.id,
      barcode:   r.getStringValue('barcode'),
      name:      r.getStringValue('name'),
      brand:     r.getStringValue('brand'),
      imageUrl:  r.getStringValue('image_url'),
      nutriscore: r.getStringValue('nutriscore'),
    );
  }

  /// Depuis la réponse de l'API OpenFoodFacts (modèle riche)
  /// Permet de créer un ProductModel à partir du Product existant.
  factory ProductModel.fromApiResponse({
    required String barcode,
    required String name,
    required String brand,
    required String imageUrl,
    required String nutriscore,
  }) {
    return ProductModel(
      id:        '',
      barcode:   barcode,
      name:      name,
      brand:     brand,
      imageUrl:  imageUrl,
      nutriscore: nutriscore,
    );
  }
}

// Données factices pour tester l'interface
final List<ProductModel> products = [
  ProductModel(
    id: '1',
    barcode: '3017620422003',
    name: 'Nutella',
    brand: 'Ferrero',
    imageUrl:
        'https://images.openfoodfacts.org/images/products/301/762/042/2003/front_fr.439.400.jpg',
    nutriscore: 'E',
  ),
  ProductModel(
    id: '2',
    barcode: '5449000000996',
    name: 'Coca-Cola',
    brand: 'Coca-Cola',
    imageUrl:
        'https://images.openfoodfacts.org/images/products/544/900/000/0996/front_fr.200.400.jpg',
    nutriscore: 'E',
  ),
  ProductModel(
    id: '3',
    barcode: '3274080005003',
    name: 'Eau de source',
    brand: 'Cristaline',
    imageUrl:
        'https://images.openfoodfacts.org/images/products/327/408/000/5003/front_fr.943.400.jpg',
    nutriscore: 'B',
  ),
  ProductModel(
    id: '4',
    barcode: '3383883752028',
    name: 'Ballotine pintade aux cèpes',
    brand: 'Leguelier',
    imageUrl:
        'https://rappel.conso.gouv.fr/image/3df84c8a-4c98-476c-b44f-7d6ffb7ace01.jpg',
    nutriscore: 'E',
  ),
  ProductModel(
    id: '5',
    barcode: '4056489195207',
    name: 'Salade pâte jambon emmental',
    brand: 'Select & Go',
    imageUrl:
        'https://rappel.conso.gouv.fr/image/07a87502-1268-4ee2-8b10-f588b12f38ac.jpg',
    nutriscore: 'C',
  ),
];
