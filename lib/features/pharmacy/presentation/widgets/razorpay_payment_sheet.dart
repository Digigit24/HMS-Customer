import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../core/services/razorpay_service.dart';
import '../../../../core/theme/theme_controller.dart';

/// Razorpay Payment Sheet Widget (Direct Integration)
///
/// This widget handles the Razorpay payment flow without backend order creation:
/// 1. Displays payment processing UI
/// 2. Initiates Razorpay checkout directly
/// 3. Handles payment success/failure callbacks
/// 4. Supports dark/light mode themes
///
/// Note: Uses direct Razorpay integration - no backend order ID required
class RazorpayPaymentSheet extends StatefulWidget {
  final double amount;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String? description;
  final Function(PaymentSuccessResponse) onSuccess;
  final Function(PaymentFailureResponse) onFailure;

  const RazorpayPaymentSheet({
    super.key,
    required this.amount,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    this.description,
    required this.onSuccess,
    required this.onFailure,
  });

  @override
  State<RazorpayPaymentSheet> createState() => _RazorpayPaymentSheetState();
}

class _RazorpayPaymentSheetState extends State<RazorpayPaymentSheet> {
  late RazorpayService _razorpayService;
  bool _isProcessing = true;
  String _statusMessage = 'Initializing payment gateway...';
  final themeController = Get.find<ThemeController>();

  @override
  void initState() {
    super.initState();
    _razorpayService = RazorpayService();
    _initializePayment();
  }

  @override
  void dispose() {
    _razorpayService.dispose();
    super.dispose();
  }

  /// Initialize and open Razorpay payment gateway
  void _initializePayment() {
    // Small delay to show initialization screen
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      setState(() {
        _statusMessage = 'Opening secure payment gateway...';
      });

      // Open Razorpay checkout (Direct Integration - No Backend Order)
      _razorpayService.openCheckout(
        amount: widget.amount,
        customerName: widget.customerName,
        customerEmail: widget.customerEmail,
        customerPhone: widget.customerPhone,
        description: widget.description,
        onSuccess: _handlePaymentSuccess,
        onFailure: _handlePaymentError,
        onWalletSelection: _handleExternalWallet,
      );
    });
  }

  /// Handle successful payment
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (!mounted) return;

    setState(() {
      _isProcessing = false;
      _statusMessage = 'Payment successful!';
    });

    // Close this sheet and call success callback
    Navigator.of(context).pop();
    widget.onSuccess(response);
  }

  /// Handle payment failure
  void _handlePaymentError(PaymentFailureResponse response) {
    if (!mounted) return;

    setState(() {
      _isProcessing = false;
      _statusMessage = 'Payment failed';
    });

    // Close this sheet and call failure callback
    Navigator.of(context).pop();
    widget.onFailure(response);
  }

  /// Handle external wallet selection
  void _handleExternalWallet() {
    if (!mounted) return;

    setState(() {
      _statusMessage = 'Redirecting to wallet...';
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !_isProcessing, // Prevent back during processing
      child: Container(
        height: MediaQuery.of(context).size.height * 0.4,
        decoration: BoxDecoration(
          color: themeController.isDarkMode
              ? const Color(0xFF1E293B)
              : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final primaryColor = themeController.getColor('primary');
    final textColor = themeController.isDarkMode
        ? Colors.white
        : const Color(0xFF1E293B);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeController.isDarkMode
            ? const Color(0xFF1E293B)
            : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.payment,
            color: primaryColor,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            'Razorpay Payment',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: primaryColor,
            ),
          ),
          const Spacer(),
          if (!_isProcessing)
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.close,
                color: themeController.isDarkMode
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final textColor = themeController.isDarkMode
        ? Colors.white
        : const Color(0xFF1E293B);
    final subtextColor = themeController.isDarkMode
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final primaryColor = themeController.getColor('primary');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated loading indicator
            SizedBox(
              width: 64,
              height: 64,
              child: CircularProgressIndicator(
                color: primaryColor,
                strokeWidth: 4,
              ),
            ),
            const SizedBox(height: 32),

            // Amount display
            Text(
              '₹${widget.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),

            // Status message
            Text(
              _statusMessage,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Instruction text
            Text(
              _isProcessing
                  ? 'Please complete the payment in the Razorpay window'
                  : 'You can close this window',
              style: TextStyle(
                fontSize: 14,
                color: subtextColor,
              ),
              textAlign: TextAlign.center,
            ),

            if (_isProcessing) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: primaryColor.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.security,
                      size: 16,
                      color: primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Secured by Razorpay',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
