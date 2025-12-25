import 'package:get/get.dart';

import '../../../../core/network/api_exceptions.dart';
import '../../../../core/utils/app_toast.dart';
import '../../data/models/cart.dart';
import '../../data/models/category.dart';
import '../../data/models/order.dart';
import '../../data/models/product.dart';
import '../../data/repositories/pharmacy_repository.dart';

class PharmacyController extends GetxController {
  final PharmacyRepository repo;
  PharmacyController({required this.repo});

  final products = <PharmacyProduct>[].obs;
  final categories = <PharmacyCategory>[].obs;
  final cart = Rxn<PharmacyCart>();
  final orders = <PharmacyOrder>[].obs;

  final isLoadingProducts = false.obs;
  final isLoadingCart = false.obs;
  final isPlacingOrder = false.obs;
  final error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
    loadProducts();
    loadCart();
  }

  Future<void> loadProducts() async {
    isLoadingProducts.value = true;
    error.value = '';
    try {
      final data = await repo.fetchProducts();
      products.assignAll(data);
      print('✅ Loaded ${data.length} products');
    } on ApiException catch (e) {
      error.value = e.message;
      AppToast.showError(e.message);
      print('❌ Error loading products: ${e.message}');
    } catch (e) {
      error.value = 'Failed to load products';
      print('❌ Unexpected error loading products: $e');
    } finally {
      isLoadingProducts.value = false;
    }
  }

  Future<void> loadCategories() async {
    try {
      final data = await repo.fetchCategories();
      categories.assignAll(data);
    } catch (_) {
      // categories are optional for UI; swallow error
    }
  }

  Future<void> loadCart() async {
    isLoadingCart.value = true;
    try {
      final c = await repo.fetchCart();
      cart.value = c;
    } on ApiException catch (e) {
      error.value = e.message;
      AppToast.showError(e.message);
    } finally {
      isLoadingCart.value = false;
    }
  }

  Future<bool> addToCart(PharmacyProduct product) async {
    // Store previous cart for rollback
    final previousCart = cart.value;

    // Optimistic UI update
    final optimisticCart = _createOptimisticCartForAdd(product);
    cart.value = optimisticCart;

    try {
      final updated = await repo.addItem(
        productId: product.id,
        quantity: 1,
      );
      cart.value = updated;
      AppToast.showSuccess('${product.productName} added to cart');
      return true;
    } on ApiException catch (e) {
      // Rollback on error
      cart.value = previousCart;
      error.value = e.message;
      AppToast.showError(e.message);
      return false;
    }
  }

  Future<bool> incrementItem(PharmacyProduct product) async {
    final currentQty = getQuantity(product.id);
    final existingItem = _findCartItem(product.id);
    if (existingItem == null) {
      return addToCart(product);
    }

    // Store previous cart for rollback
    final previousCart = cart.value;

    final newQty = currentQty + 1;

    // Optimistic UI update
    final optimisticCart = _createOptimisticCartForUpdate(product.id, newQty);
    cart.value = optimisticCart;

    try {
      final updated = await repo.updateItem(
        cartItemId: existingItem.id,
        quantity: newQty,
      );
      cart.value = updated;
      AppToast.showSuccess('Updated ${product.productName} to $newQty');
      return true;
    } on ApiException catch (e) {
      // Rollback on error
      cart.value = previousCart;
      error.value = e.message;
      AppToast.showError(e.message);
      return false;
    }
  }

  Future<bool> decrementItem(PharmacyProduct product) async {
    final existingItem = _findCartItem(product.id);
    if (existingItem == null) return false;

    // Store previous cart for rollback
    final previousCart = cart.value;

    final newQty = existingItem.quantity - 1;

    // Optimistic UI update
    final optimisticCart = newQty <= 0
        ? _createOptimisticCartForRemove(product.id)
        : _createOptimisticCartForUpdate(product.id, newQty);
    cart.value = optimisticCart;

    try {
      if (newQty <= 0) {
        final updated =
            await repo.removeItem(cartItemId: existingItem.id);
        cart.value = updated;
        AppToast.showInfo('${product.productName} removed from cart');
      } else {
        final updated = await repo.updateItem(
          cartItemId: existingItem.id,
          quantity: newQty,
        );
        cart.value = updated;
        AppToast.showSuccess('Updated ${product.productName} to $newQty');
      }
      return true;
    } on ApiException catch (e) {
      // Rollback on error
      cart.value = previousCart;
      error.value = e.message;
      AppToast.showError(e.message);
      return false;
    }
  }

  Future<bool> clearCart() async {
    try {
      final updated = await repo.clearCart();
      cart.value = updated;
      AppToast.showInfo('Cart cleared');
      return true;
    } on ApiException catch (e) {
      error.value = e.message;
      AppToast.showError(e.message);
      return false;
    }
  }

  Future<PharmacyOrder?> checkout({String? notes, String? voucherCode}) async {
    if (cart.value == null || cart.value!.cartItems.isEmpty) return null;
    isPlacingOrder.value = true;
    try {
      final payload = <String, dynamic>{
        'shipping_address': '23 Estean, New York City, USA',
        'billing_address': '23 Estean, New York City, USA',
        'status': 'pending',
        'payment_status': 'pending',
      };

      if (notes != null && notes.trim().isNotEmpty) {
        payload['notes'] = notes.trim();
      }
      if (voucherCode != null && voucherCode.trim().isNotEmpty) {
        payload['voucher'] = voucherCode.trim();
      }

      final order = await repo.createOrder(payload: payload);
      await loadCart(); // refresh cart after order
      await loadOrders();
      AppToast.showSuccess('Order #${order.id} created successfully');
      return order;
    } on ApiException catch (e) {
      error.value = e.message;
      AppToast.showError(e.message);
      return null;
    } finally {
      isPlacingOrder.value = false;
    }
  }

  Future<void> loadOrders() async {
    try {
      final data = await repo.fetchOrders();
      orders.assignAll(data);
    } on ApiException catch (e) {
      error.value = e.message;
      AppToast.showError(e.message);
    }
  }

  int getQuantity(int productId) {
    final item = _findCartItem(productId);
    return item?.quantity ?? 0;
  }

  PharmacyCartItem? _findCartItem(int productId) {
    final c = cart.value;
    if (c == null) return null;
    for (final item in c.cartItems) {
      if (item.product.id == productId) return item;
    }
    return null;
  }

  /// Create optimistic cart when adding a new product
  PharmacyCart _createOptimisticCartForAdd(PharmacyProduct product) {
    final currentCart = cart.value;
    final price = product.sellingPrice ?? product.mrp ?? 0;

    // Create new cart item
    final newItem = PharmacyCartItem(
      id: -1, // Temporary ID
      product: product,
      quantity: 1,
      priceAtTime: price,
      totalPrice: price,
    );

    if (currentCart == null) {
      // Create new cart
      return PharmacyCart(
        id: -1, // Temporary ID
        cartItems: [newItem],
        totalItems: 1,
        totalAmount: price,
      );
    } else {
      // Add to existing cart
      final updatedItems = [...currentCart.cartItems, newItem];
      return PharmacyCart(
        id: currentCart.id,
        userId: currentCart.userId,
        cartItems: updatedItems,
        totalItems: currentCart.totalItems + 1,
        totalAmount: currentCart.totalAmount + price,
        createdAt: currentCart.createdAt,
        updatedAt: DateTime.now(),
      );
    }
  }

  /// Create optimistic cart when updating quantity
  PharmacyCart? _createOptimisticCartForUpdate(int productId, int newQuantity) {
    final currentCart = cart.value;
    if (currentCart == null) return null;

    final updatedItems = currentCart.cartItems.map((item) {
      if (item.product.id == productId) {
        final price = item.priceAtTime ?? item.product.sellingPrice ?? item.product.mrp ?? 0;
        return PharmacyCartItem(
          id: item.id,
          product: item.product,
          quantity: newQuantity,
          priceAtTime: price,
          totalPrice: price * newQuantity,
        );
      }
      return item;
    }).toList();

    final totalItems = updatedItems.fold<int>(0, (sum, item) => sum + item.quantity);
    final totalAmount = updatedItems.fold<double>(0, (sum, item) => sum + (item.totalPrice ?? 0));

    return PharmacyCart(
      id: currentCart.id,
      userId: currentCart.userId,
      cartItems: updatedItems,
      totalItems: totalItems,
      totalAmount: totalAmount,
      createdAt: currentCart.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Create optimistic cart when removing a product
  PharmacyCart? _createOptimisticCartForRemove(int productId) {
    final currentCart = cart.value;
    if (currentCart == null) return null;

    final updatedItems = currentCart.cartItems.where((item) => item.product.id != productId).toList();

    if (updatedItems.isEmpty) {
      return PharmacyCart(
        id: currentCart.id,
        userId: currentCart.userId,
        cartItems: [],
        totalItems: 0,
        totalAmount: 0,
        createdAt: currentCart.createdAt,
        updatedAt: DateTime.now(),
      );
    }

    final totalItems = updatedItems.fold<int>(0, (sum, item) => sum + item.quantity);
    final totalAmount = updatedItems.fold<double>(0, (sum, item) => sum + (item.totalPrice ?? 0));

    return PharmacyCart(
      id: currentCart.id,
      userId: currentCart.userId,
      cartItems: updatedItems,
      totalItems: totalItems,
      totalAmount: totalAmount,
      createdAt: currentCart.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Create Razorpay order on backend
  ///
  /// This should be called before initiating Razorpay payment
  /// Returns order details including razorpay_order_id
  Future<Map<String, dynamic>?> createRazorpayOrder({
    required double amount,
    String? notes,
    String? voucherCode,
  }) async {
    isPlacingOrder.value = true;
    try {
      final orderData = await repo.createRazorpayOrder(
        amount: amount,
        notes: notes,
        voucherCode: voucherCode,
      );
      return orderData;
    } on ApiException catch (e) {
      error.value = e.message;
      AppToast.showError(e.message);
      return null;
    } finally {
      isPlacingOrder.value = false;
    }
  }

  /// Verify Razorpay payment and create order
  ///
  /// This should be called after successful Razorpay payment
  /// to verify the payment on backend and create the pharmacy order
  Future<PharmacyOrder?> verifyRazorpayPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    String? notes,
    String? voucherCode,
  }) async {
    isPlacingOrder.value = true;
    try {
      final order = await repo.verifyRazorpayPayment(
        razorpayOrderId: razorpayOrderId,
        razorpayPaymentId: razorpayPaymentId,
        razorpaySignature: razorpaySignature,
        notes: notes,
        voucherCode: voucherCode,
      );
      await loadCart(); // Refresh cart after order
      await loadOrders(); // Refresh orders
      AppToast.showSuccess('Order #${order.id} placed successfully');
      return order;
    } on ApiException catch (e) {
      error.value = e.message;
      AppToast.showError(e.message);
      return null;
    } finally {
      isPlacingOrder.value = false;
    }
  }
}
