import 'category.dart';

class PharmacyProduct {
  final int id;
  final String productName;
  final PharmacyCategory? category;
  final String? imageUrl;
  final String? company;
  final String? batchNo;
  final double? mrp;
  final double? sellingPrice;
  final int? quantity;
  final int? minimumStockLevel;
  final DateTime? expiryDate;
  final bool isActive;
  final bool isInStock;
  final bool lowStockWarning;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PharmacyProduct({
    required this.id,
    required this.productName,
    this.category,
    this.imageUrl,
    this.company,
    this.batchNo,
    this.mrp,
    this.sellingPrice,
    this.quantity,
    this.minimumStockLevel,
    this.expiryDate,
    this.isActive = true,
    this.isInStock = true,
    this.lowStockWarning = false,
    this.createdAt,
    this.updatedAt,
  });

  factory PharmacyProduct.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    double? parseDouble(dynamic v) {
      if (v == null) return null;
      return double.tryParse(v.toString());
    }

    return PharmacyProduct(
      id: json['id'] ?? 0,
      productName: json['product_name']?.toString() ?? 'Product',
      category: json['category'] is Map<String, dynamic>
          ? PharmacyCategory.fromJson(
              Map<String, dynamic>.from(json['category']),
            )
          : null,
      imageUrl: json['image']?.toString() ??
          json['image_url']?.toString() ??
          json['photo']?.toString() ??
          json['thumbnail']?.toString(),
      company: json['company']?.toString(),
      batchNo: json['batch_no']?.toString(),
      mrp: parseDouble(json['mrp']),
      sellingPrice: parseDouble(json['selling_price']),
      quantity: json['quantity'],
      minimumStockLevel: json['minimum_stock_level'],
      expiryDate: parseDate(json['expiry_date']),
      isActive: json['is_active'] ?? true,
      isInStock: json['is_in_stock'] ?? true,
      lowStockWarning: json['low_stock_warning'] ?? false,
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }
}
