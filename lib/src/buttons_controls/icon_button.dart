import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';

class WebbUIIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool disabled;
  final String? size; // 'small', 'medium', 'large'
  final Color? backgroundColor;

  const WebbUIIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.disabled = false,
    this.size = 'medium',
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    final double iconSize = _getIconSize(size, webbTheme);
    final double buttonSize = _getButtonSize(size, webbTheme);

    final Color iconColor = disabled
        ? webbTheme.interactionStates.disabledColor
        : (backgroundColor != null
            ? Colors.white
            : webbTheme.colorPalette.primary);

    Widget button = SizedBox(
      width: buttonSize,
      height: buttonSize,
      child: ElevatedButton(
        onPressed: disabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: backgroundColor,
          foregroundColor: iconColor,
          shape: const CircleBorder(),
          elevation: 0,
          disabledBackgroundColor:
              webbTheme.interactionStates.disabledColor.withOpacity(0.1),
          disabledForegroundColor: webbTheme.interactionStates.disabledColor,
        ),
        child: Icon(icon, size: iconSize),
      ),
    );

    if (tooltip != null && !disabled) {
      button = Tooltip(message: tooltip!, child: button);
    }

    return button;
  }

  double _getIconSize(String? size, BuildContext theme) {
    switch (size) {
      case 'small':
        return theme.iconTheme.smallSize;
      case 'large':
        return theme.iconTheme.largeSize;
      default:
        return theme.iconTheme.mediumSize;
    }
  }

  double _getButtonSize(String? size, BuildContext theme) {
    final double minSize = theme.accessibility.minTouchTargetSize;
    switch (size) {
      case 'small':
        return minSize;
      case 'large':
        return minSize * 1.5;
      default:
        return minSize * 1.25;
    }
  }
}
