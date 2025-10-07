import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';

class WebbUITooltip extends StatelessWidget {
  final Widget child;
  final String message;
  final bool preferBelow;

  const WebbUITooltip({
    super.key,
    required this.child,
    required this.message,
    this.preferBelow = true,
  });

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    return Tooltip(
      message: message,
      preferBelow: preferBelow,
      decoration: BoxDecoration(
        color: webbTheme.colorPalette.neutralDark,
        borderRadius: BorderRadius.circular(4),
      ),
      textStyle: webbTheme.typography.labelMedium.copyWith(color: Colors.white),
      child: child,
    );
  }
}
