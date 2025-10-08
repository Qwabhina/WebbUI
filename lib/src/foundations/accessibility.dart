import 'package:flutter/material.dart';
import 'dart:ui' show lerpDouble;

/// Defines accessibility guidelines for WebbUI.
class WebbUIAccessibility extends ThemeExtension<WebbUIAccessibility> {
  final double minContrastRatio; // WCAG AA: 4.5:1
  final double minTouchTargetSize; // 48x48 dp for mobile
  final double minTextSizeLarge; // 18pt for large text (WCAG)
  final double minTextSizeSmall; // 14pt for normal text

  const WebbUIAccessibility({
    required this.minContrastRatio,
    required this.minTouchTargetSize,
    required this.minTextSizeLarge,
    required this.minTextSizeSmall,
  });


  /// Default guidelines.
  static const WebbUIAccessibility defaultAccessibility = WebbUIAccessibility(
    minContrastRatio: 4.5,
    minTouchTargetSize: 48.0,
    minTextSizeLarge: 18.0,
    minTextSizeSmall: 14.0,
  );

  /// Helper to check contrast (using luminance).
  static bool hasSufficientContrast(Color color1, Color color2,
      {double ratio = 4.5}) {
    final double l1 = color1.computeLuminance();
    final double l2 = color2.computeLuminance();
    final double contrast =
        (l1 > l2 ? (l1 + 0.05) / (l2 + 0.05) : (l2 + 0.05) / (l1 + 0.05));
    return contrast >= ratio;
  }

  @override
  WebbUIAccessibility copyWith({
    double? minContrastRatio,
    double? minTouchTargetSize,
    double? minTextSizeLarge,
    double? minTextSizeSmall,
  }) {
    return WebbUIAccessibility(
      minContrastRatio: minContrastRatio ?? this.minContrastRatio,
      minTouchTargetSize: minTouchTargetSize ?? this.minTouchTargetSize,
      minTextSizeLarge: minTextSizeLarge ?? this.minTextSizeLarge,
      minTextSizeSmall: minTextSizeSmall ?? this.minTextSizeSmall,
    );
  }

  @override
  WebbUIAccessibility lerp(
    ThemeExtension<WebbUIAccessibility>? other,
    double t,
  ) {
    if (other is! WebbUIAccessibility) {
      return this;
    }
    return WebbUIAccessibility(
      minContrastRatio:
          lerpDouble(minContrastRatio, other.minContrastRatio, t)!,
      minTouchTargetSize:
          lerpDouble(minTouchTargetSize, other.minTouchTargetSize, t)!,
      minTextSizeLarge:
          lerpDouble(minTextSizeLarge, other.minTextSizeLarge, t)!,
      minTextSizeSmall:
          lerpDouble(minTextSizeSmall, other.minTextSizeSmall, t)!,
    );
  }

  double getMinTextSize(bool isLargeText) =>
      isLargeText ? minTextSizeLarge : minTextSizeSmall;
}
