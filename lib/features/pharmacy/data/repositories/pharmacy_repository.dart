import 'package:dio/dio.dart';

import 'package:dio/dio.dart';

import '../../../../core/network/api_exceptions.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/cart.dart';
import '../models/category.dart';
import '../models/order.dart';
import '../models/product.dart';

class PharmacyRepository {
  final Dio dio;
  PharmacyRepository({required this.dio});

  Future<void> _ensureAuthHeader() async {
    final token = await TokenStorage.instance.getAccessToken();
    if (token != null && token.isNotEmpty) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  Future<Options> _authOptions() async {
    final token = await TokenStorage.instance.getAccessToken();
    if (token == null || token.isEmpty) {
      throw ApiException('Not authenticated');
    }

    final tenantId = await TokenStorage.instance.getTenantId();
    final tenantSlug = await TokenStorage.instance.getTenantSlug();
    final tenantToken = await TokenStorage.instance.getTenantToken();

    final headers = <String, dynamic>{
      'Authorization': 'Bearer $token',
    };

    if (tenantId != null && tenantId.isNotEmpty) {
      headers['x-tenant-id'] = tenantId;
      headers['tenanttoken'] =
          (tenantToken != null && tenantToken.isNotEmpty) ? tenantToken : tenantId;
    }
    if (tenantSlug != null && tenantSlug.isNotEmpty) {
      headers['x-tenant-slug'] = tenantSlug;
    }

    return Options(headers: headers);
  }

  Future<List<PharmacyProduct>> fetchProducts() async {
    try {
      await _ensureAuthHeader();
      final res = await dio.get(
        '/api/pharmacy/products/',
        options: await _authOptions(),
      );
      final data = res.data;
      final List items;
      if (data is List) {
        items = data;
      } else if (data is Map && data['results'] is List) {
        items = data['results'];
      } else {
        throw ApiException('Unexpected products format');
      }
      return items
          .map((e) => PharmacyProduct.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      await _handleAuthError(e);
      throw ApiException(
        e.response?.data?.toString() ?? 'Failed to load products',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<List<PharmacyCategory>> fetchCategories() async {
    try {
      await _ensureAuthHeader();
      final res = await dio.get(
        '/api/pharmacy/categories/',
        options: await _authOptions(),
      );
      final data = res.data;
      final List items;
      if (data is List) {
        items = data;
      } else if (data is Map && data['results'] is List) {
        items = data['results'];
      } else {
        throw ApiException('Unexpected categories format');
      }
      return items
          .map((e) => PharmacyCategory.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      await _handleAuthError(e);
      throw ApiException(
        e.response?.data?.toString() ?? 'Failed to load categories',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<PharmacyCart> fetchCart() async {
    try {
      await _ensureAuthHeader();
      final res = await dio.get(
        '/api/pharmacy/cart/',
        options: await _authOptions(),
      );
      final data = res.data;
      if (data is List && data.isNotEmpty) {
        return PharmacyCart.fromJson(Map<String, dynamic>.from(data.first));
      }
      if (data is Map && data['results'] is List && data['results'].isNotEmpty) {
        return PharmacyCart.fromJson(
          Map<String, dynamic>.from(data['results'].first),
        );
      }
      if (data is Map) {
        return PharmacyCart.fromJson(Map<String, dynamic>.from(data));
      }
      throw ApiException('Unexpected cart format');
    } on DioException catch (e) {
      await _handleAuthError(e);
      throw ApiException(
        e.response?.data?.toString() ?? 'Failed to load cart',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<PharmacyCart> addItem({
    required int productId,
    required int quantity,
  }) async {
    try {
      await _ensureAuthHeader();
      final res = await dio.post(
        '/api/pharmacy/cart/add_item/',
        data: {
          'product_id': productId,
          'quantity': quantity,
        },
        options: await _authOptions(),
      );
      return PharmacyCart.fromJson(Map<String, dynamic>.from(res.data));
    } on DioException catch (e) {
      await _handleAuthError(e);
      throw ApiException(
        e.response?.data?.toString() ?? 'Failed to add item',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<PharmacyCart> updateItem({
    required int cartItemId,
    required int quantity,
  }) async {
    try {
      await _ensureAuthHeader();
      final res = await dio.post(
        '/api/pharmacy/cart/update_item/',
        data: {
          'cart_item_id': cartItemId,
          'quantity': quantity,
        },
        options: await _authOptions(),
      );
      return PharmacyCart.fromJson(Map<String, dynamic>.from(res.data));
    } on DioException catch (e) {
      await _handleAuthError(e);
      throw ApiException(
        e.response?.data?.toString() ?? 'Failed to update item',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<PharmacyCart> removeItem({
    required int cartItemId,
  }) async {
    try {
      await _ensureAuthHeader();
      final res = await dio.post(
        '/api/pharmacy/cart/remove_item/',
        data: {
          'cart_item_id': cartItemId,
        },
        options: await _authOptions(),
      );
      return PharmacyCart.fromJson(Map<String, dynamic>.from(res.data));
    } on DioException catch (e) {
      await _handleAuthError(e);
      throw ApiException(
        e.response?.data?.toString() ?? 'Failed to remove item',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<PharmacyCart> clearCart() async {
    try {
      await _ensureAuthHeader();
      final res = await dio.post(
        '/api/pharmacy/cart/clear/',
        options: await _authOptions(),
      );
      return PharmacyCart.fromJson(Map<String, dynamic>.from(res.data));
    } on DioException catch (e) {
      await _handleAuthError(e);
      throw ApiException(
        e.response?.data?.toString() ?? 'Failed to clear cart',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<PharmacyOrder> createOrder({Map<String, dynamic>? payload}) async {
    try {
      await _ensureAuthHeader();
      final res = await dio.post(
        '/api/pharmacy/orders/',
        data: payload ?? {},
        options: await _authOptions(),
      );
      return PharmacyOrder.fromJson(Map<String, dynamic>.from(res.data));
    } on DioException catch (e) {
      await _handleAuthError(e);
      throw ApiException(
        e.response?.data?.toString() ?? 'Failed to place order',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<List<PharmacyOrder>> fetchOrders() async {
    try {
      await _ensureAuthHeader();
      final res = await dio.get(
        '/api/pharmacy/orders/',
        options: await _authOptions(),
      );
      final data = res.data;
      final List items;
      if (data is List) {
        items = data;
      } else if (data is Map && data['results'] is List) {
        items = data['results'];
      } else {
        throw ApiException('Unexpected orders format');
      }
      return items
          .map((e) => PharmacyOrder.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      await _handleAuthError(e);
      throw ApiException(
        e.response?.data?.toString() ?? 'Failed to load orders',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<void> _handleAuthError(DioException e) async {
    if (e.response?.statusCode == 401) {
      await TokenStorage.instance.clear();
      throw ApiException('Session expired. Please login again.', statusCode: 401);
    }
  }
}
