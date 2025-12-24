// File Path: lib/features/dashboard/presentation/pages/settings_tab.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/theme/theme_constants.dart';
import '../../../../core/theme/theme_controller.dart';
import 'appointment_history_page.dart';
import 'order_history_page.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeController = Get.find<ThemeController>();
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

              // Header
              FadeInDown(
                duration: const Duration(milliseconds: 400),
                child: Text(
                  'Account',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 28,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Appearance Section
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                child: _SectionCard(
                  title: 'Appearance',
                  children: [
                    // Dark Mode Toggle
                    Obx(() => _SettingItem(
                          icon: Icons.dark_mode_outlined,
                          title: 'Dark Mode',
                          trailing: Switch(
                            value: themeController.isDarkMode,
                            onChanged: (_) => themeController.toggleThemeMode(),
                          ),
                        )),

                    const Divider(height: 1),

                    // Theme Color
                    _SettingItem(
                      icon: Icons.palette_outlined,
                      title: 'Theme Color',
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showThemeColorPicker(context, themeController),
                    ),

                    const Divider(height: 1),

                    // Font Family
                    _SettingItem(
                      icon: Icons.font_download_outlined,
                      title: 'Font Family',
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showFontPicker(context, themeController),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // History Section
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 100),
                child: _SectionCard(
                  title: 'History',
                  children: [
                    _SettingItem(
                      icon: Icons.event_note_outlined,
                      title: 'Appointment History',
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Get.to(() => const AppointmentHistoryPage());
                      },
                    ),
                    const Divider(height: 1),
                    _SettingItem(
                      icon: Icons.receipt_long_outlined,
                      title: 'Order History',
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Get.to(() => const OrderHistoryPage());
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Account Section
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 150),
                child: _SectionCard(
                  title: 'Account',
                  children: [
                    _SettingItem(
                      icon: Icons.person_outline,
                      title: 'Profile',
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    _SettingItem(
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    _SettingItem(
                      icon: Icons.security_outlined,
                      title: 'Privacy & Security',
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Support Section
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 250),
                child: _SectionCard(
                  title: 'Support',
                  children: [
                    _SettingItem(
                      icon: Icons.help_outline,
                      title: 'Help Center',
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    _SettingItem(
                      icon: Icons.feedback_outlined,
                      title: 'Send Feedback',
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    _SettingItem(
                      icon: Icons.info_outline,
                      title: 'About',
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Logout Button
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 350),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () {
                      Get.offAllNamed('/login');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red, width: 1.5),
                    ),
                    child: const Text('Logout'),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _showThemeColorPicker(BuildContext context, ThemeController controller) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _ThemeColorPicker(controller: controller),
    );
  }

  void _showFontPicker(BuildContext context, ThemeController controller) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _FontPicker(controller: controller),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingItem({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: theme.colorScheme.onSurfaceVariant,
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _ThemeColorPicker extends StatelessWidget {
  final ThemeController controller;

  const _ThemeColorPicker({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final colors = [
      {'name': 'Blue', 'color': AppThemeColor.blue, 'value': const Color(0xFF4F46E5)},
      {'name': 'Purple', 'color': AppThemeColor.purple, 'value': const Color(0xFF9333EA)},
      {'name': 'Green', 'color': AppThemeColor.green, 'value': const Color(0xFF059669)},
      {'name': 'Orange', 'color': AppThemeColor.orange, 'value': const Color(0xFFF97316)},
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose Theme Color',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),
          Obx(() => Wrap(
                spacing: 16,
                runSpacing: 16,
                children: colors.map((colorData) {
                  final isSelected = controller.themeColor == colorData['color'];
                  return InkWell(
                    onTap: () {
                      controller.setThemeColor(colorData['color'] as AppThemeColor);
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Container(
                      width: (MediaQuery.of(context).size.width - 80) / 4,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: (colorData['value'] as Color).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: isSelected
                              ? (colorData['value'] as Color)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: colorData['value'] as Color,
                              shape: BoxShape.circle,
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, color: Colors.white, size: 20)
                                : null,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            colorData['name'] as String,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              )),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _FontPicker extends StatelessWidget {
  final ThemeController controller;

  const _FontPicker({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final fonts = [
      {'name': 'Inter', 'font': AppFontFamily.inter},
      {'name': 'Poppins', 'font': AppFontFamily.poppins},
      {'name': 'Roboto', 'font': AppFontFamily.roboto},
      {'name': 'Montserrat', 'font': AppFontFamily.montserrat},
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose Font Family',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),
          Obx(() => Column(
                children: fonts.map((fontData) {
                  final isSelected = controller.fontFamily == fontData['font'];
                  return InkWell(
                    onTap: () {
                      controller.setFontFamily(fontData['font'] as AppFontFamily);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary.withOpacity(0.12)
                            : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FA)),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              fontData['name'] as String,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: theme.colorScheme.primary,
                              size: 22,
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              )),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
