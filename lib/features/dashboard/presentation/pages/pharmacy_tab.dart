import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/network/hms_dio_factory.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../pharmacy/data/repositories/pharmacy_repository.dart';
import '../../../pharmacy/data/models/product.dart';
import '../../../pharmacy/presentation/controller/pharmacy_controller.dart';
import '../../../pharmacy/presentation/pages/shopping_cart_page.dart';
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
          dio: HmsDioFactory.create(baseUrl: 'https://hms.celiyo.com'),
        ),
      ),
      permanent: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      final isLoading = controller.isLoadingProducts.value;
      final products = _filteredProducts();
      final cart = controller.cart.value;

      return Scaffold(
        backgroundColor:
            theme.brightness == Brightness.dark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FA),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await controller.loadProducts();
              await controller.loadCart();
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHeader(theme),
                const SizedBox(height: 12),
                _buildSearchField(),
                const SizedBox(height: 12),
                _buildCategoriesAndFilter(),
                const SizedBox(height: 12),
                if (controller.error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      controller.error.value,
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                if (!isLoading && products.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Column(
                      children: [
                        Icon(Icons.local_pharmacy, size: 48, color: Colors.grey[500]),
                        const SizedBox(height: 12),
                        const Text(
                          'No medicines found',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Try a different category or search term.',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                if (!isLoading && products.isNotEmpty)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.78,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return _buildProductCard(products[index]);
                    },
                  ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
        bottomNavigationBar: cart != null && cart.cartItems.isNotEmpty
            ? _buildCartBar(cart.totalAmount, cart.totalItems)
            : null,
      );
    });
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pharmacy',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Order your medicines quickly',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () {
            Get.to(() => ShoppingCartPage(controller: controller));
          },
          icon: Stack(
            children: [
              const Icon(Icons.shopping_bag_outlined),
              Obx(() {
                final count = controller.cart.value?.totalItems ?? 0;
                if (count == 0) return const SizedBox.shrink();
                return Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
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
                        fontSize: 10,
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
    );
  }

  Widget _buildSearchField() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search medicines',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (val) {
        setState(() {
          search = val.trim();
        });
      },
    );
  }

  Widget _buildCategoriesAndFilter() {
    return Row(
      children: [
        Expanded(child: _buildCategories()),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const FilterBottomSheet(),
              );
            },
            icon: const Icon(Icons.tune, color: Colors.white),
            padding: const EdgeInsets.all(8),
          ),
        ),
      ],
    );
  }

  Widget _buildCategories() {
    if (controller.categories.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: controller.categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isAll = index == 0;
          final cat = isAll ? null : controller.categories[index - 1];
          final selected = isAll ? selectedCategoryId == null : selectedCategoryId == cat!.id;
          final label = isAll ? 'All' : cat!.name;
          return ChoiceChip(
            label: Text(label),
            selected: selected,
            onSelected: (_) {
              setState(() {
                selectedCategoryId = isAll ? null : cat!.id;
              });
            },
            selectedColor: AppColors.primary,
            labelStyle: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            backgroundColor: Colors.white,
          );
        },
      ),
    );
  }

  Widget _buildProductCard(PharmacyProduct product) {
    final theme = Theme.of(context);
    final qty = controller.getQuantity(product.id);
    final price = product.sellingPrice ?? product.mrp ?? 0;
    final inStock = product.isInStock && (product.quantity ?? 1) > 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.productName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (product.company != null && product.company!.isNotEmpty)
                      Text(
                        product.company!,
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    if (product.category != null)
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.category!.name,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rs ${price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    inStock ? 'In stock' : 'Out of stock',
                    style: TextStyle(
                      color: inStock ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (product.lowStockWarning)
                Text(
                  'Low stock',
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                )
              else
                const SizedBox.shrink(),
              qty == 0
                  ? ElevatedButton(
                      onPressed: inStock ? () => _handleAdd(product) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Add to cart'),
                    )
                  : _buildQuantityChip(product, qty),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityChip(PharmacyProduct product, int qty) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => _handleDecrement(product),
            icon: const Icon(Icons.remove),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
            color: AppColors.primary,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '$qty',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _handleIncrement(product),
            icon: const Icon(Icons.add),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildCartBar(double totalAmount, int totalItems) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
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
                  Text(
                    '$totalItems items',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total: Rs ${totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 140,
              child: ElevatedButton(
                onPressed: controller.isPlacingOrder.value
                    ? null
                    : () {
                        Get.to(() => ShoppingCartPage(controller: controller));
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: controller.isPlacingOrder.value
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Checkout',
                        style: TextStyle(fontWeight: FontWeight.w700),
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

  Future<void> _handleAdd(PharmacyProduct product) async {
    final ok = await controller.addToCart(product);
    if (!ok) {
      AppToast.showError(
        controller.error.value.isNotEmpty
            ? controller.error.value
            : 'Failed to add to cart',
      );
      return;
    }
    setState(() {});
  }

  Future<void> _handleIncrement(PharmacyProduct product) async {
    final ok = await controller.incrementItem(product);
    if (!ok) {
      AppToast.showError(
        controller.error.value.isNotEmpty
            ? controller.error.value
            : 'Failed to update cart',
      );
      return;
    }
    setState(() {});
  }

  Future<void> _handleDecrement(PharmacyProduct product) async {
    final ok = await controller.decrementItem(product);
    if (!ok) {
      AppToast.showError(
        controller.error.value.isNotEmpty
            ? controller.error.value
            : 'Failed to update cart',
      );
      return;
    }
    setState(() {});
  }

  Future<void> _handleCheckout() async {
    final order = await controller.checkout();
    if (order == null) {
      if (controller.error.value.isNotEmpty) {
        AppToast.showError(controller.error.value);
      }
      return;
    }
  }
}


