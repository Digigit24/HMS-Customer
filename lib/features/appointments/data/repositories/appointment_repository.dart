import 'package:dio/dio.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/appointment.dart';
import '../models/doctor.dart';

class AppointmentRepository {
  final Dio dio;
  AppointmentRepository({required this.dio});

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

  // GET /api/appointments/
  Future<List<Appointment>> list() async {
    try {
      final res = await dio.get(
        '/api/appointments/',
        options: await _authOptions(),
      );
      final data = res.data;

      if (data is List) {
        return data
            .map((e) => Appointment.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }

      // some APIs return {results: []}
      if (data is Map && data['results'] is List) {
        final items = (data['results'] as List);
        return items
            .map((e) => Appointment.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }

      throw ApiException('Unexpected appointments response format');
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?.toString() ?? 'Failed to load appointments',
        statusCode: e.response?.statusCode,
      );
    }
  }

  // GET /api/appointments/{id}/
  Future<Appointment> getById(String id) async {
    try {
      final res = await dio.get(
        '/api/appointments/$id/',
        options: await _authOptions(),
      );
      return Appointment.fromJson(Map<String, dynamic>.from(res.data));
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?.toString() ?? 'Failed to load appointment',
        statusCode: e.response?.statusCode,
      );
    }
  }

  // POST /api/appointments/
  Future<Appointment> create(Map<String, dynamic> payload) async {
    try {
      final res = await dio.post(
        '/api/appointments/',
        data: payload,
        options: await _authOptions(),
      );
      return Appointment.fromJson(Map<String, dynamic>.from(res.data));
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?.toString() ?? 'Failed to create appointment',
        statusCode: e.response?.statusCode,
      );
    }
  }

  // PUT /api/appointments/{id}/
  Future<Appointment> update(String id, Map<String, dynamic> payload) async {
    try {
      final res = await dio.put(
        '/api/appointments/$id/',
        data: payload,
        options: await _authOptions(),
      );
      return Appointment.fromJson(Map<String, dynamic>.from(res.data));
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?.toString() ?? 'Failed to update appointment',
        statusCode: e.response?.statusCode,
      );
    }
  }

  // PATCH /api/appointments/{id}/
  Future<Appointment> patch(String id, Map<String, dynamic> payload) async {
    try {
      final res = await dio.patch(
        '/api/appointments/$id/',
        data: payload,
        options: await _authOptions(),
      );
      return Appointment.fromJson(Map<String, dynamic>.from(res.data));
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?.toString() ?? 'Failed to update appointment',
        statusCode: e.response?.statusCode,
      );
    }
  }

  // DELETE /api/appointments/{id}/
  Future<void> cancel(String id) async {
    try {
      await dio.delete(
        '/api/appointments/$id/',
        options: await _authOptions(),
      );
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?.toString() ?? 'Failed to cancel appointment',
        statusCode: e.response?.statusCode,
      );
    }
  }

  // POST /api/appointments/{id}/check_in/
  Future<void> checkIn(String id) async {
    try {
      await dio.post(
        '/api/appointments/$id/check_in/',
        options: await _authOptions(),
      );
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?.toString() ?? 'Failed to check-in',
        statusCode: e.response?.statusCode,
      );
    }
  }

  // POST /api/appointments/{id}/start/
  Future<void> start(String id) async {
    try {
      await dio.post(
        '/api/appointments/$id/start/',
        options: await _authOptions(),
      );
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?.toString() ?? 'Failed to start appointment',
        statusCode: e.response?.statusCode,
      );
    }
  }

  // POST /api/appointments/{id}/complete/
  Future<void> complete(String id) async {
    try {
      await dio.post(
        '/api/appointments/$id/complete/',
        options: await _authOptions(),
      );
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?.toString() ?? 'Failed to complete appointment',
        statusCode: e.response?.statusCode,
      );
    }
  }

  // GET /api/appointments/today/
  Future<List<Appointment>> today() async {
    try {
      final res = await dio.get(
        '/api/appointments/today/',
        options: await _authOptions(),
      );
      final data = res.data;
      if (data is List) {
        return data
            .map((e) => Appointment.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      if (data is Map && data['results'] is List) {
        final items = (data['results'] as List);
        return items
            .map((e) => Appointment.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      throw ApiException('Unexpected today appointments format');
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?.toString() ?? 'Failed to load today appointments',
        statusCode: e.response?.statusCode,
      );
    }
  }

  // GET /api/appointments/upcoming/
  Future<List<Appointment>> upcoming() async {
    try {
      final res = await dio.get(
        '/api/appointments/upcoming/',
        options: await _authOptions(),
      );
      final data = res.data;
      if (data is List) {
        return data
            .map((e) => Appointment.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      if (data is Map && data['results'] is List) {
        final items = (data['results'] as List);
        return items
            .map((e) => Appointment.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      throw ApiException('Unexpected upcoming appointments format');
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?.toString() ?? 'Failed to load upcoming appointments',
        statusCode: e.response?.statusCode,
      );
    }
  }

  // GET /api/appointments/statistics/
  Future<Map<String, dynamic>> statistics() async {
    try {
      final res = await dio.get(
        '/api/appointments/statistics/',
        options: await _authOptions(),
      );
      if (res.data is Map) return Map<String, dynamic>.from(res.data);
      throw ApiException('Unexpected statistics format');
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?.toString() ?? 'Failed to load statistics',
        statusCode: e.response?.statusCode,
      );
    }
  }

  // GET /api/doctors/ (assumed endpoint)
  Future<List<Doctor>> fetchDoctors({int page = 1}) async {
    try {
      final res = await dio.get(
        '/api/doctors/profiles/',
        queryParameters: {'page': page},
        options: await _authOptions(),
      );
      final data = res.data;
      final List items;
      if (data is Map && data['results'] is List) {
        items = data['results'];
      } else if (data is List) {
        items = data;
      } else {
        throw ApiException('Unexpected doctors response format');
      }

      return items
          .map((e) => Doctor.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?.toString() ?? 'Failed to load doctors',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
