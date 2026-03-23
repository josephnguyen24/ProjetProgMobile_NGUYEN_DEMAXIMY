import 'package:pocketbase/pocketbase.dart';

/// Représente un produit mis en favori par l'utilisateur.
class FavoriteRecord {
  const FavoriteRecord({
    required this.id,
    required this.userId,
    required this.barcode,
    this.productName,
    this.productImage,
  });

  final String id;
  final String userId;
  final String barcode;
  final String? productName;
  final String? productImage;

  factory FavoriteRecord.fromRecord(RecordModel r) {
    return FavoriteRecord(
      id:           r.id,
      userId:       r.getStringValue('user_id'),
      barcode:      r.getStringValue('barcode'),
      productName:  r.getStringValue('product_name').nullIfEmpty,
      productImage: r.getStringValue('product_image').nullIfEmpty,
    );
  }
}

extension _StringExt on String {
  String? get nullIfEmpty => isEmpty ? null : this;
}