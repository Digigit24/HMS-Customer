// File Path: lib/core/utils/responsive_utils.dart

import 'package:flutter/material.dart';

class ResponsiveUtils {
  /// Get responsive font size based on screen width
  static double getFontSize(BuildContext context, double baseFontSize) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Base width for design (e.g., iPhone 14 Pro)
    const double baseWidth = 390.0;

    // Calculate scale factor
    final double scaleFactor = screenWidth / baseWidth;

    // Clamp the scale factor to avoid extreme sizing
    final double clampedScale = scaleFactor.clamp(0.85, 1.3);

    return baseFontSize * clampedScale;
  }

  /// Get responsive icon size
  static double getIconSize(BuildContext context, double baseIconSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double baseWidth = 390.0;
    final double scaleFactor = screenWidth / baseWidth;
    final double clampedScale = scaleFactor.clamp(0.85, 1.2);

    return baseIconSize * clampedScale;
  }

  /// Get responsive padding
  static double getPadding(BuildContext context, double basePadding) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double baseWidth = 390.0;
    final double scaleFactor = screenWidth / baseWidth;
    final double clampedScale = scaleFactor.clamp(0.9, 1.2);

    return basePadding * clampedScale;
  }

  /// Get responsive spacing
  static double getSpacing(BuildContext context, double baseSpacing) {
    return getPadding(context, baseSpacing);
  }

  /// Get screen width
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Check if screen is small (< 360dp)
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 360;
  }

  /// Check if screen is medium (360-600dp)
  static bool isMediumScreen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 360 && width < 600;
  }

  /// Check if screen is large (>= 600dp)
  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600;
  }

  /// Get responsive value based on screen size
  static T getResponsiveValue<T>(
    BuildContext context, {
    required T small,
    T? medium,
    T? large,
  }) {
    if (isLargeScreen(context) && large != null) return large;
    if (isMediumScreen(context) && medium != null) return medium;
    return small;
  }

  /// Get safe area padding top
  static double getSafeAreaTop(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  /// Get safe area padding bottom
  static double getSafeAreaBottom(BuildContext context) {
    return MediaQuery.of(context).padding.bottom;
  }
}

/// Extension on BuildContext for easier access
extension ResponsiveContext on BuildContext {
  double fontSize(double size) => ResponsiveUtils.getFontSize(this, size);
  double iconSize(double size) => ResponsiveUtils.getIconSize(this, size);
  double padding(double size) => ResponsiveUtils.getPadding(this, size);
  double spacing(double size) => ResponsiveUtils.getSpacing(this, size);
  double get screenWidth => ResponsiveUtils.getScreenWidth(this);
  double get screenHeight => ResponsiveUtils.getScreenHeight(this);
  bool get isSmallScreen => ResponsiveUtils.isSmallScreen(this);
  bool get isMediumScreen => ResponsiveUtils.isMediumScreen(this);
  bool get isLargeScreen => ResponsiveUtils.isLargeScreen(this);
  double get safeAreaTop => ResponsiveUtils.getSafeAreaTop(this);
  double get safeAreaBottom => ResponsiveUtils.getSafeAreaBottom(this);
}
