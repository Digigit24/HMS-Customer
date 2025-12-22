// File Path: lib/features/dashboard/presentation/pages/dashboard_shell.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/app_bottom_nav.dart';
import '../controller/dashboard_controller.dart';
import 'appointments_tab.dart';
import 'chat_tab.dart';
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
      ChatTab(),
      SettingsTab(),
    ];

    final navItems = const [
      AppBottomNavItem(
        label: 'Home',
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
      ),
      AppBottomNavItem(
        label: 'Calendar',
        icon: Icons.event_note_outlined,
        activeIcon: Icons.event_note,
      ),
      AppBottomNavItem(
        label: 'History',
        icon: Icons.receipt_long_outlined,
        activeIcon: Icons.receipt_long,
      ),
      AppBottomNavItem(
        label: 'Chat',
        icon: Icons.chat_bubble_outline,
        activeIcon: Icons.chat_bubble,
      ),
      AppBottomNavItem(
        label: 'Account',
        icon: Icons.person_outline,
        activeIcon: Icons.person,
      ),
    ];

    return Obx(() {
      final index = c.currentIndex.value;

      return Scaffold(
        // Only show AppBar for non-home tabs
        appBar: index == 0
            ? null
            : AppBar(
                title: Text(navItems[index].label),
              ),

        // Keeps tab state alive. No full refresh.
        body: IndexedStack(
          index: index,
          children: tabs,
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Navigate to book appointment screen
            Get.toNamed('/book-appointment');
          },
          backgroundColor: const Color(0xFF2196F3),
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 32,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        bottomNavigationBar: AppBottomNav(
          currentIndex: index,
          items: navItems,
          onChanged: c.setTab,
        ),
      );
    });
  }
}
