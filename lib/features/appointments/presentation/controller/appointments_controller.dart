import 'package:get/get.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/utils/app_toast.dart';
import '../../data/models/appointment.dart';
import '../../data/models/doctor.dart';
import '../../data/repositories/appointment_repository.dart';

class AppointmentsController extends GetxController {
  final AppointmentRepository repo;
  AppointmentsController({required this.repo});

  final isLoading = false.obs;
  final error = ''.obs;
  final appointments = <Appointment>[].obs;
  final todayAppointments = <Appointment>[].obs;
  final upcomingAppointments = <Appointment>[].obs;
  final statistics = <String, dynamic>{}.obs;
  final doctors = <Doctor>[].obs;
  final isLoadingDoctors = false.obs;

  Future<void> loadAppointments() async {
    isLoading.value = true;
    error.value = '';
    try {
      final list = await repo.list();
      appointments.assignAll(list);
    } on ApiException catch (e) {
      error.value = e.message;
      AppToast.showError(e.message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadTodayAppointments() async {
    try {
      final list = await repo.today();
      todayAppointments.assignAll(list);
    } on ApiException catch (e) {
      error.value = e.message;
      AppToast.showError(e.message);
    }
  }

  Future<void> loadUpcomingAppointments() async {
    try {
      final list = await repo.upcoming();
      upcomingAppointments.assignAll(list);
    } on ApiException catch (e) {
      error.value = e.message;
      AppToast.showError(e.message);
    }
  }

  Future<void> loadStatistics() async {
    try {
      final stats = await repo.statistics();
      statistics.assignAll(stats);
    } on ApiException catch (e) {
      error.value = e.message;
      AppToast.showError(e.message);
    }
  }

  Future<void> loadDoctors() async {
    isLoadingDoctors.value = true;
    try {
      final list = await repo.fetchDoctors();
      doctors.assignAll(list);
    } on ApiException catch (e) {
      error.value = e.message;
      AppToast.showError(e.message);
    } finally {
      isLoadingDoctors.value = false;
    }
  }

  Future<Appointment?> getAppointmentById(int id) async {
    try {
      return await repo.getById(id.toString());
    } on ApiException catch (e) {
      error.value = e.message;
      AppToast.showError(e.message);
      return null;
    }
  }

  Future<bool> createAppointment(Map<String, dynamic> payload) async {
    try {
      await repo.create(payload);
      await loadAppointments(); // Refresh list
      AppToast.showSuccess('Appointment created');
      return true;
    } on ApiException catch (e) {
      error.value = e.message;
      AppToast.showError(e.message);
      return false;
    }
  }

  Future<bool> updateAppointment(int id, Map<String, dynamic> payload) async {
    try {
      await repo.update(id.toString(), payload);
      await loadAppointments(); // Refresh list
      AppToast.showSuccess('Appointment updated');
      return true;
    } on ApiException catch (e) {
      error.value = e.message;
      AppToast.showError(e.message);
      return false;
    }
  }

  Future<bool> cancelAppointment(int id) async {
    try {
      await repo.cancel(id.toString());
      await loadAppointments(); // Refresh list
      AppToast.showSuccess('Appointment cancelled successfully');
      return true;
    } on ApiException catch (e) {
      error.value = e.message;
      AppToast.showError(e.message);
      return false;
    }
  }

  Future<bool> checkInAppointment(int id) async {
    try {
      await repo.checkIn(id.toString());
      await loadAppointments(); // Refresh list
      AppToast.showSuccess('Checked in successfully');
      return true;
    } on ApiException catch (e) {
      error.value = e.message;
      AppToast.showError(e.message);
      return false;
    }
  }

  Future<bool> startAppointment(int id) async {
    try {
      await repo.start(id.toString());
      await loadAppointments(); // Refresh list
      AppToast.showSuccess('Appointment started');
      return true;
    } on ApiException catch (e) {
      error.value = e.message;
      AppToast.showError(e.message);
      return false;
    }
  }

  Future<bool> completeAppointment(int id) async {
    try {
      await repo.complete(id.toString());
      await loadAppointments(); // Refresh list
      AppToast.showSuccess('Appointment completed');
      return true;
    } on ApiException catch (e) {
      error.value = e.message;
      AppToast.showError(e.message);
      return false;
    }
  }

  Future<void> refreshList() async {
    await loadAppointments();
  }
}
