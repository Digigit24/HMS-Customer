import 'cart.dart';

class PharmacyOrder {
  final int id;
  final String? status;
  final double totalAmount;
  final int totalItems;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<PharmacyCartItem> items;

  PharmacyOrder({
    required this.id,
    this.status,
    this.totalAmount = 0,
    this.totalItems = 0,
    this.createdAt,
    this.updatedAt,
    this.items = const [],
  });

  factory PharmacyOrder.fromJson(Map<String, dynamic> json) {
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

    return PharmacyOrder(
      id: json['id'] ?? 0,
      status: json['status']?.toString(),
      totalAmount: parseDouble(json['total_amount']),
      totalItems: json['total_items'] ?? items.fold<int>(0, (p, e) => p + e.quantity),
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
      items: items,
    );
  }
}
