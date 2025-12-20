import 'package:dio/dio.dart';
import '../../../../core/network/api_exceptions.dart';
import '../models/appointment.dart';

class AppointmentRepository {
  final Dio dio;
  AppointmentRepository({required this.dio});

  // GET /api/appointments/
  Future<List<Appointment>> list() async {
    try {
      final res = await dio.get('/api/appointments/');
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
      final res = await dio.get('/api/appointments/$id/');
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
      final res = await dio.post('/api/appointments/', data: payload);
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
      final res = await dio.put('/api/appointments/$id/', data: payload);
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
      final res = await dio.patch('/api/appointments/$id/', data: payload);
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
      await dio.delete('/api/appointments/$id/');
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
      await dio.post('/api/appointments/$id/check_in/');
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
      await dio.post('/api/appointments/$id/start/');
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
      await dio.post('/api/appointments/$id/complete/');
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
      final res = await dio.get('/api/appointments/today/');
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
      final res = await dio.get('/api/appointments/upcoming/');
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
      final res = await dio.get('/api/appointments/statistics/');
      if (res.data is Map) return Map<String, dynamic>.from(res.data);
      throw ApiException('Unexpected statistics format');
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?.toString() ?? 'Failed to load statistics',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
