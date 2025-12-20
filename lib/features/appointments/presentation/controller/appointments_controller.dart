import 'package:get/get.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../data/models/appointment.dart';
import '../../data/repositories/appointment_repository.dart';

class AppointmentsController extends GetxController {
  final AppointmentRepository repo;
  AppointmentsController({required this.repo});

  final isLoading = false.obs;
  final error = ''.obs;
  final appointments = <Appointment>[].obs;

  Future<void> loadAppointments() async {
    isLoading.value = true;
    error.value = '';
    try {
      final list = await repo.list();
      appointments.assignAll(list);
    } on ApiException catch (e) {
      error.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshList() async {
    await loadAppointments();
  }
}
