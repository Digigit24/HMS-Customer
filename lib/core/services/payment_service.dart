import 'dart:developer';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../data/models/razorpay_order.dart';
import '../data/repositories/order_repository.dart';
import '../storage/token_storage.dart';
import 'razorpay_service.dart';

/// Unified Payment Service for handling Razorpay payments
///
/// Handles the complete payment flow:
/// 1. Create order on backend
/// 2. Open Razorpay checkout
/// 3. Verify payment on backend
class PaymentService extends GetxService {
  late final OrderRepository _orderRepository;
  late final RazorpayService _razorpayService;

  final isProcessing = false.obs;
  final currentOrderId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _orderRepository = Get.find<OrderRepository>();
    _razorpayService = RazorpayService();
  }

  @override
  void onClose() {
    _razorpayService.dispose();
    super.onClose();
  }

  /// Process Consultation Payment
  ///
  /// Parameters:
  /// - [appointmentId]: The appointment ID to pay for
  /// - [amount]: Consultation fee amount (optional, will be calculated from appointment if not provided)
  /// - [onSuccess]: Callback when payment succeeds (receives verification response)
  /// - [onFailure]: Callback when payment fails (receives error message)
  Future<void> processConsultationPayment({
    required int appointmentId,
    required int patientId,
    double? amount,
    String? patientName,
    String? patientEmail,
    String? patientPhone,
    String? notes,
    required Function(RazorpayVerificationResponse) onSuccess,
    required Function(String error) onFailure,
  }) async {
    try {
      isProcessing.value = true;

      // Step 1: Create Razorpay Order on backend
      log('📝 Creating Razorpay order for consultation...');
      final orderRequest = RazorpayOrderRequest(
        patientId: patientId,
        servicesType: ServiceType.consultation,
        appointmentId: appointmentId,
        items: [
          OrderItem(
            serviceId: appointmentId,
            contentType: ContentType.appointment,
            quantity: 1,
          ),
        ],
        notes: notes ?? 'Online consultation payment',
      );

      final orderResponse = await _orderRepository.createRazorpayOrder(orderRequest);
      currentOrderId.value = orderResponse.orderId;

      log('✅ Order created: ${orderResponse.orderNumber}');
      log('💰 Amount: ₹${orderResponse.amount}');

      // Step 2: Open Razorpay Checkout
      log('🚀 Opening Razorpay checkout...');
      _razorpayService.openCheckoutWithOrder(
        razorpayOrderId: orderResponse.razorpayOrderId,
        razorpayKeyId: orderResponse.razorpayKeyId,
        amount: orderResponse.amount,
        customerName: patientName ?? orderResponse.patientName,
        customerEmail: patientEmail ?? orderResponse.patientEmail,
        customerPhone: patientPhone ?? orderResponse.patientMobile,
        description: 'Consultation Payment - Appointment #$appointmentId',
        onSuccess: (paymentResponse) async {
          // Step 3: Verify Payment on backend
          await _verifyPayment(
            orderResponse: orderResponse,
            paymentResponse: paymentResponse,
            onSuccess: onSuccess,
            onFailure: onFailure,
          );
        },
        onFailure: (failureResponse) {
          isProcessing.value = false;
          final errorMsg = failureResponse.message ?? 'Payment failed';
          log('❌ Payment failed: $errorMsg');
          onFailure(errorMsg);
        },
      );
    } catch (e) {
      isProcessing.value = false;
      log('❌ Error processing consultation payment: $e');
      onFailure(e.toString());
    }
  }

  /// Process Pharmacy Payment
  ///
  /// Parameters:
  /// - [cartItems]: List of cart items to pay for
  /// - [patientId]: Patient ID
  /// - [fees]: Optional additional fees
  /// - [notes]: Optional payment notes
  /// - [onSuccess]: Callback when payment succeeds
  /// - [onFailure]: Callback when payment fails
  Future<void> processPharmacyPayment({
    required List<OrderItem> items,
    required int patientId,
    String? patientName,
    String? patientEmail,
    String? patientPhone,
    List<OrderFee>? fees,
    String? notes,
    required Function(RazorpayVerificationResponse) onSuccess,
    required Function(String error) onFailure,
  }) async {
    try {
      isProcessing.value = true;

      // Step 1: Create Razorpay Order on backend
      log('📝 Creating Razorpay order for pharmacy...');
      final orderRequest = RazorpayOrderRequest(
        patientId: patientId,
        servicesType: ServiceType.pharmacy,
        items: items,
        fees: fees,
        notes: notes ?? 'Pharmacy order payment',
      );

      final orderResponse = await _orderRepository.createRazorpayOrder(orderRequest);
      currentOrderId.value = orderResponse.orderId;

      log('✅ Order created: ${orderResponse.orderNumber}');
      log('💰 Amount: ₹${orderResponse.amount}');

      // Step 2: Open Razorpay Checkout
      log('🚀 Opening Razorpay checkout...');
      _razorpayService.openCheckoutWithOrder(
        razorpayOrderId: orderResponse.razorpayOrderId,
        razorpayKeyId: orderResponse.razorpayKeyId,
        amount: orderResponse.amount,
        customerName: patientName ?? orderResponse.patientName,
        customerEmail: patientEmail ?? orderResponse.patientEmail,
        customerPhone: patientPhone ?? orderResponse.patientMobile,
        description: 'Pharmacy Order Payment',
        onSuccess: (paymentResponse) async {
          // Step 3: Verify Payment on backend
          await _verifyPayment(
            orderResponse: orderResponse,
            paymentResponse: paymentResponse,
            onSuccess: onSuccess,
            onFailure: onFailure,
          );
        },
        onFailure: (failureResponse) {
          isProcessing.value = false;
          final errorMsg = failureResponse.message ?? 'Payment failed';
          log('❌ Payment failed: $errorMsg');
          onFailure(errorMsg);
        },
      );
    } catch (e) {
      isProcessing.value = false;
      log('❌ Error processing pharmacy payment: $e');
      onFailure(e.toString());
    }
  }

  /// Verify Payment on Backend
  Future<void> _verifyPayment({
    required RazorpayOrderResponse orderResponse,
    required PaymentSuccessResponse paymentResponse,
    required Function(RazorpayVerificationResponse) onSuccess,
    required Function(String error) onFailure,
  }) async {
    try {
      log('🔐 Verifying payment...');

      final verificationRequest = RazorpayVerificationRequest(
        orderId: orderResponse.orderId,
        razorpayOrderId: paymentResponse.orderId ?? '',
        razorpayPaymentId: paymentResponse.paymentId ?? '',
        razorpaySignature: paymentResponse.signature ?? '',
      );

      final verificationResponse =
          await _orderRepository.verifyRazorpayPayment(verificationRequest);

      log('✅ Payment verified successfully!');
      log('Order Status: ${verificationResponse.status}');

      if (verificationResponse.isConsultationOrder) {
        log('📋 Visit Created: ${verificationResponse.visitNumber}');
        log('💵 OPD Bill: ${verificationResponse.billNumber}');
      }

      isProcessing.value = false;
      currentOrderId.value = '';
      onSuccess(verificationResponse);
    } catch (e) {
      isProcessing.value = false;
      log('❌ Payment verification failed: $e');
      onFailure('Payment verification failed: $e');
    }
  }

  /// Get Current Patient ID from storage/API
  ///
  /// This is a helper method to get the patient ID for the current user.
  /// You may need to implement an API call to fetch the patient profile.
  Future<int?> getCurrentPatientId() async {
    try {
      final userId = await TokenStorage.instance.getUserId();
      if (userId != null && userId.isNotEmpty) {
        // For now, assuming userId can be used as patientId
        // In production, you might need to fetch the patient profile from API
        return int.tryParse(userId);
      }
      return null;
    } catch (e) {
      log('❌ Error getting patient ID: $e');
      return null;
    }
  }
}
