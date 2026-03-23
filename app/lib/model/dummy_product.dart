class DummyProduct {
  final String id; // L'ID généré par PocketBase plus tard
  final String barcode;
  final String name;
  final String brand;
  final String imageUrl;
  final String nutriscore;
  final bool isFavorite;

  DummyProduct({
    required this.id,
    required this.barcode,
    required this.name,
    required this.brand,
    required this.imageUrl,
    required this.nutriscore,
    this.isFavorite = false,
  });
}

// Données factices pour tester l'interface
final List<DummyProduct> dummyProducts = [
  DummyProduct(
    id: '1',
    barcode: '3017620422003',
    name: 'Nutella',
    brand: 'Ferrero',
    imageUrl:
        'https://images.openfoodfacts.org/images/products/301/762/042/2003/front_fr.439.400.jpg',
    nutriscore: 'E',
    isFavorite: true,
  ),
  DummyProduct(
    id: '2',
    barcode: '5449000000996',
    name: 'Coca-Cola',
    brand: 'Coca-Cola',
    imageUrl:
        'https://images.openfoodfacts.org/images/products/544/900/000/0996/front_fr.200.400.jpg',
    nutriscore: 'E',
    isFavorite: false,
  ),
  DummyProduct(
    id: '3',
    barcode: '3274080005003',
    name: 'Eau de source',
    brand: 'Cristaline',
    imageUrl:
        'https://images.openfoodfacts.org/images/products/327/408/000/5003/front_fr.943.400.jpg',
    nutriscore: 'B',
    isFavorite: true,
  ),
  DummyProduct(
    id: '4',
    barcode: '3383883752028',
    name: 'Ballotine pintade aux cèpes',
    brand: 'Leguelier',
    imageUrl:
        'https://rappel.conso.gouv.fr/image/3df84c8a-4c98-476c-b44f-7d6ffb7ace01.jpg',
    nutriscore: 'E',
    isFavorite: false,
  ),
];
