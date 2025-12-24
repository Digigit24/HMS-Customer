import 'product.dart';

class PharmacyCartItem {
  final int id;
  final PharmacyProduct product;
  final int quantity;
  final double? priceAtTime;
  final double? totalPrice;

  PharmacyCartItem({
    required this.id,
    required this.product,
    required this.quantity,
    this.priceAtTime,
    this.totalPrice,
  });

  factory PharmacyCartItem.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic v) {
      if (v == null) return null;
      return double.tryParse(v.toString());
    }

    return PharmacyCartItem(
      id: json['id'] ?? 0,
      product: PharmacyProduct.fromJson(
        Map<String, dynamic>.from(json['product'] ?? {}),
      ),
      quantity: json['quantity'] ?? 0,
      priceAtTime: parseDouble(json['price_at_time']),
      totalPrice: parseDouble(json['total_price']),
    );
  }
}

class PharmacyCart {
  final int id;
  final String? userId;
  final List<PharmacyCartItem> cartItems;
  final int totalItems;
  final double totalAmount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PharmacyCart({
    required this.id,
    required this.cartItems,
    this.userId,
    this.totalItems = 0,
    this.totalAmount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory PharmacyCart.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    double parseDouble(dynamic v) {
      if (v == null) return 0;
      return double.tryParse(v.toString()) ?? 0;
    }

    final items = <PharmacyCartItem>[];
    if (json['cart_items'] is List) {
      for (final item in json['cart_items']) {
        items.add(
          PharmacyCartItem.fromJson(Map<String, dynamic>.from(item)),
        );
      }
    }

    return PharmacyCart(
      id: json['id'] ?? 0,
      userId: json['user_id']?.toString(),
      cartItems: items,
      totalItems: json['total_items'] ?? items.fold<int>(0, (p, e) => p + e.quantity),
      totalAmount: parseDouble(json['total_amount']),
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }
}
