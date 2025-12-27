// File Path: lib/features/dashboard/presentation/pages/home_tab.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/widgets/custom_search_bar.dart';
import '../../../../core/theme/theme_constants.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../appointments/presentation/controller/appointments_controller.dart';
import '../widgets/dashboard_feature_card.dart';
import '../widgets/appointment_card.dart';
import '../widgets/info_banner.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  void initState() {
    super.initState();
    // Load upcoming appointments
    try {
      Get.find<AppointmentsController>().loadAppointments();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: context.padding(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: context.spacing(16)),

              // Header - Greeting
              FadeInDown(
                duration: const Duration(milliseconds: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi Dwiky!',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: context.fontSize(20),
                      ),
                    ),
                    SizedBox(height: context.spacing(4)),
                    Text(
                      'May you always in a good condition',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: context.fontSize(13),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: context.spacing(16)),

              // Search Bar with Filter
              FadeInDown(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 100),
                child: CustomSearchBar(
                  hintText: 'symptoms, diseases...',
                  showFilter: true,
                  onFilterTap: () {
                    // TODO: Implement filter
                  },
                ),
              ),

              SizedBox(height: context.spacing(16)),

              // Upcoming Appointment Card
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 200),
                child: AppointmentCard(
                  doctorName: 'Dr. Stone Gaze',
                  specialty: 'Ear, Nose & Throat specialist',
                  imageUrl: 'assets/images/1.png',
                  date: 'Wed, 10 Jan, 2024',
                  time: 'Morning set: 11:00',
                  onTap: () {
                    // TODO: Navigate to appointment details
                  },
                  onMessageTap: () {
                    // TODO: Open chat
                  },
                ),
              ),

              SizedBox(height: context.spacing(16)),

              // Feature Cards Grid
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 300),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: context.spacing(12),
                  mainAxisSpacing: context.spacing(12),
                  childAspectRatio: 1.1,
                  children: [
                    // Book Appointment
                    DashboardFeatureCard(
                      icon: Icons.event_note,
                      iconBackgroundColor: const Color(0xFF6366F1),
                      iconColor: const Color(0xFF6366F1),
                      title: 'Book Appointment',
                      subtitle: 'Find a Doctor or specialist',
                      onTap: () {
                        // TODO: Navigate to booking
                      },
                    ),
                    // Appointment History
                    DashboardFeatureCard(
                      icon: Icons.history,
                      iconBackgroundColor: const Color(0xFF10B981),
                      iconColor: const Color(0xFF10B981),
                      title: 'Appointment History',
                      subtitle: 'View past appointments',
                      onTap: () {
                        // TODO: Navigate to appointment history
                      },
                    ),
                    // Pharmacy
                    DashboardFeatureCard(
                      icon: Icons.local_pharmacy,
                      iconBackgroundColor: const Color(0xFFF97316),
                      iconColor: const Color(0xFFF97316),
                      title: 'Pharmacy',
                      subtitle: 'Purchase Medicines',
                      onTap: () {
                        // TODO: Navigate to pharmacy
                      },
                    ),
                    // Order History
                    DashboardFeatureCard(
                      icon: Icons.shopping_bag,
                      iconBackgroundColor: const Color(0xFFEC4899),
                      iconColor: const Color(0xFFEC4899),
                      title: 'Order History',
                      subtitle: 'View past orders',
                      onTap: () {
                        // TODO: Navigate to order history
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: context.spacing(16)),

              // Info Banner - COVID Prevention
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 400),
                child: InfoBanner(
                  title: 'Prevent the spread\nof COVID-19 Virus',
                  subtitle: 'Find out how',
                  icon: Icons.coronavirus_outlined,
                  backgroundColor: const Color(0xFF4F46E5),
                  iconColor: Colors.white.withOpacity(0.3),
                  onTap: () {
                    // TODO: Navigate to COVID info
                  },
                ),
              ),

              SizedBox(height: context.spacing(20)),
            ],
          ),
        ),
      ),
    );
  }
}
