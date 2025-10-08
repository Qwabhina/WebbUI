import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';

/// Defines the visual type and context of the status.
enum WebbUIStatusType { online, offline, pending, custom }

/// A small, color-coded indicator dot, optionally paired with a label,
/// used to convey a compact status (e.g., connection status, readiness).
class WebbUIStatusIndicator extends StatelessWidget {
  /// The type defining the color and context of the status.
  final WebbUIStatusType type;

  /// An optional text label to display next to the indicator dot.
  final String? label;

  /// Custom color to use when [type] is [WebbUIStatusType.custom].
  final Color? customColor;

  const WebbUIStatusIndicator({
    super.key,
    required this.type,
    this.label,
    this.customColor,
  });

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    final Color color;

    // Determine the color based on the status type
    switch (type) {
      case WebbUIStatusType.online:
        color = webbTheme.colorPalette.success;
        break;
      case WebbUIStatusType.offline:
        color = webbTheme.colorPalette.error;
        break;
      case WebbUIStatusType.pending:
        color = webbTheme.colorPalette.warning;
        break;
      case WebbUIStatusType.custom:
        // Use custom color or neutral dark as fallback
        color = customColor ?? webbTheme.colorPalette.neutralDark;
        break;
    }

    // Size the dot based on the theme's base spacing unit (1.5x base spacing = 12.0 by default)
    final double dotSize = webbTheme.spacingGrid.spacing(1.5);

    return Row(
      mainAxisSize: MainAxisSize.min,
      // Vertically align the dot and text label
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // The Status Dot
        Container(
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),

        // The optional Label
        if (label != null)
          Padding(
            padding: EdgeInsets.only(left: webbTheme.spacingGrid.spacing(1)),
            child: Text(
              label!,
              // Use neutralDark for high contrast on the label
              style: webbTheme.typography.labelMedium
                  .copyWith(color: webbTheme.colorPalette.neutralDark),
            ),
          ),
      ],
    );
  }
}
