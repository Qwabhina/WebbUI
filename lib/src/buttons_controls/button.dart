import 'package:flutter/material.dart';
import 'package:webb_ui/src/foundations/breakpoints.dart';
import 'package:webb_ui/src/theme.dart';

enum WebbUIButtonVariant {
  primary,
  secondary,
  tertiary,
  danger,
  success,
}

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
    final bool isMobile =
        MediaQuery.of(context).size.width < WebbUIBreakpoints.mobile;
    final double minHeight = webbTheme.accessibility.minTouchTargetSize;
    final double paddingHorizontal =
        webbTheme.spacingGrid.spacing(isMobile ? 3 : 2);

    Color backgroundColor;
    Color foregroundColor;
    BorderSide? borderSide;

    switch (variant) {
      case WebbUIButtonVariant.primary:
        backgroundColor = webbTheme.colorPalette.primary;
        foregroundColor = webbTheme.colorPalette.onPrimary;
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
      case WebbUIButtonVariant.danger:
        backgroundColor = webbTheme.colorPalette.error;
        foregroundColor = webbTheme.colorPalette.onPrimary;
        borderSide = null;
        break;
      case WebbUIButtonVariant.success:
        backgroundColor = webbTheme.colorPalette.success;
        foregroundColor = webbTheme.colorPalette.onPrimary;
        borderSide = null;
        break;
    }

    // Override for disabled state
    if (disabled) {
      if (variant == WebbUIButtonVariant.primary) {
        backgroundColor = webbTheme.interactionStates.disabledColor;
        foregroundColor = webbTheme.colorPalette.onPrimary.withOpacity(0.5);
      } else {
        backgroundColor = Colors.transparent;
        foregroundColor = webbTheme.interactionStates.disabledColor;
        if (variant == WebbUIButtonVariant.secondary) {
          borderSide = BorderSide(
              color: webbTheme.interactionStates.disabledColor, width: 1.5);
        }
      }
    }

    final scaledIconTheme = webbTheme.iconTheme;

    // FIX: Calculate proper overlay colors for transparent backgrounds
    Color getOverlayColor(Set<WidgetState> states) {
      if (states.contains(WidgetState.pressed)) {
        // For transparent backgrounds, use the primary color with opacity
        if (backgroundColor == Colors.transparent) {
          return webbTheme.colorPalette.primary.withOpacity(0.12);
        }
        return webbTheme.interactionStates.pressedOverlay;
      }
      if (states.contains(WidgetState.hovered)) {
        // For transparent backgrounds, use the primary color with opacity
        if (backgroundColor == Colors.transparent) {
          return webbTheme.colorPalette.primary.withOpacity(0.08);
        }
        return webbTheme.interactionStates.hoverOverlay;
      }
      return Colors.transparent;
    }

    final ButtonStyle style = ButtonStyle(
      backgroundColor: WidgetStateProperty.all<Color>(backgroundColor),
      foregroundColor: WidgetStateProperty.all<Color>(foregroundColor),
      overlayColor: WidgetStateProperty.resolveWith<Color>(getOverlayColor),
      padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
        EdgeInsets.symmetric(
          horizontal: paddingHorizontal,
          vertical: webbTheme.spacingGrid.spacing(1),
        ),
      ),
      shape: WidgetStateProperty.all<OutlinedBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: borderSide ?? BorderSide.none,
        ),
      ),
      elevation: WidgetStateProperty.resolveWith<double?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) return 0;
          return webbTheme.elevation.getShadows(1).first.blurRadius / 4;
        },
      ),
      minimumSize: WidgetStateProperty.all<Size>(Size(0, minHeight)),
    );

    return Semantics(
      button: true,
      enabled: !disabled && !isLoading,
      label: isLoading ? '$label (Loading)' : label,
      child: SizedBox(
        width: fullWidth ? double.infinity : null,
        height: minHeight,
        child: ElevatedButton(
          onPressed: disabled || isLoading ? null : onPressed,
          style: style,
          child: isLoading
              ? SizedBox(
                  width: scaledIconTheme.mediumSize,
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
                      style: webbTheme.typography.labelLarge.copyWith(
                        color: foregroundColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
