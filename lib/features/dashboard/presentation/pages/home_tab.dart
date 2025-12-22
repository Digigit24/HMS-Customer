// File Path: lib/features/dashboard/presentation/pages/home_tab.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/widgets/custom_search_bar.dart';
import '../../../../core/theme/theme_constants.dart';
import '../widgets/dashboard_feature_card.dart';
import '../widgets/appointment_card.dart';
import '../widgets/info_banner.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

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
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'May you always in a good condition',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

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

              const SizedBox(height: 28),

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

              const SizedBox(height: 28),

              // Feature Cards Grid
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 300),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0,
                  children: [
                    // Book an Appointment
                    DashboardFeatureCard(
                      icon: Icons.event_note,
                      iconBackgroundColor: const Color(0xFF6366F1),
                      iconColor: const Color(0xFF6366F1),
                      title: 'Book an\nAppointment',
                      subtitle: 'Find a Doctor or\nspecialist',
                      onTap: () {
                        // TODO: Navigate to booking
                      },
                    ),
                    // Appointment with QR
                    DashboardFeatureCard(
                      icon: Icons.qr_code_2,
                      iconBackgroundColor: const Color(0xFF10B981),
                      iconColor: const Color(0xFF10B981),
                      title: 'Appointment\nwith QR',
                      subtitle: 'Queuing without the\nhustle',
                      onTap: () {
                        // TODO: Navigate to QR scanner
                      },
                    ),
                    // Request Consultation
                    DashboardFeatureCard(
                      icon: Icons.headset_mic,
                      iconBackgroundColor: const Color(0xFFF97316),
                      iconColor: const Color(0xFFF97316),
                      title: 'Request\nConsultation',
                      subtitle: 'Talk to specialist',
                      onTap: () {
                        // TODO: Navigate to consultation
                      },
                    ),
                    // Locate a Pharmacy
                    DashboardFeatureCard(
                      icon: Icons.local_pharmacy,
                      iconBackgroundColor: const Color(0xFFEC4899),
                      iconColor: const Color(0xFFEC4899),
                      title: 'Locate a\nPharmacy',
                      subtitle: 'Purchase Medicines',
                      onTap: () {
                        // TODO: Navigate to pharmacy locator
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

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

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
