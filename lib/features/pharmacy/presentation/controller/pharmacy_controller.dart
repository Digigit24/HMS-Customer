import 'package:get/get.dart';

import '../../../../core/network/api_exceptions.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/services/payment_service.dart';
import '../../../../core/data/models/razorpay_order.dart';
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

  // Local cart state - stores product quantities before syncing to backend
  final localCartItems = <int, int>{}.obs; // Map<productId, quantity>

  final isLoadingProducts = false.obs;
  final isLoadingCart = false.obs;
  final isPlacingOrder = false.obs;
  final isSyncingCart = false.obs;
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

      // Initialize local cart items from server cart
      localCartItems.clear();
      if (c != null) {
        for (final item in c.cartItems) {
          localCartItems[item.product.id] = item.quantity;
        }
      }
    } on ApiException catch (e) {
      error.value = e.message;
      AppToast.showError(e.message);
    } finally {
      isLoadingCart.value = false;
    }
  }

  void addToCart(PharmacyProduct product) {
    // Check stock availability
    final currentQty = localCartItems[product.id] ?? 0;
    final newQty = currentQty + 1;

    if (newQty > (product.quantity ?? 0)) {
      AppToast.showError('Only ${product.quantity ?? 0} items available in stock');
      return;
    }

    // Update local cart state only
    localCartItems[product.id] = newQty;
    AppToast.showSuccess('${product.productName} added to cart');
  }

  void incrementItem(PharmacyProduct product) {
    // Check stock availability
    final currentQty = localCartItems[product.id] ?? 0;
    final newQty = currentQty + 1;

    if (newQty > (product.quantity ?? 0)) {
      AppToast.showError('Only ${product.quantity ?? 0} items available in stock');
      return;
    }

    // Update local cart state only
    localCartItems[product.id] = newQty;
    AppToast.showSuccess('Updated to $newQty');
  }

  void decrementItem(PharmacyProduct product) {
    // Update local cart state only
    final currentQty = localCartItems[product.id] ?? 0;
    if (currentQty <= 0) return;

    final newQty = currentQty - 1;
    if (newQty <= 0) {
      localCartItems.remove(product.id);
      AppToast.showInfo('${product.productName} removed from cart');
    } else {
      localCartItems[product.id] = newQty;
      AppToast.showSuccess('Updated to $newQty');
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
      // TODO: Get patient ID from user profile/session
      // For now hardcoded as 1, will be converted to variable later
      final data = await repo.fetchOrders(patientId: 1);
      orders.assignAll(data);
    } on ApiException catch (e) {
      error.value = e.message;
      AppToast.showError(e.message);
    }
  }

  int getQuantity(int productId) {
    // Check local cart first, then fall back to server cart
    if (localCartItems.containsKey(productId)) {
      return localCartItems[productId]!;
    }
    final item = _findCartItem(productId);
    return item?.quantity ?? 0;
  }

  // Get total items count from local cart
  int get totalLocalItems {
    return localCartItems.values.fold<int>(0, (sum, qty) => sum + qty);
  }

  // Check if there are unsaved local changes
  bool get hasLocalChanges {
    return localCartItems.isNotEmpty;
  }

  PharmacyCartItem? _findCartItem(int productId) {
    final c = cart.value;
    if (c == null) return null;
    for (final item in c.cartItems) {
      if (item.product.id == productId) return item;
    }
    return null;
  }

  /// Sync local cart changes to backend
  /// This should be called before viewing cart or proceeding to checkout
  Future<bool> syncCartToBackend() async {
    if (localCartItems.isEmpty) {
      // No local changes, just reload cart from server
      await loadCart();
      return true;
    }

    isSyncingCart.value = true;
    try {
      // First, clear the backend cart to start fresh
      await repo.clearCart();

      // Add all items from local cart to backend
      for (final entry in localCartItems.entries) {
        final productId = entry.key;
        final quantity = entry.value;

        if (quantity > 0) {
          await repo.addItem(
            productId: productId,
            quantity: quantity,
          );
        }
      }

      // Reload cart from backend to get updated totals
      await loadCart();

      AppToast.showSuccess('Cart updated successfully');
      return true;
    } on ApiException catch (e) {
      error.value = e.message;

      // Check if it's a stock error
      if (e.message.toLowerCase().contains('stock')) {
        // Extract stock info from error message
        final match = RegExp(r'Available:\s*(\d+)').firstMatch(e.message);
        if (match != null) {
          final availableStock = int.parse(match.group(1)!);
          AppToast.showError('Insufficient stock! Only $availableStock items available');
        } else {
          AppToast.showError('Insufficient stock: ${e.message}');
        }
      } else {
        AppToast.showError('Failed to sync cart: ${e.message}');
      }
      return false;
    } finally {
      isSyncingCart.value = false;
    }
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

  /// Process Pharmacy Payment with Unified Payment Service
  ///
  /// This method uses the new unified payment API that works across all service types.
  /// It handles the complete payment flow:
  /// 1. Create order on backend
  /// 2. Open Razorpay checkout
  /// 3. Verify payment on backend
  ///
  /// Usage:
  /// ```dart
  /// await controller.processPharmacyPaymentUnified(
  ///   onSuccess: (response) {
  ///     Get.to(() => OrderSuccessPage(orderId: response.orderId));
  ///   },
  ///   onFailure: (error) {
  ///     Get.snackbar('Error', error);
  ///   },
  /// );
  /// ```
  Future<void> processPharmacyPaymentUnified({
    String? notes,
    List<OrderFee>? fees,
    required Function(RazorpayVerificationResponse) onSuccess,
    required Function(String error) onFailure,
  }) async {
    if (cart.value == null || cart.value!.cartItems.isEmpty) {
      onFailure('Cart is empty');
      return;
    }

    isPlacingOrder.value = true;

    try {
      // Get payment service
      if (!Get.isRegistered<PaymentService>()) {
        Get.put(PaymentService());
      }
      final paymentService = Get.find<PaymentService>();

      // TODO: Get patient ID from user profile/session
      // For now hardcoded as 1, will be converted to variable later
      final patientId = 1;

      // Convert cart items to order items
      final orderItems = cart.value!.cartItems.map((cartItem) {
        return OrderItem(
          serviceId: cartItem.product.id,
          contentType: ContentType.pharmacyProduct,
          quantity: cartItem.quantity,
        );
      }).toList();

      // Process payment using unified service
      await paymentService.processPharmacyPayment(
        items: orderItems,
        patientId: patientId,
        fees: fees,
        notes: notes,
        onSuccess: (verificationResponse) async {
          // Reload cart and orders after successful payment
          await loadCart();
          await loadOrders();
          isPlacingOrder.value = false;
          onSuccess(verificationResponse);
        },
        onFailure: (errorMsg) {
          isPlacingOrder.value = false;
          onFailure(errorMsg);
        },
      );
    } catch (e) {
      isPlacingOrder.value = false;
      error.value = e.toString();
      onFailure(e.toString());
    }
  }
}
