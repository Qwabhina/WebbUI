import 'package:flutter/material.dart';
import 'breakpoints.dart';

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
  final TextStyle labelSmall;

  const WebbUITypography({
    required this.displayLarge,
    required this.displayMedium,
    required this.headlineLarge,
    required this.headlineMedium,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.labelLarge,
    required this.labelMedium,
    required this.labelSmall,
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
        TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.43),
    labelMedium:
        TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.33),
    labelSmall:
        TextStyle(fontSize: 11, fontWeight: FontWeight.w500, height: 1.27),
  );

  static double getScaleFactor(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    
    if (width < 360) return 0.85; // Small mobile
    if (width < 400) return 0.9; // Normal mobile
    if (width < WebbUIBreakpoints.mobile) return 1.0; // Large mobile
    if (width < WebbUIBreakpoints.tablet) return 1.05; // Small tablet
    if (width < WebbUIBreakpoints.desktop) {
      return 1.1; // Large tablet/Small desktop
    }
    return 1.2; // Large desktop
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
    TextStyle? labelSmall,
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
      labelSmall: labelSmall ?? this.labelSmall,
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
      labelSmall: TextStyle.lerp(labelSmall, other.labelSmall, t)!,
    );
  }

  /// Scales all text styles based on context
  WebbUITypography scaleWithContext(BuildContext context) {
    final double scaleFactor = getScaleFactor(context);
    
    TextStyle scaleTextStyle(TextStyle style) {
      return style.copyWith(
        fontSize: (style.fontSize ?? 16.0) * scaleFactor,
        // Optionally scale height as well, but be careful with line heights
        height: style.height != null ? style.height! * scaleFactor : null,
      );
    }

    return copyWith(
      displayLarge: scaleTextStyle(displayLarge),
      displayMedium: scaleTextStyle(displayMedium),
      headlineLarge: scaleTextStyle(headlineLarge),
      headlineMedium: scaleTextStyle(headlineMedium),
      bodyLarge: scaleTextStyle(bodyLarge),
      bodyMedium: scaleTextStyle(bodyMedium),
      labelLarge: scaleTextStyle(labelLarge),
      labelMedium: scaleTextStyle(labelMedium),
      labelSmall: scaleTextStyle(labelSmall),
    );
  }
}
