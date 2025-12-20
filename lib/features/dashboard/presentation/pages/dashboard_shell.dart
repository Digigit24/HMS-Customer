import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/app_bottom_nav.dart';
import '../controller/dashboard_controller.dart';
import 'appointments_tab.dart';
import 'home_tab.dart';
import 'pharmacy_tab.dart';
import 'settings_tab.dart';

class DashboardShell extends StatelessWidget {
  const DashboardShell({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(DashboardController());

    final tabs = const [
      HomeTab(),
      AppointmentsTab(),
      PharmacyTab(),
      SettingsTab(),
    ];

    final navItems = const [
      AppBottomNavItem(
          label: 'Home', icon: Icons.home_outlined, activeIcon: Icons.home),
      AppBottomNavItem(
          label: 'Appointments',
          icon: Icons.event_note_outlined,
          activeIcon: Icons.event_note),
      AppBottomNavItem(
          label: 'Pharmacy',
          icon: Icons.local_pharmacy_outlined,
          activeIcon: Icons.local_pharmacy),
      AppBottomNavItem(
          label: 'Settings',
          icon: Icons.settings_outlined,
          activeIcon: Icons.settings),
    ];

    return Obx(() {
      final index = c.currentIndex.value;

      return Scaffold(
        appBar: AppBar(
          title: Text(navItems[index].label),
        ),

        // ✅ Keeps tab state alive. No full refresh.
        body: IndexedStack(
          index: index,
          children: tabs,
        ),

        bottomNavigationBar: AppBottomNav(
          currentIndex: index,
          items: navItems,
          onChanged: c.setTab,
        ),
      );
    });
  }
}
