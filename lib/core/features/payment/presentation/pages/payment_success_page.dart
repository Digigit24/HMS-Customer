import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme/theme_controller.dart';
import '../../../../data/models/razorpay_order.dart';

/// Universal Payment Success Page
///
/// Displays payment success message for any service type (consultation, pharmacy, etc.)
class PaymentSuccessPage extends StatelessWidget {
  final RazorpayVerificationResponse verificationResponse;
  final String? title;
  final String? subtitle;
  final VoidCallback? onContinue;

  const PaymentSuccessPage({
    super.key,
    required this.verificationResponse,
    this.title,
    this.subtitle,
    this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Payment Successful',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Success Icon
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Color(0xFF10B981),
                          size: 80,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Title
                      Text(
                        title ?? 'Payment Successful!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 12),

                      // Subtitle
                      Text(
                        subtitle ?? _getDefaultSubtitle(),
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? const Color(0xFF94A3B8) : Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 40),

                      // Order Details Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildDetailRow(
                              'Order Number',
                              verificationResponse.orderNumber,
                              isDark,
                            ),
                            const SizedBox(height: 16),
                            _buildDetailRow(
                              'Status',
                              verificationResponse.status.toUpperCase(),
                              isDark,
                              valueColor: const Color(0xFF10B981),
                            ),

                            // Show consultation-specific details
                            if (verificationResponse.isConsultationOrder) ...[
                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 16),
                              _buildDetailRow(
                                'Visit Number',
                                verificationResponse.visitNumber ?? 'N/A',
                                isDark,
                              ),
                              if (verificationResponse.billNumber != null) ...[
                                const SizedBox(height: 16),
                                _buildDetailRow(
                                  'Bill Number',
                                  verificationResponse.billNumber!,
                                  isDark,
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onContinue ?? () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    bool isDark, {
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? const Color(0xFF94A3B8) : Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? (isDark ? Colors.white : Colors.black87),
          ),
        ),
      ],
    );
  }

  String _getDefaultSubtitle() {
    if (verificationResponse.isConsultationOrder) {
      return 'Your consultation appointment has been confirmed.\nYour visit has been registered.';
    }
    return 'Your order has been confirmed and will be\nprocessed shortly.';
  }
}
