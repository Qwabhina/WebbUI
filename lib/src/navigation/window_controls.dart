import 'dart:io';
import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:webb_ui/src/theme.dart';

/// Platform-aware window controls for desktop applications
class WebbUIWindowControls extends StatelessWidget {
  final bool showMinimize;
  final bool showMaximize;
  final bool showClose;
  final Color? buttonColor;
  final Color? hoverColor;

  const WebbUIWindowControls({
    super.key,
    this.showMinimize = true,
    this.showMaximize = true,
    this.showClose = true,
    this.buttonColor,
    this.hoverColor,
  });

  /// Check if we're running on a desktop platform that supports window controls
  static bool get isDesktopPlatform {
    return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  }

  @override
  Widget build(BuildContext context) {
    if (!isDesktopPlatform) {
      return const SizedBox.shrink();
    }

    final webbTheme = context;
    final defaultButtonColor = buttonColor ?? webbTheme.colorPalette.onPrimary;
    final defaultHoverColor =
        hoverColor ?? webbTheme.colorPalette.primary.withOpacity(0.1);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showMinimize)
          _WindowControlButton(
            icon: Icons.minimize,
            onPressed: () => appWindow.minimize(),
            color: defaultButtonColor,
            hoverColor: defaultHoverColor,
          ),
        if (showMaximize)
          _WindowControlButton(
            icon: appWindow.isMaximized ? Icons.filter_none : Icons.crop_square,
            onPressed: () => appWindow.maximizeOrRestore(),
            color: defaultButtonColor,
            hoverColor: defaultHoverColor,
          ),
        if (showClose)
          _WindowControlButton(
            icon: Icons.close,
            onPressed: () => appWindow.close(),
            color: defaultButtonColor,
            hoverColor: defaultHoverColor,
            isCloseButton: true,
          ),
      ],
    );
  }
}

class _WindowControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  final Color hoverColor;
  final bool isCloseButton;

  const _WindowControlButton({
    required this.icon,
    required this.onPressed,
    required this.color,
    required this.hoverColor,
    this.isCloseButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;

    return SizedBox(
      width: webbTheme.accessibility.minTouchTargetSize,
      height: webbTheme.accessibility.minTouchTargetSize,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          hoverColor: isCloseButton ? Colors.red.withOpacity(0.2) : hoverColor,
          child: Icon(
            icon,
            size: webbTheme.iconTheme.smallSize,
            color: color,
          ),
        ),
      ),
    );
  }
}
