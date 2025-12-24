import 'dart:convert';

import 'package:dio/dio.dart';
import '../storage/token_storage.dart';

class HmsDioFactory {
  HmsDioFactory._();

  static Dio create({required String baseUrl}) {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl, // バ. should be https://hms.celiyo.com
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'accept': 'application/json, text/plain, */*',
        'accept-encoding': 'gzip, deflate, br, zstd',
        'accept-language': 'en-US,en;q=0.9',
        'connection': 'keep-alive',
        'origin': 'https://admin.gorehospital.com',
        'referer': 'https://admin.gorehospital.com/',
        'sec-fetch-dest': 'empty',
        'sec-fetch-mode': 'cors',
        'sec-fetch-site': 'cross-site',
        'sec-ch-ua':
            '"Google Chrome";v="143", "Chromium";v="143", "Not A(Brand";v="24"',
        'sec-ch-ua-mobile': '?1',
        'sec-ch-ua-platform': '"Android"',
        'user-agent':
            'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36',
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final storage = TokenStorage.instance;

        final values = await Future.wait([
          storage.getAccessToken(),
          storage.getTenantId(),
          storage.getTenantSlug(),
          storage.getTenantToken(),
        ]);

        final token = values[0] as String?;
        String? tenantId = values[1] as String?;
        String? tenantSlug = values[2] as String?;
        String? tenantToken = values[3] as String?;

        if ((tenantId == null || tenantSlug == null) &&
            token != null &&
            token.isNotEmpty) {
          final claims = _decodeClaims(token);
          tenantId ??= claims['tenant_id']?.toString();
          tenantSlug ??= claims['tenant_slug']?.toString();
        }

        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        if (tenantId != null && tenantId.isNotEmpty) {
          options.headers['x-tenant-id'] = tenantId;
          options.headers['tenanttoken'] =
              (tenantToken != null && tenantToken.isNotEmpty)
                  ? tenantToken
                  : tenantId;
        }

        if (tenantSlug != null && tenantSlug.isNotEmpty) {
          options.headers['x-tenant-slug'] = tenantSlug;
        }

        options.headers.putIfAbsent(
            'accept', () => 'application/json, text/plain, */*');
        options.headers.putIfAbsent(
            'accept-encoding', () => 'gzip, deflate, br, zstd');
        options.headers.putIfAbsent(
            'accept-language', () => 'en-US,en;q=0.9');
        options.headers.putIfAbsent('connection', () => 'keep-alive');
        options.headers.putIfAbsent(
            'origin', () => 'https://admin.gorehospital.com');
        options.headers.putIfAbsent(
            'referer', () => 'https://admin.gorehospital.com/');
        options.headers.putIfAbsent('sec-fetch-dest', () => 'empty');
        options.headers.putIfAbsent('sec-fetch-mode', () => 'cors');
        options.headers.putIfAbsent('sec-fetch-site', () => 'cross-site');
        options.headers.putIfAbsent('sec-ch-ua',
            () => '"Google Chrome";v="143", "Chromium";v="143", "Not A(Brand";v="24"');
        options.headers.putIfAbsent('sec-ch-ua-mobile', () => '?1');
        options.headers.putIfAbsent('sec-ch-ua-platform', () => '"Android"');
        options.headers.putIfAbsent('user-agent',
            () => 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36');

        return handler.next(options);
      },
    ));

    dio.interceptors
        .add(LogInterceptor(requestBody: true, responseBody: true));
    return dio;
  }
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
