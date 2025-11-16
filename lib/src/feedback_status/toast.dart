import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';

/// Defines the visual type of the toast notification.
enum WebbUIToastType { success, warning, error, info }

/// A utility class for displaying temporary, non-blocking toast notifications.
class WebbUIToast {
  /// Displays a toast notification at the bottom of the screen.
  static void show(
    BuildContext context, {
    required String message,
    WebbUIToastType type = WebbUIToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Check if the overlay is available
    final overlay = Overlay.of(context);
    
    final Color backgroundColor;
    final IconData icon;
    
    // Determine color and icon based on the toast type
    switch (type) {
      case WebbUIToastType.success:
        backgroundColor = context.colorPalette.success;
        // icon = Icons.check_circle;
        icon = FluentIcons.checkmark_circle_20_regular;
        break;
      case WebbUIToastType.warning:
        backgroundColor = context.colorPalette.warning;
        // icon = Icons.warning;
        icon = FluentIcons.warning_20_regular;
        break;
      case WebbUIToastType.error:
        backgroundColor = context.colorPalette.error;
        // icon = Icons.error;
        icon = FluentIcons.error_circle_20_regular;
        break;
      case WebbUIToastType.info:
        backgroundColor = context.colorPalette.info;
        // icon = Icons.info;
        icon = FluentIcons.info_20_regular;
        break;
    }

    final toast = OverlayEntry(
      builder: (context) => Positioned(
        // Position the toast at the bottom center
        bottom: 50.0,
        left: 0.0,
        right: 0.0,
        child: Material(
          color: Colors.transparent,
          child: Center(
            // Center the toast horizontally within the Positioned container
            child: Container(
              // Constrain the toast width for better readability on large screens
              constraints: const BoxConstraints(maxWidth: 400),
              margin: EdgeInsets.symmetric(
                  horizontal: context.spacingGrid.spacing(2)),
              padding: EdgeInsets.all(context.spacingGrid.spacing(2)),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: context.elevation.getShadows(2),
              ),
              child: Row(
                children: [
                  // Icon
                  Icon(icon,
                      color: Colors.white, size: context.iconTheme.mediumSize),
                  SizedBox(width: context.spacingGrid.spacing(2)),
                  // Message Text
                  Expanded(
                    child: Text(
                      message,
                      // Ensure text is white for high contrast against the colored background
                      style: context.typography.bodyMedium
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Insert the toast into the overlay
    overlay.insert(toast);

    // Remove the toast after the specified duration
    Future.delayed(duration, () => toast.remove());
  }
}
