import 'package:flutter/material.dart';

/// Defines the style for the carousel indicators.
enum WebbUICarouselIndicatorStyle { dots, bars }

/// Defines the vertical position for the carousel indicators.
enum WebbUICarouselIndicatorPosition { bottom, top }

/// Configuration options for an item's caption overlay.
class CaptionConfig {
  /// The alignment of the caption within the carousel item.
  final AlignmentGeometry alignment;

  /// The background color of the caption container.
  /// Defaults to a semi-transparent dark color from the theme.
  final Color? backgroundColor;

  /// The text style for the caption. Defaults to `bodyMedium` from the theme.
  final TextStyle? textStyle;

  /// The padding inside the caption container.
  final EdgeInsets? padding;

  /// The opacity of the caption's background color.
  final double? opacity;

  const CaptionConfig({
    this.alignment = Alignment.bottomCenter,
    this.backgroundColor,
    this.textStyle,
    this.padding,
    this.opacity,
  });
}
