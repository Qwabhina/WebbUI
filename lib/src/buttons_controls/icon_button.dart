import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';

class WebbUIIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? label; // For tooltip or accessibility
  final bool disabled;

  const WebbUIIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.label,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    final double size = context.iconTheme.mediumSize;
    final Color color = disabled
        ? webbTheme.interactionStates.disabledColor
        : webbTheme.colorPalette.primary;

    Widget button = IconButton(
      icon: Icon(icon, size: size, color: color),
      onPressed: disabled ? null : onPressed,
      tooltip: label,
      style: IconButton.styleFrom(
        backgroundColor: Colors.transparent,
        disabledBackgroundColor:
            webbTheme.interactionStates.disabledColor.withOpacity(0.5),
        highlightColor: webbTheme.interactionStates.pressedOverlay,
        hoverColor: webbTheme.interactionStates.hoverOverlay,
        focusColor: webbTheme.interactionStates.focusedBorder.withOpacity(0.2),
        padding: EdgeInsets.all(webbTheme.spacingGrid.spacing(1)),
        minimumSize: Size(webbTheme.accessibility.minTouchTargetSize,
            webbTheme.accessibility.minTouchTargetSize),
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
