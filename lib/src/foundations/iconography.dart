import 'package:flutter/material.dart';
import 'package:webb_ui/src/foundations/typography.dart';
import 'dart:ui' show lerpDouble;

/// Defines iconography for WebbUI, including sizes and styles.
class WebbUIIconTheme extends ThemeExtension<WebbUIIconTheme> {
  final double smallSize;
  final double mediumSize;
  final double largeSize;
  final IconThemeData iconThemeData; // For color, opacity, etc.

  const WebbUIIconTheme({
    required this.smallSize,
    required this.mediumSize,
    required this.largeSize,
    required this.iconThemeData,
  });

  /// Default light icon theme.
  static const WebbUIIconTheme defaultIconTheme = WebbUIIconTheme(
    smallSize: 16.0,
    mediumSize: 24.0,
    largeSize: 32.0,
    iconThemeData: IconThemeData(color: Colors.black, size: 24.0),
  );

  /// Default dark icon theme, with lighter color.
  static const WebbUIIconTheme defaultDarkIconTheme = WebbUIIconTheme(
    smallSize: 16.0,
    mediumSize: 24.0,
    largeSize: 32.0,
    iconThemeData: IconThemeData(color: Colors.white, size: 24.0),
  );

  // /// Responsive size getter.
  // static double getIconSize(BuildContext context, {required String sizeType}) {
  //   final WebbUIIconTheme theme =
  //       Theme.of(context).extension<WebbUIIconTheme>() ?? defaultIconTheme;
  //   final double scale =
  //       WebbUITypography.getScaleFactor(context); // Reuse scale from typography
  //   switch (sizeType) {
  //     case 'small':
  //       return theme.smallSize * scale;
  //     case 'large':
  //       return theme.largeSize * scale;
  //     default:
  //       return theme.mediumSize * scale;
  //   }
  // }

  WebbUIIconTheme scaleWithContext(BuildContext context) {
    final double scaleFactor = WebbUITypography.getScaleFactor(context);
    return copyWith(
      smallSize: smallSize * scaleFactor,
      mediumSize: mediumSize * scaleFactor,
      largeSize: largeSize * scaleFactor,
      // Optionally scale iconThemeData.size if needed, but often size is explicit
      // If you want to scale the default size as well:
      iconThemeData: iconThemeData.copyWith(
        size: iconThemeData.size! * scaleFactor,
      ),
    );
  }

  @override
  WebbUIIconTheme copyWith({
    double? smallSize,
    double? mediumSize,
    double? largeSize,
    IconThemeData? iconThemeData,
  }) {
    return WebbUIIconTheme(
      smallSize: smallSize ?? this.smallSize,
      mediumSize: mediumSize ?? this.mediumSize,
      largeSize: largeSize ?? this.largeSize,
      iconThemeData: iconThemeData ?? this.iconThemeData,
    );
  }

  @override
  WebbUIIconTheme lerp(ThemeExtension<WebbUIIconTheme>? other, double t) {
    if (other is! WebbUIIconTheme) {
      return this;
    }
    return WebbUIIconTheme(
      smallSize: lerpDouble(smallSize, other.smallSize, t)!,
      mediumSize: lerpDouble(mediumSize, other.mediumSize, t)!,
      largeSize: lerpDouble(largeSize, other.largeSize, t)!,
      iconThemeData: IconThemeData.lerp(iconThemeData, other.iconThemeData, t),
    );
  }
}
