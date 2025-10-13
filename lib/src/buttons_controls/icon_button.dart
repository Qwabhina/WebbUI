import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';

class WebbUIIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? label;
  final bool disabled;
  final double? size;

  const WebbUIIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.label,
    this.disabled = false,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    final double iconSize = size ?? context.iconTheme.mediumSize;
    final Color color = disabled
        ? webbTheme.interactionStates.disabledColor
        : webbTheme.colorPalette.primary;

    // Calculate proper padding to maintain touch target
    final double minSize = webbTheme.accessibility.minTouchTargetSize;
    final double padding = (minSize - iconSize) / 2;

    Widget button = IconButton(
      icon: Icon(icon, size: iconSize, color: color),
      onPressed: disabled ? null : onPressed,
      tooltip: label,
      style: IconButton.styleFrom(
        backgroundColor: Colors.transparent,
        disabledBackgroundColor: 
            webbTheme.interactionStates.disabledColor.withOpacity(0.1),
        highlightColor: webbTheme.interactionStates.pressedOverlay,
        hoverColor: webbTheme.interactionStates.hoverOverlay,
        focusColor: webbTheme.interactionStates.focusedBorder.withOpacity(0.2),
        padding:
            EdgeInsets.all(padding.clamp(4, 12)), // Ensure reasonable bounds
        minimumSize: Size(minSize, minSize),
      ),
    );

    if (label != null) {
      return Tooltip(
        message: label!,
        child: button,
      );
    }
    return button;
  }
}
