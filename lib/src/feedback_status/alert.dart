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
        return Icons.check_circle_outline;
      case WebbUIAlertType.warning:
        return Icons.warning_amber_rounded;
      case WebbUIAlertType.error:
        return Icons.error_outline;
      case WebbUIAlertType.info:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    final Color backgroundColor;
    final IconData icon = _getIcon(type);

    // Foreground color is set to white for maximum contrast against status colors
    const Color foregroundColor = Colors.white;

    switch (type) {
      case WebbUIAlertType.success:
        backgroundColor = webbTheme.colorPalette.success;
        break;
      case WebbUIAlertType.warning:
        backgroundColor = webbTheme.colorPalette.warning;
        break;
      case WebbUIAlertType.error:
        backgroundColor = webbTheme.colorPalette.error;
        break;
      case WebbUIAlertType.info:
        backgroundColor = webbTheme.colorPalette.info;
        break;
    }
    
    // Use Material for elevation and proper theming integration
    return Material(
      color: backgroundColor,
      // Apply elevation from theme
      elevation:
          elevated ? webbTheme.elevation.getShadows(1).first.blurRadius / 2 : 0,
      shadowColor: elevated
          ? webbTheme.elevation.getShadows(1).first.color
          : Colors.transparent,
      borderRadius: BorderRadius.circular(
          webbTheme.spacingGrid.baseSpacing), // Rounded corners

      child: Container(
        constraints: const BoxConstraints(
            minHeight: 48), // Ensure minimum height for touch target/visibility
        padding: EdgeInsets.all(webbTheme.spacingGrid.spacing(2)),
        
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Align icon and close button to top
          children: [
            // Icon
            Padding(
              padding:
                  EdgeInsets.only(top: webbTheme.spacingGrid.spacing(0.25)),
              child: Icon(
                icon,
                color: foregroundColor,
                size: webbTheme.iconTheme.mediumSize,
              ),
            ),

            SizedBox(width: webbTheme.spacingGrid.spacing(2)),
            
            // Message Text (Expanded to fill space)
            Expanded(
              child: Text(
                message,
                // Using bodyLarge for better readability
                style: webbTheme.typography.bodyLarge
                    .copyWith(color: foregroundColor),
              ),
            ),
            
            // Dismiss button
            if (dismissible)
              Padding(
                padding:
                    EdgeInsets.only(left: webbTheme.spacingGrid.spacing(1)),
                child: IconButton(
                  icon: Icon(
                    Icons.close,
                    color: foregroundColor,
                    size: webbTheme.iconTheme.mediumSize *
                        0.9, // Slightly smaller close icon
                  ),
                  onPressed: onDismiss,
                  // Ensure proper touch target size using accessibility theme
                  constraints: BoxConstraints(
                    minWidth: webbTheme.accessibility.minTouchTargetSize,
                    minHeight: webbTheme.accessibility.minTouchTargetSize,
                  ),
                  padding: EdgeInsets.zero,
                  splashRadius: webbTheme.spacingGrid.spacing(3),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
