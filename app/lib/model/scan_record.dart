import 'package:pocketbase/pocketbase.dart';

/// Représente un scan produit enregistré en base.
class ScanRecord {
  const ScanRecord({
    required this.id,
    required this.userId,
    required this.barcode,
    this.productName,
    this.productImage,
    required this.created,
  });

  final String id;
  final String userId;
  final String barcode;
  final String? productName;
  final String? productImage;
  final DateTime created;

  factory ScanRecord.fromRecord(RecordModel r) {
    return ScanRecord(
      id:           r.id,
      userId:       r.getStringValue('user_id'),
      barcode:      r.getStringValue('barcode'),
      productName:  r.getStringValue('product_name').nullIfEmpty,
      productImage: r.getStringValue('product_image').nullIfEmpty,
      created:      DateTime.tryParse(r.created) ?? DateTime.now(),
    );
  }
}

extension _StringExt on String {
  String? get nullIfEmpty => isEmpty ? null : this;
}