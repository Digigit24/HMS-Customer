import 'dart:async';
import 'dart:developer';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:js_util' as js_util;

/// Web-specific Razorpay implementation using JavaScript SDK
///
/// This service handles Razorpay payments on web platform by directly
/// interfacing with the Razorpay JavaScript SDK.
class RazorpayWebService {
  static bool _scriptLoaded = false;
  static final _scriptLoadedCompleter = Completer<void>();

  /// Initialize Razorpay by loading the JavaScript SDK
  static Future<void> initialize() async {
    if (_scriptLoaded) return;

    if (_scriptLoadedCompleter.isCompleted) {
      return _scriptLoadedCompleter.future;
    }

    try {
      // Check if script is already loaded
      if (html.document.getElementById('razorpay-checkout-js') != null) {
        _scriptLoaded = true;
        if (!_scriptLoadedCompleter.isCompleted) {
          _scriptLoadedCompleter.complete();
        }
        return;
      }

      // Load Razorpay checkout script
      final script = html.ScriptElement()
        ..id = 'razorpay-checkout-js'
        ..src = 'https://checkout.razorpay.com/v1/checkout.js'
        ..async = true;

      final completer = Completer<void>();

      script.onLoad.listen((_) {
        log('✅ Razorpay script loaded successfully');
        _scriptLoaded = true;
        completer.complete();
        if (!_scriptLoadedCompleter.isCompleted) {
          _scriptLoadedCompleter.complete();
        }
      });

      script.onError.listen((error) {
        log('❌ Failed to load Razorpay script: $error');
        final err = Exception('Failed to load Razorpay script');
        if (!completer.isCompleted) completer.completeError(err);
        if (!_scriptLoadedCompleter.isCompleted) {
          _scriptLoadedCompleter.completeError(err);
        }
      });

      html.document.head?.append(script);
      await completer.future;
    } catch (e) {
      log('❌ Error initializing Razorpay: $e');
      rethrow;
    }
  }

  /// Open Razorpay checkout on web
  static Future<void> openCheckout({
    required String razorpayKeyId,
    required String razorpayOrderId,
    required double amount,
    required String currency,
    required String name,
    required String description,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required Function(Map<String, dynamic>) onSuccess,
    required Function(Map<String, dynamic>) onFailure,
  }) async {
    try {
      // Ensure script is loaded
      await initialize();

      log('🚀 Opening Razorpay checkout on web');
      log('Key: $razorpayKeyId');
      log('Order ID: $razorpayOrderId');
      log('Amount: ₹$amount');

      // Convert amount to paise
      final amountInPaise = (amount * 100).toInt();

      // Create options object
      final options = js_util.jsify({
        'key': razorpayKeyId,
        'amount': amountInPaise,
        'currency': currency,
        'name': name,
        'description': description,
        'order_id': razorpayOrderId,
        'prefill': {
          'name': customerName,
          'email': customerEmail,
          'contact': customerPhone,
        },
        'theme': {
          'color': '#6366F1',
        },
        'handler': js.allowInterop((response) {
          log('✅ Payment successful on web');
          final result = {
            'razorpay_payment_id': js_util.getProperty(response, 'razorpay_payment_id'),
            'razorpay_order_id': js_util.getProperty(response, 'razorpay_order_id'),
            'razorpay_signature': js_util.getProperty(response, 'razorpay_signature'),
          };
          onSuccess(result);
        }),
        'modal': {
          'ondismiss': js.allowInterop(() {
            log('❌ Payment cancelled by user on web');
            onFailure({
              'code': 'PAYMENT_CANCELLED',
              'message': 'Payment cancelled by user',
            });
          }),
        },
      });

      // Create Razorpay instance
      final razorpayConstructor = js_util.getProperty(html.window, 'Razorpay');
      if (razorpayConstructor == null) {
        throw Exception('Razorpay is not loaded');
      }

      final razorpay = js_util.callConstructor(razorpayConstructor, [options]);

      // Add error handler
      js_util.callMethod(razorpay, 'on', [
        'payment.failed',
        js.allowInterop((response) {
          log('❌ Payment failed on web');
          final result = {
            'code': js_util.getProperty(
              js_util.getProperty(response, 'error'),
              'code',
            ),
            'description': js_util.getProperty(
              js_util.getProperty(response, 'error'),
              'description',
            ),
            'source': js_util.getProperty(
              js_util.getProperty(response, 'error'),
              'source',
            ),
            'step': js_util.getProperty(
              js_util.getProperty(response, 'error'),
              'step',
            ),
            'reason': js_util.getProperty(
              js_util.getProperty(response, 'error'),
              'reason',
            ),
          };
          onFailure(result);
        }),
      ]);

      // Open checkout
      js_util.callMethod(razorpay, 'open', []);
      log('✅ Razorpay checkout opened on web');
    } catch (e, stackTrace) {
      log('❌ Error opening Razorpay on web: $e');
      log('Stack trace: $stackTrace');
      onFailure({
        'code': 'INITIALIZATION_ERROR',
        'message': e.toString(),
      });
    }
  }
}
