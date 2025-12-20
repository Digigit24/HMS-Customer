class Appointment {
  final String id;
  final String status;
  final DateTime? scheduledAt;
  final String? patientName;
  final String? doctorName;

  Appointment({
    required this.id,
    required this.status,
    this.scheduledAt,
    this.patientName,
    this.doctorName,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    // These keys may differ; adjust once we see real response
    final scheduled =
        json['scheduled_at'] ?? json['scheduledAt'] ?? json['date_time'];

    final patient = json['patient_name'] ??
        json['patient']?['full_name'] ??
        json['patient']?['name'];

    final doctor = json['doctor_name'] ??
        json['doctor']?['full_name'] ??
        json['doctor']?['name'];

    return Appointment(
      id: (json['id'] ?? '').toString(),
      status: (json['status'] ?? 'unknown').toString(),
      scheduledAt: parseDate(scheduled),
      patientName: patient?.toString(),
      doctorName: doctor?.toString(),
    );
  }
}
