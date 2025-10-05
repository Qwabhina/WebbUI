import 'package:flutter/material.dart';
import 'package:webb_ui/src/foundations/foundations.dart';
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
      backgroundColor = webbTheme.interactionStates.disabledColor;
      foregroundColor = Colors.white.withOpacity(0.5);
    }

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: minHeight,
      child: ElevatedButton(
        onPressed: disabled || isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          side: borderSide,
          padding: EdgeInsets.symmetric(
              horizontal: paddingHorizontal,
              vertical: webbTheme.spacingGrid.spacing(1)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: webbTheme.elevation
              .getShadows(1)
              .first
              .blurRadius, // Subtle shadow
          disabledBackgroundColor: webbTheme.interactionStates.disabledColor,
          overlayColor:
              webbTheme.interactionStates.hoverOverlay, // For hover/pressed
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: foregroundColor,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon,
                        size: WebbUIIconTheme.getIconSize(context,
                            sizeType: 'medium')),
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
