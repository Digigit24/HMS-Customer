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

  /// Initialize payment with Razorpay
  ///
  /// Parameters:
  /// - [amount]: Amount in INR (will be converted to paise automatically)
  /// - [orderId]: Razorpay order ID from backend
  /// - [customerName]: Customer's name
  /// - [customerEmail]: Customer's email
  /// - [customerPhone]: Customer's phone number
  /// - [description]: Payment description
  /// - [onSuccess]: Callback when payment succeeds
  /// - [onFailure]: Callback when payment fails
  /// - [onWalletSelection]: Callback when external wallet is selected
  void openCheckout({
    required double amount,
    required String orderId,
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
      'order_id': orderId,
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
      'modal': {
        'ondismiss': () {
          log('Razorpay checkout dismissed');
        }
      },
      'retry': {
        'enabled': RazorpayConfig.retryEnabled,
        'max_count': RazorpayConfig.maxRetryAttempts,
      },
      'config': {
        'display': {
          'blocks': {
            'utib': {
              'name': 'Pay using Razorpay',
              'instruments': _buildInstrumentsList(),
            }
          },
          'sequence': ['block.utib'],
          'preferences': {
            'show_default_blocks': true,
          }
        }
      }
    };

    // Add company logo if available
    if (RazorpayConfig.companyLogo.isNotEmpty) {
      options['image'] = RazorpayConfig.companyLogo;
    }

    try {
      _razorpay.open(options);
    } catch (e) {
      log('Error opening Razorpay checkout: $e');
      // Call failure callback with error
      if (_onFailure != null) {
        _onFailure!(PaymentFailureResponse(
          0,
          'Failed to open payment gateway',
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
    log('Payment Success: ${response.paymentId}');
    log('Order ID: ${response.orderId}');
    log('Signature: ${response.signature}');

    if (_onSuccess != null) {
      _onSuccess!(response);
    }
  }

  /// Handle payment failure
  void _handlePaymentError(PaymentFailureResponse response) {
    log('Payment Error: ${response.code} - ${response.message}');
    log('Error Data: ${response.error}');

    if (_onFailure != null) {
      _onFailure!(response);
    }
  }

  /// Handle external wallet selection
  void _handleExternalWallet(ExternalWalletResponse response) {
    log('External Wallet Selected: ${response.walletName}');

    if (_onWalletSelection != null) {
      _onWalletSelection!();
    }
  }

  /// Dispose the Razorpay instance
  void dispose() {
    _razorpay.clear();
  }
}
