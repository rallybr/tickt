import 'package:flutter/material.dart';

class ResponsiveUtils {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  static double getScreenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double getScreenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static double getAdaptiveFontSize(BuildContext context, double baseSize) {
    double screenWidth = getScreenWidth(context);
    if (screenWidth < 360) {
      return baseSize * 0.8;
    } else if (screenWidth < 600) {
      return baseSize;
    } else if (screenWidth < 900) {
      return baseSize * 1.2;
    } else {
      return baseSize * 1.4;
    }
  }

  static EdgeInsets getAdaptivePadding(BuildContext context) {
    double screenWidth = getScreenWidth(context);
    if (screenWidth < 360) {
      return const EdgeInsets.all(8.0);
    } else if (screenWidth < 600) {
      return const EdgeInsets.all(16.0);
    } else if (screenWidth < 900) {
      return const EdgeInsets.all(24.0);
    } else {
      return const EdgeInsets.all(32.0);
    }
  }

  static double getAdaptiveIconSize(BuildContext context) {
    double screenWidth = getScreenWidth(context);
    if (screenWidth < 360) {
      return 20.0;
    } else if (screenWidth < 600) {
      return 24.0;
    } else if (screenWidth < 900) {
      return 28.0;
    } else {
      return 32.0;
    }
  }
} 