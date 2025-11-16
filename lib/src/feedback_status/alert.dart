import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';

/// Defines the color and icon type for the alert.
enum WebbUIAlertType { success, warning, error, info }

/// A theme-compliant banner used to display important, contextual messages.
class WebbUIAlert extends StatelessWidget {
  /// The main message content of the alert.
  final String message;
  
  /// The type defining the color, icon, and context.
  final WebbUIAlertType type;
  
  /// Callback function when the dismiss button is pressed.
  final VoidCallback? onDismiss;
  
  /// If true, a close button is displayed.
  final bool dismissible;
  
  /// If true, applies a slight elevation/shadow to the alert.
  final bool elevated;
  
  const WebbUIAlert({
    super.key,
    required this.message,
    this.type = WebbUIAlertType.info,
    this.onDismiss,
    this.dismissible = false,
    this.elevated = true, // Added elevated property for visual lift
  });

  /// Helper to get the correct icon for the alert type
  IconData _getIcon(WebbUIAlertType type) {
    switch (type) {
      case WebbUIAlertType.success:
        // return Icons.check_circle_outline;
        return FluentIcons.checkmark_circle_20_regular;
      case WebbUIAlertType.warning:
        // return Icons.warning_amber_rounded;
        return FluentIcons.warning_20_regular;
      case WebbUIAlertType.error:
        // return Icons.error_outline;
        return FluentIcons.error_circle_20_regular;
      case WebbUIAlertType.info:
        // return Icons.info_outline;
        return FluentIcons.info_20_regular;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor;
    final IconData icon = _getIcon(type);

    // Foreground color is set to white for maximum contrast against status colors
    const Color foregroundColor = Colors.white;

    switch (type) {
      case WebbUIAlertType.success:
        backgroundColor = context.colorPalette.success;
        break;
      case WebbUIAlertType.warning:
        backgroundColor = context.colorPalette.warning;
        break;
      case WebbUIAlertType.error:
        backgroundColor = context.colorPalette.error;
        break;
      case WebbUIAlertType.info:
        backgroundColor = context.colorPalette.info;
        break;
    }
    
    // Use Material for elevation and proper theming integration
    return Material(
      color: backgroundColor,
      // Apply elevation from theme
      elevation:
          elevated ? context.elevation.getShadows(1).first.blurRadius / 2 : 0,
      shadowColor: elevated
          ? context.elevation.getShadows(1).first.color
          : Colors.transparent,
      borderRadius: BorderRadius.circular(
          context.spacingGrid.baseSpacing), // Rounded corners

      child: Container(
        constraints: const BoxConstraints(
            minHeight: 48), // Ensure minimum height for touch target/visibility
        padding: EdgeInsets.all(context.spacingGrid.spacing(2)),
        
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Align icon and close button to top
          children: [
            // Icon
            Padding(
              padding:
                  EdgeInsets.only(top: context.spacingGrid.spacing(0.25)),
              child: Icon(
                icon,
                color: foregroundColor,
                size: context.iconTheme.mediumSize,
              ),
            ),

            SizedBox(width: context.spacingGrid.spacing(2)),
            
            // Message Text (Expanded to fill space)
            Expanded(
              child: Text(
                message,
                // Using bodyLarge for better readability
                style: context.typography.bodyLarge
                    .copyWith(color: foregroundColor),
              ),
            ),
            
            // Dismiss button
            if (dismissible)
              Padding(
                padding:
                    EdgeInsets.only(left: context.spacingGrid.spacing(1)),
                child: IconButton(
                  icon: Icon(
                    // Icons.close,
                    FluentIcons.dismiss_20_regular,
                    color: foregroundColor,
                    size: context.iconTheme.mediumSize *
                        0.9, // Slightly smaller close icon
                  ),
                  onPressed: onDismiss,
                  // Ensure proper touch target size using accessibility theme
                  constraints: BoxConstraints(
                    minWidth: context.accessibility.minTouchTargetSize,
                    minHeight: context.accessibility.minTouchTargetSize,
                  ),
                  padding: EdgeInsets.zero,
                  splashRadius: context.spacingGrid.spacing(3),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
