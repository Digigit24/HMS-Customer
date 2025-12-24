import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_toast.dart';
import '../../data/models/cart.dart';
import '../controller/pharmacy_controller.dart';
import 'order_success_page.dart';

class CheckoutPage extends StatefulWidget {
  final PharmacyController controller;
  const CheckoutPage({super.key, required this.controller});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final notesCtrl = TextEditingController();
  final voucherCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.controller.loadCart();
  }

  @override
  void dispose() {
    notesCtrl.dispose();
    voucherCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 4),
            const Text(
              'Shopping Cart',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(width: 8),
            Obx(() {
              final count = widget.controller.cart.value?.totalItems ?? 0;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  count.toString(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
      body: Obx(() {
        final cart = widget.controller.cart.value;
        final isLoading = widget.controller.isLoadingCart.value;
        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (cart == null || cart.cartItems.isEmpty) {
          return _buildEmptyState(theme);
        }
        return _buildContent(theme, cart);
      }),
    );
  }

  Widget _buildContent(ThemeData theme, PharmacyCart cart) {
    return Container(
      color: const Color(0xFFF6F8FB),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shippingBlock(theme),
                  const SizedBox(height: 16),
                  _cartItemsBlock(theme, cart),
                  const SizedBox(height: 16),
                  _voucherBlock(theme),
                  const SizedBox(height: 12),
                  _paymentBlock(theme),
                  const SizedBox(height: 16),
                  _notesBlock(theme),
                  const SizedBox(height: 16),
                  _summary(theme, cart),
                ],
              ),
            ),
          ),
          _confirmBar(cart),
        ],
      ),
    );
  }

  Widget _shippingBlock(ThemeData theme) {
    return _card(
      theme,
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Address Shipping',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  '23 Estean, New York City, USA',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Text(
            'Change',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cartItemsBlock(ThemeData theme, PharmacyCart cart) {
    return _card(
      theme,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Orders will be delivered by 18:00 Tomorrow',
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                const Text(
                  'Change',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...cart.cartItems.map((item) => Column(
                children: [
                  _cartItemRow(theme, item),
                  if (item != cart.cartItems.last)
                    Divider(height: 16, color: theme.dividerColor.withOpacity(0.3)),
                ],
              )),
        ],
      ),
    );
  }

  Widget _cartItemRow(ThemeData theme, PharmacyCartItem item) {
    final price = item.totalPrice ??
        item.priceAtTime ??
        (item.product.sellingPrice ?? item.product.mrp ?? 0);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: item.product.imageUrl != null && item.product.imageUrl!.isNotEmpty
              ? Image.network(
                  item.product.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.local_pharmacy, color: AppColors.primary),
                )
              : const Icon(Icons.local_pharmacy, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.product.productName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text(
                '${item.product.category?.name ?? 'Tablets'} • Qty: ${item.quantity.toString().padLeft(2, '0')}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '₹${price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  _quantityStepper(item),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => _remove(item),
          icon: const Icon(Icons.delete_outline, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _quantityStepper(PharmacyCartItem item) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        color: Colors.white,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _decrement(item),
            icon: const Icon(Icons.remove),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
          Container(
            width: 36,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item.quantity.toString().padLeft(2, '0'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _increment(item),
            icon: const Icon(Icons.add),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _voucherBlock(ThemeData theme) {
    return _card(
      theme,
      child: Row(
        children: [
          const Icon(Icons.card_giftcard_outlined, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: voucherCtrl,
              decoration: const InputDecoration(
                hintText: 'MediXpert Voucher',
                border: InputBorder.none,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              FocusScope.of(context).unfocus();
              AppToast.showInfo('Voucher applied (mock)');
            },
            child: const Text(
              'APPLY',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentBlock(ThemeData theme) {
    return _card(
      theme,
      child: Row(
        children: [
          const Icon(Icons.payment, color: AppColors.primary),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Payment on delivery (COD)',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Icon(Icons.chevron_right, color: theme.iconTheme.color),
        ],
      ),
    );
  }

  Widget _notesBlock(ThemeData theme) {
    return _card(
      theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notes for MediXpert',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: notesCtrl,
            maxLines: 4,
            maxLength: 225,
            decoration: InputDecoration(
              hintText: 'Take some notes for the shipper',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              counterText: '',
            ),
          ),
        ],
      ),
    );
  }

  Widget _summary(ThemeData theme, PharmacyCart cart) {
    final subtotal = cart.totalAmount;
    final voucher = 0.0;
    final total = subtotal - voucher;
    return _card(
      theme,
      child: Column(
        children: [
          _summaryRow('Total items', cart.totalItems.toString(), theme),
          const SizedBox(height: 8),
          _summaryRow('Subtotal', '₹${subtotal.toStringAsFixed(2)}', theme),
          const SizedBox(height: 8),
          _summaryRow('Voucher', '-₹${voucher.toStringAsFixed(2)}', theme,
              valueColor: Colors.red),
          const Divider(height: 20),
          _summaryRow('Total', '₹${total.toStringAsFixed(2)}', theme,
              isBold: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, ThemeData theme,
      {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w700,
            color: valueColor ?? theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _confirmBar(PharmacyCart cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${cart.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 150,
              child: Obx(() {
                final loading = widget.controller.isPlacingOrder.value;
                return ElevatedButton(
                  onPressed: loading ? null : _confirmOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: loading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Checkout',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(ThemeData theme, {required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.remove_shopping_cart_outlined,
                size: 64, color: AppColors.primary),
            const SizedBox(height: 12),
            const Text(
              'Your cart is empty',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              'Add items from the pharmacy to continue.',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Browse products'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmOrder() async {
    final order = await widget.controller.checkout(
      notes: notesCtrl.text,
      voucherCode: voucherCtrl.text,
    );
    if (order == null) {
      if (widget.controller.error.value.isNotEmpty) {
        AppToast.showError(widget.controller.error.value);
      }
      return;
    }
    Get.off(() => OrderSuccessPage(order: order));
  }

  Future<void> _increment(PharmacyCartItem item) async {
    final ok = await widget.controller.incrementItem(item.product);
    if (ok) {
      await widget.controller.loadCart();
      setState(() {});
    }
  }

  Future<void> _decrement(PharmacyCartItem item) async {
    final ok = await widget.controller.decrementItem(item.product);
    if (ok) {
      await widget.controller.loadCart();
      setState(() {});
    }
  }

  Future<void> _remove(PharmacyCartItem item) async {
    for (var i = 0; i < item.quantity; i++) {
      final ok = await widget.controller.decrementItem(item.product);
      if (!ok) break;
    }
    await widget.controller.loadCart();
    setState(() {});
  }
}
