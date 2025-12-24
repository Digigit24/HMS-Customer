import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/network/hms_dio_factory.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../pharmacy/data/repositories/pharmacy_repository.dart';
import '../../../pharmacy/data/models/product.dart';
import '../../../pharmacy/presentation/controller/pharmacy_controller.dart';
import '../../../pharmacy/presentation/pages/shopping_cart_page.dart';
import '../../../pharmacy/presentation/pages/product_detail_page.dart';
import '../../../pharmacy/presentation/widgets/filter_bottom_sheet.dart';

class PharmacyTab extends StatefulWidget {
  const PharmacyTab({super.key});

  @override
  State<PharmacyTab> createState() => _PharmacyTabState();
}

class _PharmacyTabState extends State<PharmacyTab> {
  late final PharmacyController controller;
  int? selectedCategoryId;
  String search = '';

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      PharmacyController(
        repo: PharmacyRepository(
          dio: HmsDioFactory.create(),
        ),
      ),
      permanent: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isLoadingProducts.value;
      final products = _filteredProducts();
      final cart = controller.cart.value;

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Online Pharmacy',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  Text(
                    'Online Pharmacy',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 11,
                    ),
                  ),
                  Icon(Icons.chevron_right,
                      size: 12, color: Colors.white.withOpacity(0.8)),
                  Text(
                    'Prescription Drugs',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 11,
                    ),
                  ),
                  Icon(Icons.chevron_right,
                      size: 12, color: Colors.white.withOpacity(0.8)),
                  Text(
                    'Analgesic',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            ),
            IconButton(
              onPressed: () {
                Get.to(() => ShoppingCartPage(controller: controller));
              },
              icon: Stack(
                children: [
                  const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                  Obx(() {
                    final count = controller.cart.value?.totalItems ?? 0;
                    if (count == 0) return const SizedBox.shrink();
                    return Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          count.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Analgesic',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Products (34)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const FilterBottomSheet(),
                      );
                    },
                    icon: const Icon(Icons.tune),
                    color: const Color(0xFF64748B),
                  ),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : products.isEmpty
                      ? _buildEmptyState()
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.7,
                          ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            return _buildProductCard(products[index]);
                          },
                        ),
            ),
          ],
        ),
        bottomNavigationBar: cart != null && cart.cartItems.isNotEmpty
            ? _buildBottomCartBar(cart.totalAmount, cart.totalItems)
            : null,
      );
    });
  }

  Widget _buildProductCard(PharmacyProduct product) {
    final qty = controller.getQuantity(product.id);
    final price = product.sellingPrice ?? product.mrp ?? 0;
    final originalPrice = product.mrp ?? price;
    final discount = originalPrice > price
        ? ((originalPrice - price) / originalPrice * 100).round()
        : 0;

    return InkWell(
      onTap: () {
        Get.to(() => ProductDetailPage(
          product: product,
          controller: controller,
        ));
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Center(
                    child: product.imageUrl != null &&
                            product.imageUrl!.isNotEmpty
                        ? Image.network(
                            product.imageUrl!,
                            height: 80,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.local_pharmacy,
                              size: 48,
                              color: AppColors.primary,
                            ),
                          )
                        : const Icon(
                            Icons.local_pharmacy,
                            size: 48,
                            color: AppColors.primary,
                          ),
                  ),
                ),
                if (discount > 0)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '-$discount%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, color: Color(0xFFFBBF24), size: 14),
                        const SizedBox(width: 4),
                        const Text(
                          '4.8',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '(454)',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.productName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '5ml',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          '₹${price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        if (discount > 0) ...[
                          const SizedBox(width: 6),
                          Text(
                            '₹${originalPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 11,
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_pharmacy_outlined,
              size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No products found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCartBar(double totalAmount, int totalItems) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$totalItems items',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total: ₹${totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Get.to(() => ShoppingCartPage(controller: controller));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'View Cart',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PharmacyProduct> _filteredProducts() {
    var list = controller.products.toList();
    if (selectedCategoryId != null) {
      list = list.where((p) => p.category?.id == selectedCategoryId).toList();
    }
    if (search.isNotEmpty) {
      final q = search.toLowerCase();
      list = list
          .where((p) =>
              p.productName.toLowerCase().contains(q) ||
              (p.company?.toLowerCase().contains(q) ?? false))
          .toList();
    }
    return list;
  }
}
