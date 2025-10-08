import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';

/// A theme-compliant circular loading indicator.
class WebbUISpinner extends StatelessWidget {
  /// The color of the spinner. Defaults to the primary color in the theme.
  final Color? color;

  /// The size (width and height) of the spinner. Defaults to 24.0.
  final double size;

  /// The thickness of the spinner's line. Defaults to 3.0.
  final double strokeWidth;

  const WebbUISpinner({
    super.key,
    this.color,
    this.size = 24.0,
    this.strokeWidth = 3.0,
  });

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    return SizedBox(
      height: size,
      width: size,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
            color ?? webbTheme.colorPalette.primary),
        strokeWidth: strokeWidth,
      ),
    );
  }
}
