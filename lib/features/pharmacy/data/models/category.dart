class PharmacyCategory {
  final int id;
  final String name;
  final String? description;
  final String? type;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PharmacyCategory({
    required this.id,
    required this.name,
    this.description,
    this.type,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory PharmacyCategory.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    return PharmacyCategory(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      type: json['type']?.toString(),
      isActive: json['is_active'] ?? true,
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }
}
