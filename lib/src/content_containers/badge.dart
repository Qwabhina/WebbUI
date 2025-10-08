import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';

/// Defines the color context for the badge (e.g., status or priority).
enum WebbUIBadgeColorType {
  primary,
  error,
  success,
  warning,
  info,
  neutral // Uses neutralDark from color palette
}

/// A small, non-interactive component used to display status or numerical information.
class WebbUIBadge extends StatelessWidget {
  /// The content displayed inside the badge (usually a short number or text).
  final String content;

  /// The color context for the badge.
  final WebbUIBadgeColorType colorType;

  /// The widget the badge is anchored to. If null, the badge is displayed inline.
  final Widget? child;

  const WebbUIBadge({
    super.key,
    required this.content,
    this.colorType = WebbUIBadgeColorType.neutral,
    this.child,
  });

  /// Helper to map the enum to the theme's color palette.
  Color _getBackgroundColor(BuildContext webbTheme) {
    switch (colorType) {
      case WebbUIBadgeColorType.primary:
        return webbTheme.colorPalette.primary;
      case WebbUIBadgeColorType.error:
        return webbTheme.colorPalette.error;
      case WebbUIBadgeColorType.success:
        return webbTheme.colorPalette.success;
      case WebbUIBadgeColorType.warning:
        return webbTheme.colorPalette.warning;
      case WebbUIBadgeColorType.info:
        return webbTheme.colorPalette.info;
      case WebbUIBadgeColorType.neutral:
        return webbTheme.colorPalette.neutralDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;

    final backgroundColor = _getBackgroundColor(webbTheme);
    // Badges universally use the light color for text for maximum contrast
    final foregroundColor = webbTheme.colorPalette.neutralLight;

    final badgeContent = Container(
      // Ensure a minimum size for visibility, especially for single dots/numbers
      constraints: BoxConstraints(
        minWidth: webbTheme.spacingGrid.spacing(2),
        minHeight: webbTheme.spacingGrid.spacing(2),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: webbTheme.spacingGrid.spacing(0.75),
        vertical: webbTheme.spacingGrid.spacing(0.25),
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(
            webbTheme.spacingGrid.baseSpacing * 2), // Pill shape
      ),
      child: Text(
        content,
        textAlign: TextAlign.center,
        // Using a slightly smaller font size based on labelMedium
        style: webbTheme.typography.labelMedium.copyWith(
          color: foregroundColor,
          height: 1.0, // Ensures text alignment is tight within the container
          fontSize: webbTheme.typography.labelMedium.fontSize! * 0.9,
        ),
      ),
    );

    if (child == null) {
      // Display badge inline if no child is provided
      return badgeContent;
    }

    // Anchor the badge to a child widget using the native Flutter Badge
    return Badge(
      // The badge component from the Flutter framework expects a label widget
      label: badgeContent,
      // Default offset to place the badge on the top-right corner
      offset: Offset(webbTheme.spacingGrid.spacing(0.5),
          webbTheme.spacingGrid.spacing(-0.5)),
      child: child!,
    );
  }
}
