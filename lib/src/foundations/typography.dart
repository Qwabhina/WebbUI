import 'package:flutter/material.dart';

/// Defines the typography system for WebbUI, with responsive scaling applied via context.
class WebbUITypography extends ThemeExtension<WebbUITypography> {
  final TextStyle displayLarge;
  final TextStyle displayMedium;
  final TextStyle headlineLarge;
  final TextStyle headlineMedium;
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle labelLarge;
  final TextStyle labelMedium;

  const WebbUITypography({
    required this.displayLarge,
    required this.displayMedium,
    required this.headlineLarge,
    required this.headlineMedium,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.labelLarge,
    required this.labelMedium,
  });

  /// Default typography (base sizes at scale 1.0), using system fonts for cross-platform consistency.
  static const WebbUITypography defaultTypography = WebbUITypography(
    displayLarge:
        TextStyle(fontSize: 57, fontWeight: FontWeight.bold, height: 1.12),
    displayMedium:
        TextStyle(fontSize: 45, fontWeight: FontWeight.bold, height: 1.16),
    headlineLarge:
        TextStyle(fontSize: 32, fontWeight: FontWeight.bold, height: 1.25),
    headlineMedium:
        TextStyle(fontSize: 28, fontWeight: FontWeight.bold, height: 1.29),
    bodyLarge:
        TextStyle(fontSize: 16, fontWeight: FontWeight.normal, height: 1.5),
    bodyMedium:
        TextStyle(fontSize: 14, fontWeight: FontWeight.normal, height: 1.43),
    labelLarge:
        TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.43),
    labelMedium:
        TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.33),
  );

  static double getScaleFactor(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    if (width < 600) return 0.9; // Mobile: slightly smaller
    if (width < 1024) return 1.0; // Tablet: base
    return 1.1; // Desktop: slightly larger
  }

  @override
  WebbUITypography copyWith({
    TextStyle? displayLarge,
    TextStyle? displayMedium,
    TextStyle? headlineLarge,
    TextStyle? headlineMedium,
    TextStyle? bodyLarge,
    TextStyle? bodyMedium,
    TextStyle? labelLarge,
    TextStyle? labelMedium,
  }) {
    return WebbUITypography(
      displayLarge: displayLarge ?? this.displayLarge,
      displayMedium: displayMedium ?? this.displayMedium,
      headlineLarge: headlineLarge ?? this.headlineLarge,
      headlineMedium: headlineMedium ?? this.headlineMedium,
      bodyLarge: bodyLarge ?? this.bodyLarge,
      bodyMedium: bodyMedium ?? this.bodyMedium,
      labelLarge: labelLarge ?? this.labelLarge,
      labelMedium: labelMedium ?? this.labelMedium,
    );
  }

  @override
  WebbUITypography lerp(ThemeExtension<WebbUITypography>? other, double t) {
    if (other is! WebbUITypography) {
      return this;
    }
    return WebbUITypography(
      displayLarge: TextStyle.lerp(displayLarge, other.displayLarge, t)!,
      displayMedium: TextStyle.lerp(displayMedium, other.displayMedium, t)!,
      headlineLarge: TextStyle.lerp(headlineLarge, other.headlineLarge, t)!,
      headlineMedium: TextStyle.lerp(headlineMedium, other.headlineMedium, t)!,
      bodyLarge: TextStyle.lerp(bodyLarge, other.bodyLarge, t)!,
      bodyMedium: TextStyle.lerp(bodyMedium, other.bodyMedium, t)!,
      labelLarge: TextStyle.lerp(labelLarge, other.labelLarge, t)!,
      labelMedium: TextStyle.lerp(labelMedium, other.labelMedium, t)!,
    );
  }

  /// Internal method to scale all styles based on context (used in BuildContext extension).
  WebbUITypography scaleWithContext(BuildContext context) {
    final double scaleFactor = getScaleFactor(context);
    return copyWith(
      displayLarge:
          displayLarge.copyWith(fontSize: displayLarge.fontSize! * scaleFactor),
      displayMedium: displayMedium.copyWith(
          fontSize: displayMedium.fontSize! * scaleFactor),
      headlineLarge: headlineLarge.copyWith(
          fontSize: headlineLarge.fontSize! * scaleFactor),
      headlineMedium: headlineMedium.copyWith(
          fontSize: headlineMedium.fontSize! * scaleFactor),
      bodyLarge:
          bodyLarge.copyWith(fontSize: bodyLarge.fontSize! * scaleFactor),
      bodyMedium:
          bodyMedium.copyWith(fontSize: bodyMedium.fontSize! * scaleFactor),
      labelLarge:
          labelLarge.copyWith(fontSize: labelLarge.fontSize! * scaleFactor),
      labelMedium:
          labelMedium.copyWith(fontSize: labelMedium.fontSize! * scaleFactor),
    );
  }
}
