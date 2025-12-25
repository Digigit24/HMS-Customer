import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/network/hms_dio_factory.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/utils/responsive_utils.dart';
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
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Obx(() {
      final isLoading = controller.isLoadingProducts.value;
      final products = _filteredProducts();
      final cart = controller.cart.value;

      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: primaryColor,
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Online Pharmacy',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.fontSize(18),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  Text(
                    'Online Pharmacy',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: context.fontSize(11),
                    ),
                  ),
                  Icon(Icons.chevron_right,
                      size: context.iconSize(12), color: Colors.white.withOpacity(0.8)),
                  Text(
                    'Prescription Drugs',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: context.fontSize(11),
                    ),
                  ),
                  Icon(Icons.chevron_right,
                      size: context.iconSize(12), color: Colors.white.withOpacity(0.8)),
                  Text(
                    'Analgesic',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: context.fontSize(11),
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
              onPressed: () async {
                // Sync local cart to backend before viewing cart
                await controller.syncCartToBackend();
                Get.to(() => ShoppingCartPage(controller: controller));
              },
              icon: Stack(
                children: [
                  const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                  Obx(() {
                    final count = controller.totalLocalItems;
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
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(context.padding(16.0)),
                child: Text(
                  'Analgesic',
                  style: TextStyle(
                    fontSize: context.fontSize(24),
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.padding(16.0)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Products (34)',
                      style: TextStyle(
                        fontSize: context.fontSize(16),
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant,
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
                      color: theme.colorScheme.onSurfaceVariant,
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
                            padding: EdgeInsets.all(context.padding(16)),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: context.spacing(16),
                              crossAxisSpacing: context.spacing(16),
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
        ),
        bottomNavigationBar: controller.totalLocalItems > 0
            ? _buildBottomCartBar()
            : null,
      );
    });
  }

  Widget _buildProductCard(PharmacyProduct product) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
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
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor),
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
                    color: theme.colorScheme.surfaceContainerHighest,
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
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.local_pharmacy,
                              size: context.iconSize(48),
                              color: primaryColor,
                            ),
                          )
                        : Icon(
                            Icons.local_pharmacy,
                            size: context.iconSize(48),
                            color: primaryColor,
                          ),
                  ),
                ),
                if (discount > 0)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: context.padding(8), vertical: context.padding(4)),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '-$discount%',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.fontSize(11),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(context.padding(12.0)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, color: const Color(0xFFFBBF24), size: context.iconSize(14)),
                        SizedBox(width: context.spacing(4)),
                        Text(
                          '4.8',
                          style: TextStyle(
                            fontSize: context.fontSize(12),
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(width: context.spacing(2)),
                        Text(
                          '(454)',
                          style: TextStyle(
                            fontSize: context.fontSize(11),
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.spacing(6)),
                    Text(
                      product.productName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: context.fontSize(14),
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: context.spacing(4)),
                    Text(
                      '5ml',
                      style: TextStyle(
                        fontSize: context.fontSize(12),
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          '₹${price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: context.fontSize(16),
                            fontWeight: FontWeight.w700,
                            color: primaryColor,
                          ),
                        ),
                        if (discount > 0) ...[
                          SizedBox(width: context.spacing(6)),
                          Text(
                            '₹${originalPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: context.fontSize(11),
                              decoration: TextDecoration.lineThrough,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Add to Cart button
            Obx(() {
              final qty = controller.getQuantity(product.id);
              return Padding(
                padding: EdgeInsets.fromLTRB(
                  context.padding(12),
                  0,
                  context.padding(12),
                  context.padding(12),
                ),
                child: qty == 0
                    ? SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: ElevatedButton(
                          onPressed: () {
                            controller.addToCart(product);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Add to Cart',
                            style: TextStyle(
                              fontSize: context.fontSize(13),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        height: 36,
                        decoration: BoxDecoration(
                          border: Border.all(color: primaryColor, width: 1.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                controller.decrementItem(product);
                              },
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                bottomLeft: Radius.circular(8),
                              ),
                              child: Container(
                                width: 36,
                                height: 36,
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.remove,
                                  size: context.iconSize(18),
                                  color: primaryColor,
                                ),
                              ),
                            ),
                            Text(
                              qty.toString(),
                              style: TextStyle(
                                fontSize: context.fontSize(14),
                                fontWeight: FontWeight.w600,
                                color: primaryColor,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                controller.incrementItem(product);
                              },
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              ),
                              child: Container(
                                width: 36,
                                height: 36,
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.add,
                                  size: context.iconSize(18),
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_pharmacy_outlined,
              size: context.iconSize(64), color: theme.colorScheme.onSurfaceVariant),
          SizedBox(height: context.spacing(16)),
          Text(
            'No products found',
            style: TextStyle(
              fontSize: context.fontSize(18),
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCartBar() {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    // Calculate total from local cart items
    final totalItems = controller.totalLocalItems;
    double totalAmount = 0;
    for (final entry in controller.localCartItems.entries) {
      final productId = entry.key;
      final quantity = entry.value;
      final product = controller.products.firstWhere(
        (p) => p.id == productId,
        orElse: () => controller.products.first,
      );
      final price = product.sellingPrice ?? product.mrp ?? 0;
      totalAmount += price * quantity;
    }

    return Container(
      padding: EdgeInsets.all(context.padding(16)),
      decoration: BoxDecoration(
        color: theme.cardColor,
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
                    style: TextStyle(
                      fontSize: context.fontSize(14),
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: context.spacing(4)),
                  Text(
                    'Total: ₹${totalAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: context.fontSize(18),
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Sync local cart to backend before viewing cart
                await controller.syncCartToBackend();
                Get.to(() => ShoppingCartPage(controller: controller));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding:
                    EdgeInsets.symmetric(horizontal: context.padding(32), vertical: context.padding(14)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'View Cart',
                style: TextStyle(
                  fontSize: context.fontSize(16),
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
