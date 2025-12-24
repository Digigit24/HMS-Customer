import 'dart:convert';

class LoginResponse {
  final String access;
  final String refresh;
  final String? message;
  final String? tenantId;
  final String? tenantSlug;
  final String? tenantToken;
  final String? userId;

  LoginResponse({
    required this.access,
    required this.refresh,
    this.message,
    this.tenantId,
    this.tenantSlug,
    this.tenantToken,
    this.userId,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final tokens = (json['tokens'] is Map)
        ? Map<String, dynamic>.from(json['tokens'])
        : {};

    final access = (tokens['access'] ?? '').toString().trim();
    final refresh = (tokens['refresh'] ?? '').toString().trim();
    final user = (json['user'] is Map)
        ? Map<String, dynamic>.from(json['user'])
        : const <String, dynamic>{};
    final claims = _decodeClaims(access);

    String? tenantId = _asString(
      json['tenant_id'] ?? json['tenant'] ?? user['tenant'],
    );

    String? tenantSlug = _asString(
      json['tenant_slug'] ??
          user['tenant_slug'] ??
          user['tenant_name'] ??
          tokens['tenant_slug'],
    );

    String? tenantToken = _asString(
      json['tenanttoken'] ??
          json['tenant_token'] ??
          user['tenanttoken'] ??
          tokens['tenanttoken'],
    );

    tenantId ??= _asString(claims['tenant_id']);
    tenantSlug ??= _asString(claims['tenant_slug']);
    tenantToken ??= tenantId;

    final userId = _asString(
      json['user_id'] ??
          user['id'] ??
          user['user_id'] ??
          claims['user_id'] ??
          claims['sub'],
    );

    return LoginResponse(
      message: json['message']?.toString(),
      access: access,
      refresh: refresh,
      tenantId: tenantId,
      tenantSlug: tenantSlug,
      tenantToken: tenantToken,
      userId: userId,
    );
  }
}

String? _asString(dynamic value) {
  if (value == null) return null;
  final str = value.toString().trim();
  return str.isEmpty ? null : str;
}

Map<String, dynamic> _decodeClaims(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return {};

    final payload = parts[1];
    final normalized =
        payload.padRight(payload.length + (4 - payload.length % 4) % 4, '=');
    final bytes = base64Url.decode(normalized);
    return Map<String, dynamic>.from(json.decode(utf8.decode(bytes)));
  } catch (_) {
    return {};
  }
}
