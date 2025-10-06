import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';

enum WebbUIButtonVariant { primary, secondary, tertiary }

class WebbUIButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final WebbUIButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  final bool disabled;

  const WebbUIButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = WebbUIButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    final double minHeight =
        webbTheme.accessibility.minTouchTargetSize; // 48.0 for touch
    final double paddingHorizontal =
        webbTheme.spacingGrid.spacing(isMobile ? 3 : 2);

    Color backgroundColor;
    Color foregroundColor;
    BorderSide? borderSide;

    switch (variant) {
      case WebbUIButtonVariant.primary:
        backgroundColor = webbTheme.colorPalette.primary;
        foregroundColor = Colors.white;
        borderSide = null;
        break;
      case WebbUIButtonVariant.secondary:
        backgroundColor = Colors.transparent;
        foregroundColor = webbTheme.colorPalette.primary;
        borderSide =
            BorderSide(color: webbTheme.colorPalette.primary, width: 1.5);
        break;
      case WebbUIButtonVariant.tertiary:
        backgroundColor = Colors.transparent;
        foregroundColor = webbTheme.colorPalette.primary;
        borderSide = null;
        break;
    }

    if (disabled) {
      // Disabled button always uses interactionStates.disabledColor
      backgroundColor = webbTheme.interactionStates.disabledColor;
      foregroundColor = Colors.white.withOpacity(0.5);
    }

    final scaledIconTheme = webbTheme.iconTheme;

    // --- START OF STYLE FIX: Use a full ButtonStyle to handle WidgetStateProperty ---
    final ButtonStyle style = ButtonStyle(
      // Background Color
      backgroundColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            // Use the pre-calculated disabled color
            return webbTheme.interactionStates.disabledColor;
          }
          return backgroundColor; // Use the variant-specific color
        },
      ),

      // Foreground Color (Text/Icon)
      foregroundColor: WidgetStateProperty.all<Color?>(foregroundColor),

      // Overlay Color (This is the fix for hover/pressed)
      overlayColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.pressed)) {
            return webbTheme.interactionStates.pressedOverlay;
          }
          if (states.contains(WidgetState.hovered)) {
            return webbTheme.interactionStates.hoverOverlay;
          }
          return null; // Transparent overlay by default
        },
      ),

      // Padding
      padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
        EdgeInsets.symmetric(
            horizontal: paddingHorizontal,
            vertical: webbTheme.spacingGrid.spacing(1)),
      ),

      // Shape/Border
      shape: WidgetStateProperty.all<OutlinedBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: borderSide ?? BorderSide.none,
        ),
      ),

      // Elevation (use the elevation token)
      elevation: WidgetStateProperty.resolveWith<double?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return 0;
          }
          // Using the blurRadius as a simple elevation proxy
          return webbTheme.elevation.getShadows(1).first.blurRadius;
        },
      ),

      // Minimum size to enforce minHeight (accessibility touch target)
      minimumSize: WidgetStateProperty.all<Size>(Size(0, minHeight)),
    );
    // --- END OF STYLE FIX ---


    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: minHeight,
      child: ElevatedButton(
        onPressed: disabled || isLoading ? null : onPressed,
        // Pass the resolved ButtonStyle object here
        style: style, 
        child: isLoading
            ? SizedBox(
                width: scaledIconTheme.mediumSize, // Use scaled size for loader
                height: scaledIconTheme.mediumSize,
                child: CircularProgressIndicator(
                  color: foregroundColor,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: scaledIconTheme.mediumSize),
                    SizedBox(width: webbTheme.spacingGrid.spacing(1)),
                  ],
                  Text(
                    label,
                    style: webbTheme.typography.labelLarge
                        .copyWith(color: foregroundColor),
                  ),
                ],
              ),
      ),
    );
  }
}
