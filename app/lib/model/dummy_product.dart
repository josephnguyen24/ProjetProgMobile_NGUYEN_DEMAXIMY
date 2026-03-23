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
    barcode: '123456789',
    name: 'Petits pois et carottes',
    brand: 'Cassegrain',
    imageUrl:
        'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80',
    nutriscore: 'A',
    isFavorite: true,
  ),
  DummyProduct(
    id: '2',
    barcode: '987654321',
    name: 'Pâtes',
    brand: 'Panzani',
    imageUrl:
        'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80',
    nutriscore: 'C',
    isFavorite: false,
  ),
  DummyProduct(
    id: '3',
    barcode: '456123789',
    name: 'Sauce Tomate',
    brand: 'Heinz',
    imageUrl:
        'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80',
    nutriscore: 'D',
    isFavorite: true,
  ),
];
