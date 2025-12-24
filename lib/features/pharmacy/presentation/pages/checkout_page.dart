import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_toast.dart';
import '../../data/models/cart.dart';
import '../controller/pharmacy_controller.dart';
import '../widgets/razorpay_payment_sheet.dart';
import 'order_success_page.dart';

class CheckoutPage extends StatefulWidget {
  final PharmacyController controller;
  const CheckoutPage({super.key, required this.controller});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final notesCtrl = TextEditingController();
  final double voucherDiscount = 50.0;
  String selectedPaymentMethod = 'razorpay'; // 'razorpay' or 'cod'

  @override
  void initState() {
    super.initState();
    // Load cart after build completes to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.loadCart();
    });
  }

  @override
  void dispose() {
    notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: const Text(
          'Check Out',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Color(0xFF1E293B),
          ),
        ),
      ),
      body: Obx(() {
        final cart = widget.controller.cart.value;
        final isLoading = widget.controller.isLoadingCart.value;
        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (cart == null || cart.cartItems.isEmpty) {
          return _buildEmptyState();
        }
        return _buildContent(cart);
      }),
    );
  }

  Widget _buildContent(PharmacyCart cart) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildAddressSection(),
                const SizedBox(height: 20),
                _buildDeliveryInfoCard(cart),
                const SizedBox(height: 20),
                _buildVoucherSection(),
                const SizedBox(height: 12),
                _buildPaymentSection(),
                const SizedBox(height: 20),
                _buildNotesSection(),
                const SizedBox(height: 20),
                _buildSummary(cart),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        _buildBottomBar(),
      ],
    );
  }

  Widget _buildAddressSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Address Shipping',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Change',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              Icon(Icons.location_on_outlined,
                  size: 16, color: Color(0xFF64748B)),
              SizedBox(width: 6),
              Text(
                '23 Estean, New York City, USA',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfoCard(PharmacyCart cart) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: const [
                Icon(Icons.access_time, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Orders will be delivered by 18:00 Tomorrow',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...cart.cartItems.map((item) {
            final price = item.totalPrice ??
                item.priceAtTime ??
                (item.product.sellingPrice ?? item.product.mrp ?? 0);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: item.product.imageUrl != null &&
                            item.product.imageUrl!.isNotEmpty
                        ? Image.network(
                            item.product.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.local_pharmacy,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          )
                        : const Icon(
                            Icons.local_pharmacy,
                            color: AppColors.primary,
                            size: 24,
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product.productName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item.product.category?.name ?? 'Tablets'} • 50 Pills',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.shopping_bag_outlined,
                                size: 14, color: Color(0xFF64748B)),
                            const SizedBox(width: 4),
                            Text(
                              'Quatity: ${item.quantity.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₹${price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildVoucherSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            const Icon(Icons.card_giftcard_outlined,
                size: 20, color: Color(0xFF64748B)),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'MediXpert Voucher',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                backgroundColor: AppColors.primary.withOpacity(0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                children: const [
                  Text(
                    'MEDIXPERT',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.chevron_right, color: AppColors.primary, size: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSection() {
    final paymentLabel = selectedPaymentMethod == 'razorpay'
        ? 'Pay Online with Razorpay'
        : 'Cash on Delivery (COD)';
    final paymentIcon = selectedPaymentMethod == 'razorpay'
        ? Icons.payment
        : Icons.money;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: _showPaymentMethodSelector,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Icon(paymentIcon, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      paymentLabel,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF94A3B8), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notes for MediXpert',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: notesCtrl,
              maxLines: 4,
              maxLength: 225,
              decoration: const InputDecoration(
                hintText: 'Take some notes for the shipper',
                hintStyle: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(14),
                counterStyle: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(PharmacyCart cart) {
    final totalDeal = cart.totalAmount;
    final total = totalDeal - voucherDiscount;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            _buildSummaryRow('Total deal', '₹${totalDeal.toStringAsFixed(2)}'),
            const SizedBox(height: 10),
            _buildSummaryRow('Voucher', '-₹${voucherDiscount.toStringAsFixed(2)}',
                valueColor: const Color(0xFF10B981)),
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 10),
            _buildSummaryRow('Total', '₹${total.toStringAsFixed(2)}',
                isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: const Color(0xFF64748B),
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 18 : 15,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ?? const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Obx(() {
          final loading = widget.controller.isPlacingOrder.value;
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: loading ? null : _confirmOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Confirm',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shopping_cart_outlined,
                size: 80, color: AppColors.primary),
            const SizedBox(height: 16),
            const Text(
              'Your cart is empty',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add items from the pharmacy to continue.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              child: const Text('Browse Products'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentMethodSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Payment Method',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 20),
            _buildPaymentOption(
              'razorpay',
              'Pay Online with Razorpay',
              'UPI, Card, Net Banking, Wallets',
              Icons.payment,
            ),
            const SizedBox(height: 12),
            _buildPaymentOption(
              'cod',
              'Cash on Delivery',
              'Pay when you receive the order',
              Icons.money,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
    String value,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = selectedPaymentMethod == value;
    return InkWell(
      onTap: () {
        setState(() {
          selectedPaymentMethod = value;
        });
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.08)
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : const Color(0xFF64748B),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primary
                          : const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 24,
              )
            else
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[400]!, width: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmOrder() async {
    final cart = widget.controller.cart.value;
    if (cart == null || cart.cartItems.isEmpty) {
      AppToast.showError('Cart is empty');
      return;
    }

    final totalDeal = cart.totalAmount;
    final total = totalDeal - voucherDiscount;

    // Check payment method
    if (selectedPaymentMethod == 'razorpay') {
      // Show Razorpay payment sheet for online payment
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        isDismissible: false,
        builder: (context) => RazorpayPaymentSheet(
          amount: total,
          orderId: DateTime.now().millisecondsSinceEpoch.toString(),
          onSuccess: () => _handlePaymentSuccess(),
          onFailure: () => _handlePaymentFailure(),
        ),
      );
    } else {
      // Cash on Delivery - create order directly
      _handlePaymentSuccess();
    }
  }

  Future<void> _handlePaymentSuccess() async {
    // Payment successful, create the order
    final order = await widget.controller.checkout(
      notes: notesCtrl.text,
      voucherCode: 'MEDIXPERT',
    );

    if (order == null) {
      if (widget.controller.error.value.isNotEmpty) {
        AppToast.showError(widget.controller.error.value);
      }
      return;
    }

    // Navigate to success page
    Get.off(() => OrderSuccessPage(order: order));
  }

  void _handlePaymentFailure() {
    // Payment failed
    AppToast.showError('Payment failed. Please try again.');
  }
}
