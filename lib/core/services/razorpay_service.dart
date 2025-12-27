import 'dart:developer';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../config/razorpay_config.dart';

/// Service class to handle Razorpay payment integration
class RazorpayService {
  late Razorpay _razorpay;
  Function(PaymentSuccessResponse)? _onSuccess;
  Function(PaymentFailureResponse)? _onFailure;
  Function()? _onWalletSelection;

  RazorpayService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  /// Initialize payment with Razorpay (Direct Integration - No Backend Order)
  ///
  /// Parameters:
  /// - [amount]: Amount in INR (will be converted to paise automatically)
  /// - [customerName]: Customer's name
  /// - [customerEmail]: Customer's email
  /// - [customerPhone]: Customer's phone number
  /// - [description]: Payment description
  /// - [onSuccess]: Callback when payment succeeds
  /// - [onFailure]: Callback when payment fails
  /// - [onWalletSelection]: Callback when external wallet is selected
  ///
  /// Note: This uses direct Razorpay integration without backend order creation.
  /// For production, consider using backend order creation for better security.
  void openCheckout({
    required double amount,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    String? description,
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onFailure,
    Function()? onWalletSelection,
  }) {
    _onSuccess = onSuccess;
    _onFailure = onFailure;
    _onWalletSelection = onWalletSelection;

    // Convert amount to paise (Razorpay uses smallest currency unit)
    int amountInPaise = (amount * 100).toInt();

    var options = {
      'key': RazorpayConfig.keyId,
      'amount': amountInPaise,
      'name': RazorpayConfig.companyName,
      'description': description ?? RazorpayConfig.companyDescription,
      'timeout': RazorpayConfig.timeoutDuration,
      'currency': RazorpayConfig.currency,
      'prefill': {
        'name': customerName,
        'email': customerEmail,
        'contact': customerPhone,
      },
      'theme': {
        'color': '#${RazorpayConfig.themeColor}',
      },
    };

    // Add company logo if available
    if (RazorpayConfig.companyLogo.isNotEmpty) {
      options['image'] = RazorpayConfig.companyLogo;
    }

    try {
      log('🚀 Opening Razorpay with options: $options');
      _razorpay.open(options);
      log('✅ Razorpay.open() called successfully');
    } catch (e) {
      log('❌ Error opening Razorpay checkout: $e');
      log('Stack trace: ${StackTrace.current}');
      // Call failure callback with error
      if (_onFailure != null) {
        _onFailure!(PaymentFailureResponse(
          0,
          'Failed to open payment gateway: $e',
          null,
        ));
      }
    }
  }

  /// Initialize payment with Razorpay (Backend Order Integration)
  ///
  /// This is the recommended approach for production as it creates an order
  /// on the backend first, ensuring better security and order tracking.
  ///
  /// Parameters:
  /// - [razorpayOrderId]: Order ID received from backend
  /// - [razorpayKeyId]: Razorpay key ID from backend
  /// - [amount]: Amount in INR (will be converted to paise automatically)
  /// - [customerName]: Customer's name
  /// - [customerEmail]: Customer's email
  /// - [customerPhone]: Customer's phone number
  /// - [description]: Payment description
  /// - [onSuccess]: Callback when payment succeeds
  /// - [onFailure]: Callback when payment fails
  /// - [onWalletSelection]: Callback when external wallet is selected
  void openCheckoutWithOrder({
    required String razorpayOrderId,
    required String razorpayKeyId,
    required double amount,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    String? description,
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onFailure,
    Function()? onWalletSelection,
  }) {
    _onSuccess = onSuccess;
    _onFailure = onFailure;
    _onWalletSelection = onWalletSelection;

    // Convert amount to paise (Razorpay uses smallest currency unit)
    int amountInPaise = (amount * 100).toInt();

    var options = {
      'key': razorpayKeyId,
      'amount': amountInPaise,
      'currency': RazorpayConfig.currency,
      'name': RazorpayConfig.companyName,
      'description': description ?? RazorpayConfig.companyDescription,
      'order_id': razorpayOrderId, // Backend generated order ID
      'timeout': RazorpayConfig.timeoutDuration,
      'prefill': {
        'name': customerName,
        'email': customerEmail,
        'contact': customerPhone,
      },
      'theme': {
        'color': '#${RazorpayConfig.themeColor}',
      },
    };

    // Add company logo if available
    if (RazorpayConfig.companyLogo.isNotEmpty) {
      options['image'] = RazorpayConfig.companyLogo;
    }

    try {
      log('🚀 Opening Razorpay with backend order: $razorpayOrderId');
      log('Options: $options');
      _razorpay.open(options);
      log('✅ Razorpay.open() called successfully');
    } catch (e) {
      log('❌ Error opening Razorpay checkout: $e');
      log('Stack trace: ${StackTrace.current}');
      // Call failure callback with error
      if (_onFailure != null) {
        _onFailure!(PaymentFailureResponse(
          0,
          'Failed to open payment gateway: $e',
          null,
        ));
      }
    }
  }

  /// Build list of enabled payment instruments
  List<Map<String, dynamic>> _buildInstrumentsList() {
    List<Map<String, dynamic>> instruments = [];

    if (RazorpayConfig.enableUPI) {
      instruments.add({'method': 'upi'});
    }
    if (RazorpayConfig.enableCard) {
      instruments.add({'method': 'card'});
    }
    if (RazorpayConfig.enableNetbanking) {
      instruments.add({'method': 'netbanking'});
    }
    if (RazorpayConfig.enableWallet) {
      instruments.add({'method': 'wallet'});
    }
    if (RazorpayConfig.enableEMI) {
      instruments.add({'method': 'emi'});
    }

    return instruments;
  }

  /// Handle successful payment
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    log('✅ Payment Success: ${response.paymentId}');
    log('Order ID: ${response.orderId}');
    log('Signature: ${response.signature}');

    if (_onSuccess != null) {
      _onSuccess!(response);
    } else {
      log('⚠️ Warning: No success callback registered');
    }
  }

  /// Handle payment failure
  void _handlePaymentError(PaymentFailureResponse response) {
    log('❌ Payment Error: ${response.code} - ${response.message}');
    log('Error Data: ${response.error}');

    if (_onFailure != null) {
      _onFailure!(response);
    } else {
      log('⚠️ Warning: No failure callback registered');
    }
  }

  /// Handle external wallet selection
  void _handleExternalWallet(ExternalWalletResponse response) {
    log('💳 External Wallet Selected: ${response.walletName}');

    if (_onWalletSelection != null) {
      _onWalletSelection!();
    }
  }

  /// Dispose the Razorpay instance
  void dispose() {
    _razorpay.clear();
  }
}
