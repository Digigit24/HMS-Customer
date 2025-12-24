class Doctor {
  final int id;
  final String name;
  final String? specialty;
  final String? image;

  Doctor({
    required this.id,
    required this.name,
    this.specialty,
    this.image,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    final doctor = json['doctor'];
    if (doctor is Map<String, dynamic>) {
      return Doctor.fromJson(doctor);
    }

    return Doctor(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ??
          json['full_name']?.toString() ??
          'Doctor',
      specialty: json['specialty']?.toString() ??
          json['specialization']?.toString(),
      image: json['image']?.toString() ?? json['photo']?.toString(),
    );
  }
}
