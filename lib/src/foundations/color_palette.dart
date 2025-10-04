import 'package:flutter/material.dart';

/// Defines the color palette for WebbUI, extensible via theme overrides.
class WebbUIColorPalette extends ThemeExtension<WebbUIColorPalette> {
  final Color primary;
  final Color secondary;
  final Color neutralLight;
  final Color neutralDark;
  final Color success;
  final Color warning;
  final Color error;
  final Color info;

  const WebbUIColorPalette({
    required this.primary,
    required this.secondary,
    required this.neutralLight,
    required this.neutralDark,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
  });

  /// Default light palette values, which can be overridden.
  static const WebbUIColorPalette defaultPalette = WebbUIColorPalette(
    primary: Color(0xFF2196F3), // Blue for primary actions
    secondary: Color(0xFF4CAF50), // Green for secondary
    neutralLight: Color(0xFFFFFFFF), // White for backgrounds
    neutralDark: Color(0xFF212121), // Dark gray for text
    success: Color(0xFF4CAF50), // Green for success
    warning: Color(0xFFFFC107), // Yellow for warnings
    error: Color(0xFFF44336), // Red for errors
    info: Color(0xFF03A9F4), // Light blue for info
  );

  /// Default dark palette values, with inverted neutrals and adjusted accents.
  static const WebbUIColorPalette darkPalette = WebbUIColorPalette(
    primary: Color(0xFF64B5F6), // Lighter blue for dark mode visibility
    secondary: Color(0xFF81C784), // Lighter green
    neutralLight: Color(0xFF121212), // Dark background
    neutralDark: Color(0xFFE0E0E0), // Light text
    success: Color(0xFF81C784), // Lighter green
    warning: Color(0xFFFFE082), // Lighter yellow
    error: Color(0xFFE57373), // Lighter red
    info: Color(0xFF4FC3F7), // Lighter blue
  );

  @override
  WebbUIColorPalette copyWith({
    Color? primary,
    Color? secondary,
    Color? neutralLight,
    Color? neutralDark,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
  }) {
    return WebbUIColorPalette(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      neutralLight: neutralLight ?? this.neutralLight,
      neutralDark: neutralDark ?? this.neutralDark,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
    );
  }

  @override
  WebbUIColorPalette lerp(ThemeExtension<WebbUIColorPalette>? other, double t) {
    if (other is! WebbUIColorPalette) {
      return this;
    }
    return WebbUIColorPalette(
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      neutralLight: Color.lerp(neutralLight, other.neutralLight, t)!,
      neutralDark: Color.lerp(neutralDark, other.neutralDark, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}
