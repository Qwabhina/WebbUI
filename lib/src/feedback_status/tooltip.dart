import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';

/// A theme-compliant, customizable tooltip component.
/// It uses themed colors for high contrast and consistent typography.
class WebbUITooltip extends StatelessWidget {
  /// The widget above which the tooltip message will be displayed.
  final Widget child;

  /// The message to be displayed in the tooltip.
  final String message;

  /// Whether the tooltip should prefer being displayed below the widget.
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

      // Theme-compliant decoration: dark background for high contrast
      decoration: BoxDecoration(
        color: webbTheme.colorPalette.neutralDark,
        // Uses a small, fixed border radius for containment
        borderRadius: BorderRadius.circular(4),
      ),

      // Theme-compliant text style with explicit white color for contrast
      textStyle: webbTheme.typography.labelMedium.copyWith(color: Colors.white),

      child: child,
    );
  }
}
