/// Razorpay Order Creation Request DTO
class RazorpayOrderRequest {
  final int patientId;
  final String servicesType;
  final int? appointmentId;
  final List<OrderItem> items;
  final List<OrderFee>? fees;
  final String? notes;

  RazorpayOrderRequest({
    required this.patientId,
    required this.servicesType,
    this.appointmentId,
    required this.items,
    this.fees,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'patient_id': patientId,
      'services_type': servicesType,
      'items': items.map((item) => item.toJson()).toList(),
    };

    if (appointmentId != null) {
      json['appointment_id'] = appointmentId;
    }

    if (fees != null && fees!.isNotEmpty) {
      json['fees'] = fees!.map((fee) => fee.toJson()).toList();
    }

    if (notes != null && notes!.isNotEmpty) {
      json['notes'] = notes;
    }

    return json;
  }
}

/// Order Item for Razorpay Order
class OrderItem {
  final int serviceId;
  final String contentType;
  final int quantity;

  OrderItem({
    required this.serviceId,
    required this.contentType,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'service_id': serviceId,
      'content_type': contentType,
      'quantity': quantity,
    };
  }
}

/// Order Fee for Razorpay Order
class OrderFee {
  final int feeTypeId;
  final double? amount;

  OrderFee({
    required this.feeTypeId,
    this.amount,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'fee_type_id': feeTypeId,
    };

    if (amount != null) {
      json['amount'] = amount;
    }

    return json;
  }
}

/// Razorpay Order Creation Response
class RazorpayOrderResponse {
  final String orderId;
  final String orderNumber;
  final String razorpayOrderId;
  final String razorpayKeyId;
  final double amount;
  final String currency;
  final String patientName;
  final String patientEmail;
  final String patientMobile;

  RazorpayOrderResponse({
    required this.orderId,
    required this.orderNumber,
    required this.razorpayOrderId,
    required this.razorpayKeyId,
    required this.amount,
    required this.currency,
    required this.patientName,
    required this.patientEmail,
    required this.patientMobile,
  });

  factory RazorpayOrderResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;

    return RazorpayOrderResponse(
      orderId: data['order_id']?.toString() ?? '',
      orderNumber: data['order_number']?.toString() ?? '',
      razorpayOrderId: data['razorpay_order_id']?.toString() ?? '',
      razorpayKeyId: data['razorpay_key_id']?.toString() ?? '',
      amount: _parseDouble(data['amount']),
      currency: data['currency']?.toString() ?? 'INR',
      patientName: data['patient_name']?.toString() ?? '',
      patientEmail: data['patient_email']?.toString() ?? '',
      patientMobile: data['patient_mobile']?.toString() ?? '',
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}

/// Razorpay Payment Verification Request
class RazorpayVerificationRequest {
  final String orderId;
  final String razorpayOrderId;
  final String razorpayPaymentId;
  final String razorpaySignature;

  RazorpayVerificationRequest({
    required this.orderId,
    required this.razorpayOrderId,
    required this.razorpayPaymentId,
    required this.razorpaySignature,
  });

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'razorpay_order_id': razorpayOrderId,
      'razorpay_payment_id': razorpayPaymentId,
      'razorpay_signature': razorpaySignature,
    };
  }
}

/// Razorpay Payment Verification Response
class RazorpayVerificationResponse {
  final String orderId;
  final String orderNumber;
  final String status;
  final bool isPaid;
  final int? visitId;
  final String? visitNumber;
  final int? opdBillId;
  final String? billNumber;

  RazorpayVerificationResponse({
    required this.orderId,
    required this.orderNumber,
    required this.status,
    required this.isPaid,
    this.visitId,
    this.visitNumber,
    this.opdBillId,
    this.billNumber,
  });

  factory RazorpayVerificationResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;

    return RazorpayVerificationResponse(
      orderId: data['order_id']?.toString() ?? '',
      orderNumber: data['order_number']?.toString() ?? '',
      status: data['status']?.toString() ?? '',
      isPaid: data['is_paid'] == true,
      visitId: data['visit_id'] as int?,
      visitNumber: data['visit_number']?.toString(),
      opdBillId: data['opd_bill_id'] as int?,
      billNumber: data['bill_number']?.toString(),
    );
  }

  bool get isConsultationOrder => visitId != null && visitNumber != null;
}

/// Service Type Enum
class ServiceType {
  static const String consultation = 'consultation';
  static const String diagnostic = 'diagnostic';
  static const String laboratory = 'laboratory';
  static const String pharmacy = 'pharmacy';
  static const String nursingCare = 'nursing_care';
  static const String homeHealthcare = 'home_healthcare';
}

/// Content Type Enum
class ContentType {
  static const String appointment = 'appointment';
  static const String diagnosticOrder = 'diagnosticorder';
  static const String labOrder = 'laborder';
  static const String pharmacyProduct = 'pharmacyproduct';
}
