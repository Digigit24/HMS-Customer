import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../auth/presentation/controller/auth_controller.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            onPressed: () => c.logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: const Center(
        child: Text('Logged in ✅\nNo data fetched yet.'),
      ),
    );
  }
}
