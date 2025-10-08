import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';

/// Defines the usage and visual presentation type of the chip.
enum WebbUIChipType {
  standard, // Default informational chip (neutral background, dark text)
  input, // Represents user input, often dismissible
  filter, // Represents a filter option, often toggled (primary colors)
}

/// A small, interactive element used for input, filtering, or presenting information.
class WebbUIChip extends StatelessWidget {
  /// The text label displayed inside the chip.
  final String label;

  /// The type defining the chip's styling and intended use.
  final WebbUIChipType type;

  /// Optional callback when the chip is tapped/clicked.
  final VoidCallback? onTap;

  /// Optional callback for a dismissible chip. Triggers a close icon.
  final VoidCallback? onDeleted;

  /// Used primarily for filter chips to indicate the selection state.
  final bool isSelected;

  const WebbUIChip({
    super.key,
    required this.label,
    this.type = WebbUIChipType.standard,
    this.onTap,
    this.onDeleted,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    final bool isDeletable = onDeleted != null;
    final bool isClickable = onTap != null || type == WebbUIChipType.filter;

    Color backgroundColor;
    Color foregroundColor;
    Color borderColor = Colors.transparent;

    // --- Color Logic based on Type and Selection ---
    if (type == WebbUIChipType.filter && isSelected) {
      // Selected Filter: Solid Primary
      backgroundColor = webbTheme.colorPalette.primary;
      foregroundColor = webbTheme.colorPalette.neutralLight;
    } else if (type == WebbUIChipType.filter && isClickable) {
      // Unselected Interactive Filter: Transparent/Outline Primary
      backgroundColor = webbTheme.colorPalette.primary.withOpacity(0.1);
      foregroundColor = webbTheme.colorPalette.primary;
      borderColor = webbTheme.colorPalette.primary.withOpacity(0.5);
    } else {
      // Standard and Input chips: Light Neutral
      backgroundColor = webbTheme.colorPalette.neutralDark.withOpacity(0.1);
      foregroundColor = webbTheme.colorPalette.neutralDark;
    }

    // Determine padding based on theme spacing
    final horizontalPadding = webbTheme.spacingGrid.spacing(1.5);
    final verticalPadding = webbTheme.spacingGrid.spacing(0.5);

    // Icon for deletion/dismissal
    final deleteIcon = isDeletable
        ? Padding(
            padding: EdgeInsets.only(left: webbTheme.spacingGrid.spacing(0.5)),
            child: InkWell(
              onTap: onDeleted,
              borderRadius:
                  BorderRadius.circular(webbTheme.iconTheme.smallSize),
              child: Icon(
                Icons.close,
                size: webbTheme.iconTheme.smallSize,
                color: foregroundColor.withOpacity(0.8),
              ),
            ),
          )
        : null;

    // Use Material and InkWell for consistent interaction feedback (hover/splash)
    return Material(
      color: backgroundColor,
      elevation: 0,
      borderRadius: BorderRadius.circular(
          webbTheme.spacingGrid.baseSpacing * 4), // Pill shape
      child: InkWell(
        onTap: isClickable ? onTap : null,
        borderRadius:
            BorderRadius.circular(webbTheme.spacingGrid.baseSpacing * 4),
        hoverColor: isClickable
            ? webbTheme.interactionStates.hoverOverlay
            : Colors.transparent,
        splashColor: isClickable
            ? webbTheme.interactionStates.pressedOverlay
            : Colors.transparent,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 1),
            borderRadius:
                BorderRadius.circular(webbTheme.spacingGrid.baseSpacing * 4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: webbTheme.typography.labelMedium
                    .copyWith(color: foregroundColor),
              ),
              if (deleteIcon != null) deleteIcon,
            ],
          ),
        ),
      ),
    );
  }
}
