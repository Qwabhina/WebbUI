import 'package:flutter/material.dart';

class WebbUIBreakpoints {
  static const double mobile = 600;
  static const double tablet = 1024;
  static const double desktop = 1440;
  static const double largeDesktop = 1920;

  static bool isMobile(double width) => width < mobile;
  static bool isTablet(double width) => width >= mobile && width < tablet;
  static bool isDesktop(double width) =>
      width >= tablet && width < largeDesktop;
  static bool isLargeDesktop(double width) => width >= largeDesktop;

  static String getDeviceType(double width) {
    if (isMobile(width)) return 'mobile';
    if (isTablet(width)) return 'tablet';
    if (isDesktop(width)) return 'desktop';
    return 'largeDesktop';
  }

  /// Get responsive value based on breakpoints
  static T responsiveValue<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    final width = MediaQuery.of(context).size.width;

    if (isLargeDesktop(width)) {
      return largeDesktop ?? desktop ?? tablet ?? mobile;
    }
    if (isDesktop(width)) return desktop ?? tablet ?? mobile;
    if (isTablet(width)) return tablet ?? mobile;
    return mobile;
  }
}
