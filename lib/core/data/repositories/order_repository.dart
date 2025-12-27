import 'package:dio/dio.dart';
import '../../network/api_exceptions.dart';
import '../../storage/token_storage.dart';
import '../models/razorpay_order.dart';

/// Unified Order Repository for Razorpay Payment Integration
///
/// Handles all Razorpay payment operations for consultation, pharmacy, and other services
class OrderRepository {
  final Dio dio;

  OrderRepository({required this.dio});

  /// Get authenticated request options with tenant headers
  Future<Options> _authOptions() async {
    final token = await TokenStorage.instance.getAccessToken();
    if (token == null || token.isEmpty) {
      throw ApiException('Not authenticated');
    }

    final tenantId = await TokenStorage.instance.getTenantId();
    final tenantSlug = await TokenStorage.instance.getTenantSlug();
    final tenantToken = await TokenStorage.instance.getTenantToken();

    final headers = <String, dynamic>{
      'Authorization': 'Bearer $token',
    };

    if (tenantId != null && tenantId.isNotEmpty) {
      headers['x-tenant-id'] = tenantId;
      headers['tenanttoken'] =
          (tenantToken != null && tenantToken.isNotEmpty)
              ? tenantToken
              : tenantId;
    }
    if (tenantSlug != null && tenantSlug.isNotEmpty) {
      headers['x-tenant-slug'] = tenantSlug;
    }

    return Options(headers: headers);
  }

  /// Create Razorpay Order
  ///
  /// Creates an order in DigiHMS and Razorpay, returns checkout details for frontend
  ///
  /// Endpoint: POST /api/orders/razorpay/create/
  ///
  /// Example for Consultation:
  /// ```dart
  /// final request = RazorpayOrderRequest(
  ///   patientId: 123,
  ///   servicesType: ServiceType.consultation,
  ///   appointmentId: 456,
  ///   items: [
  ///     OrderItem(
  ///       serviceId: 456,
  ///       contentType: ContentType.appointment,
  ///       quantity: 1,
  ///     ),
  ///   ],
  ///   notes: 'Online consultation payment',
  /// );
  /// ```
  ///
  /// Example for Pharmacy:
  /// ```dart
  /// final request = RazorpayOrderRequest(
  ///   patientId: 123,
  ///   servicesType: ServiceType.pharmacy,
  ///   items: [
  ///     OrderItem(
  ///       serviceId: 789,
  ///       contentType: ContentType.pharmacyProduct,
  ///       quantity: 2,
  ///     ),
  ///   ],
  ///   fees: [
  ///     OrderFee(feeTypeId: 5, amount: 50.0),
  ///   ],
  /// );
  /// ```
  Future<RazorpayOrderResponse> createRazorpayOrder(
    RazorpayOrderRequest request,
  ) async {
    try {
      final response = await dio.post(
        '/api/orders/razorpay/create/',
        data: request.toJson(),
        options: await _authOptions(),
      );

      if (response.data['success'] != true) {
        throw ApiException(
          response.data['error']?.toString() ?? 'Failed to create order',
        );
      }

      return RazorpayOrderResponse.fromJson(response.data);
    } on DioException catch (e) {
      await _handleAuthError(e);

      // Handle specific error responses
      if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        if (errorData is Map) {
          final errorMsg = errorData['error']?.toString() ??
              errorData['message']?.toString() ??
              'Invalid request';
          throw ApiException(errorMsg, statusCode: 400);
        }
      }

      throw ApiException(
        e.response?.data?.toString() ?? 'Failed to create Razorpay order',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Verify Razorpay Payment
  ///
  /// Verifies payment signature and completes the order.
  /// For consultation orders, auto-creates Visit + OPDBill.
  ///
  /// Endpoint: POST /api/orders/razorpay/verify/
  ///
  /// Example:
  /// ```dart
  /// final verificationRequest = RazorpayVerificationRequest(
  ///   orderId: orderResponse.orderId,
  ///   razorpayOrderId: paymentResponse.orderId,
  ///   razorpayPaymentId: paymentResponse.paymentId,
  ///   razorpaySignature: paymentResponse.signature,
  /// );
  /// ```
  Future<RazorpayVerificationResponse> verifyRazorpayPayment(
    RazorpayVerificationRequest request,
  ) async {
    try {
      final response = await dio.post(
        '/api/orders/razorpay/verify/',
        data: request.toJson(),
        options: await _authOptions(),
      );

      if (response.data['success'] != true) {
        throw ApiException(
          response.data['error']?.toString() ?? 'Payment verification failed',
        );
      }

      return RazorpayVerificationResponse.fromJson(response.data);
    } on DioException catch (e) {
      await _handleAuthError(e);

      // Handle specific error responses
      if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        if (errorData is Map) {
          final errorMsg = errorData['error']?.toString() ??
              errorData['message']?.toString() ??
              'Payment verification failed';
          throw ApiException(errorMsg, statusCode: 400);
        }
      }

      if (e.response?.statusCode == 404) {
        throw ApiException('Order not found', statusCode: 404);
      }

      throw ApiException(
        e.response?.data?.toString() ?? 'Failed to verify payment',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Get Fee Types
  ///
  /// Endpoint: GET /api/orders/fee-types/
  ///
  /// Returns list of available fee types (service charges, taxes, etc.)
  Future<List<Map<String, dynamic>>> getFeeTypes() async {
    try {
      final response = await dio.get(
        '/api/orders/fee-types/',
        options: await _authOptions(),
      );

      final data = response.data;

      if (data is Map && data['data'] is List) {
        return List<Map<String, dynamic>>.from(data['data']);
      }

      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      }

      throw ApiException('Unexpected fee types format');
    } on DioException catch (e) {
      await _handleAuthError(e);
      throw ApiException(
        e.response?.data?.toString() ?? 'Failed to load fee types',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// List Orders
  ///
  /// Endpoint: GET /api/orders/
  ///
  /// Optional query parameters:
  /// - payment_verified: Filter by payment verification status
  Future<List<Map<String, dynamic>>> listOrders({
    bool? paymentVerified,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (paymentVerified != null) {
        queryParams['payment_verified'] = paymentVerified;
      }

      final response = await dio.get(
        '/api/orders/',
        queryParameters: queryParams,
        options: await _authOptions(),
      );

      final data = response.data;

      if (data is Map && data['data'] is List) {
        return List<Map<String, dynamic>>.from(data['data']);
      }

      if (data is Map && data['results'] is List) {
        return List<Map<String, dynamic>>.from(data['results']);
      }

      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      }

      throw ApiException('Unexpected orders format');
    } on DioException catch (e) {
      await _handleAuthError(e);
      throw ApiException(
        e.response?.data?.toString() ?? 'Failed to load orders',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Get Order Details
  ///
  /// Endpoint: GET /api/orders/{order_id}/
  Future<Map<String, dynamic>> getOrderDetails(String orderId) async {
    try {
      final response = await dio.get(
        '/api/orders/$orderId/',
        options: await _authOptions(),
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      await _handleAuthError(e);
      throw ApiException(
        e.response?.data?.toString() ?? 'Failed to load order details',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Handle authentication errors
  Future<void> _handleAuthError(DioException e) async {
    if (e.response?.statusCode == 401) {
      await TokenStorage.instance.clear();
      throw ApiException('Session expired. Please login again.', statusCode: 401);
    }
  }
}
