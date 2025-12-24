import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  TokenStorage._();
  static final TokenStorage instance = TokenStorage._();

  static const _storage = FlutterSecureStorage();
  static final Map<String, String> _memoryFallback = {};
  static final _prefsFuture = SharedPreferences.getInstance();

  static const _kAccessToken = 'access_token';
  static const _kRefreshToken = 'refresh_token';
  static const _kTenantId = 'tenant_id';
  static const _kTenantSlug = 'tenant_slug';
  static const _kTenantToken = 'tenant_token';
  static const _kUserId = 'user_id';

  /// Preload tokens from secure storage into memory.
  /// Call this early (e.g., in main) to avoid missing tokens after app restart.
  Future<void> preload() async {
    final keys = [
      _kAccessToken,
      _kRefreshToken,
      _kTenantId,
      _kTenantSlug,
      _kTenantToken,
    ];

    for (final key in keys) {
      final val = await _safeRead(key);
      if (val != null) {
        _memoryFallback[key] = val;
      }
    }
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    String? tenantId,
    String? tenantSlug,
    String? tenantToken,
    String? userId,
  }) async {
    final writes = <Future<void>>[
      _safeWrite(_kAccessToken, accessToken),
      _safeWrite(_kRefreshToken, refreshToken),
    ];

    if (tenantId != null) {
      writes.add(_safeWrite(_kTenantId, tenantId));
    }
    if (tenantSlug != null) {
      writes.add(_safeWrite(_kTenantSlug, tenantSlug));
    }
    if (tenantToken != null) {
      writes.add(_safeWrite(_kTenantToken, tenantToken));
    }
    if (userId != null) {
      writes.add(_safeWrite(_kUserId, userId));
    }

    await Future.wait(writes);
  }

  Future<String?> getAccessToken() => _safeRead(_kAccessToken);
  Future<String?> getRefreshToken() => _safeRead(_kRefreshToken);
  Future<String?> getTenantId() => _safeRead(_kTenantId);
  Future<String?> getTenantSlug() => _safeRead(_kTenantSlug);
  Future<String?> getTenantToken() => _safeRead(_kTenantToken);

  Future<void> clear() async {
    await _safeDelete(_kAccessToken);
    await _safeDelete(_kRefreshToken);
    await _safeDelete(_kTenantId);
    await _safeDelete(_kTenantSlug);
    await _safeDelete(_kTenantToken);
    await _safeDelete(_kUserId);
    _memoryFallback.clear();
  }

  Future<String?> getUserId() => _safeRead(_kUserId);

  Future<String?> _safeRead(String key) async {
    final prefs = await _prefsFuture;

    if (kIsWeb) {
      final val = prefs.getString(key);
      return val ?? _memoryFallback[key];
    }

    try {
      final value = await _storage.read(key: key);
      if (value != null) return value;
    } catch (_) {
      // ignore secure storage errors
    }

    final val = prefs.getString(key);
    return val ?? _memoryFallback[key];
  }

  Future<void> _safeWrite(String key, String value) async {
    _memoryFallback[key] = value;
    final prefs = await _prefsFuture;
    await prefs.setString(key, value);

    if (kIsWeb) return;
    try {
      await _storage.write(key: key, value: value);
    } catch (_) {
      // Swallow errors on web/insecure contexts; shared_prefs + memory will keep us going.
    }
  }

  Future<void> _safeDelete(String key) async {
    _memoryFallback.remove(key);
    final prefs = await _prefsFuture;
    await prefs.remove(key);

    if (kIsWeb) return;
    try {
      await _storage.delete(key: key);
    } catch (_) {
      // ignore
    }
  }
}
