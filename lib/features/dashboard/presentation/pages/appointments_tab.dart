import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../appointments/data/repositories/appointment_repository.dart';
import '../../../appointments/presentation/controller/appointments_controller.dart';
import '../../../../core/network/hms_dio_factory.dart';

class AppointmentsTab extends StatelessWidget {
  const AppointmentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Inject controller once
    final controller = Get.put(
      AppointmentsController(
        repo: AppointmentRepository(
          dio: HmsDioFactory.create(baseUrl: 'https://hms.celiyo.com'),
        ),
      ),
      permanent: false,
    );

    // load once when tab opens
    if (controller.appointments.isEmpty && !controller.isLoading.value) {
      Future.microtask(() => controller.loadAppointments());
    }

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.error.value.isNotEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  controller.error.value,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: controller.loadAppointments,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshList,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.appointments.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final appt = controller.appointments[i];

            final timeText = appt.scheduledAt == null
                ? 'Time not available'
                : appt.scheduledAt!.toLocal().toString();

            return Card(
              child: ListTile(
                title: Text('Status: ${appt.status}'),
                subtitle: Text(timeText),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Later: open details page
                  Get.snackbar('Appointment', 'ID: ${appt.id}');
                },
              ),
            );
          },
        ),
      );
    });
  }
}
