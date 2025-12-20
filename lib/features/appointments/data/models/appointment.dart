class Appointment {
  final int id;
  final String? tenantId;
  final String? appointmentId;
  final String? appointmentDate;
  final String? appointmentTime;
  final String? endTime;
  final int? durationMinutes;
  final String status;
  final String? priority;
  final String? chiefComplaint;
  final String? symptoms;
  final String? notes;
  final bool? isFollowUp;
  final String? consultationFee;
  final DateTime? checkInTime;
  final DateTime? checkedInAt;
  final String? actualStartTime;
  final String? actualEndTime;
  final int? waitingTimeMinutes;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final DateTime? approvedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? visit;

  // Additional fields for UI
  final String? patientName;
  final String? doctorName;
  final String? doctorSpecialty;
  final String? doctorImage;

  Appointment({
    required this.id,
    this.tenantId,
    this.appointmentId,
    this.appointmentDate,
    this.appointmentTime,
    this.endTime,
    this.durationMinutes,
    required this.status,
    this.priority,
    this.chiefComplaint,
    this.symptoms,
    this.notes,
    this.isFollowUp,
    this.consultationFee,
    this.checkInTime,
    this.checkedInAt,
    this.actualStartTime,
    this.actualEndTime,
    this.waitingTimeMinutes,
    this.cancelledAt,
    this.cancellationReason,
    this.approvedAt,
    this.createdAt,
    this.updatedAt,
    this.visit,
    this.patientName,
    this.doctorName,
    this.doctorSpecialty,
    this.doctorImage,
  });

  DateTime? get scheduledAt {
    if (appointmentDate == null) return null;
    try {
      if (appointmentTime != null) {
        return DateTime.parse('$appointmentDate $appointmentTime');
      }
      return DateTime.parse(appointmentDate!);
    } catch (_) {
      return null;
    }
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    DateTime? parseDateTime(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    // Extract doctor info if nested
    final doctor = json['doctor'];
    final patient = json['patient'];

    return Appointment(
      id: json['id'] ?? 0,
      tenantId: json['tenant_id']?.toString(),
      appointmentId: json['appointment_id']?.toString(),
      appointmentDate: json['appointment_date']?.toString(),
      appointmentTime: json['appointment_time']?.toString(),
      endTime: json['end_time']?.toString(),
      durationMinutes: json['duration_minutes'],
      status: json['status'] ?? 'unknown',
      priority: json['priority']?.toString(),
      chiefComplaint: json['chief_complaint']?.toString(),
      symptoms: json['symptoms']?.toString(),
      notes: json['notes']?.toString(),
      isFollowUp: json['is_follow_up'],
      consultationFee: json['consultation_fee']?.toString(),
      checkInTime: parseDateTime(json['check_in_time']),
      checkedInAt: parseDateTime(json['checked_in_at']),
      actualStartTime: json['actual_start_time']?.toString(),
      actualEndTime: json['actual_end_time']?.toString(),
      waitingTimeMinutes: json['waiting_time_minutes'],
      cancelledAt: parseDateTime(json['cancelled_at']),
      cancellationReason: json['cancellation_reason']?.toString(),
      approvedAt: parseDateTime(json['approved_at']),
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
      visit: json['visit'],
      patientName: patient?['name'] ?? patient?['full_name'],
      doctorName: doctor?['name'] ?? doctor?['full_name'],
      doctorSpecialty: doctor?['specialty'] ?? doctor?['specialization'],
      doctorImage: doctor?['image'] ?? doctor?['photo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'appointment_id': appointmentId,
      'appointment_date': appointmentDate,
      'appointment_time': appointmentTime,
      'end_time': endTime,
      'duration_minutes': durationMinutes,
      'status': status,
      'priority': priority,
      'chief_complaint': chiefComplaint,
      'symptoms': symptoms,
      'notes': notes,
      'is_follow_up': isFollowUp,
      'consultation_fee': consultationFee,
      'check_in_time': checkInTime?.toIso8601String(),
      'checked_in_at': checkedInAt?.toIso8601String(),
      'actual_start_time': actualStartTime,
      'actual_end_time': actualEndTime,
      'waiting_time_minutes': waitingTimeMinutes,
      'cancelled_at': cancelledAt?.toIso8601String(),
      'cancellation_reason': cancellationReason,
      'approved_at': approvedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'visit': visit,
    };
  }
}
