import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';

class WebbUISkeleton extends StatelessWidget {
  final double height;
  final double width;
  final BorderRadius? borderRadius;

  const WebbUISkeleton({
    super.key,
    required this.height,
    required this.width,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: webbTheme.colorPalette.neutralDark.withOpacity(0.1),
        borderRadius: borderRadius ?? BorderRadius.circular(4),
      ),
      child: const SizedBox.shrink(),
    );
  }
}

class WebbUISpinner extends StatelessWidget {
  final Color? color;
  final double size;

  const WebbUISpinner({
    super.key,
    this.color,
    this.size = 24.0,
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
        strokeWidth: 3.0,
      ),
    );
  }
}
