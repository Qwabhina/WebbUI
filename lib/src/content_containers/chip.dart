import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';

enum WebbUIChipType {
  standard,
  input,
  filter,
}

class WebbUIChip extends StatelessWidget {
  final String label;
  final WebbUIChipType type;
  final VoidCallback? onTap;
  final VoidCallback? onDeleted;
  final bool isSelected;
  final String? semanticLabel;

  const WebbUIChip({
    super.key,
    required this.label,
    this.type = WebbUIChipType.standard,
    this.onTap,
    this.onDeleted,
    this.isSelected = false,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    final bool isDeletable = onDeleted != null;
    final bool isClickable = onTap != null || type == WebbUIChipType.filter;

    Color backgroundColor;
    Color foregroundColor;
    Color borderColor = Colors.transparent;

    if (type == WebbUIChipType.filter && isSelected) {
      backgroundColor = webbTheme.colorPalette.primary;
      foregroundColor = webbTheme.colorPalette.neutralLight;
    } else if (type == WebbUIChipType.filter && isClickable) {
      backgroundColor = webbTheme.colorPalette.primary.withOpacity(0.1);
      foregroundColor = webbTheme.colorPalette.primary;
      borderColor = webbTheme.colorPalette.primary.withOpacity(0.5);
    } else {
      backgroundColor = webbTheme.colorPalette.neutralDark.withOpacity(0.1);
      foregroundColor = webbTheme.colorPalette.neutralDark;
    }

    final horizontalPadding = webbTheme.spacingGrid.spacing(1.5);
    final verticalPadding = webbTheme.spacingGrid.spacing(0.5);

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

    return Semantics(
      button: isClickable,
      enabled: isClickable,
      label: semanticLabel ?? label,
      selected: isSelected,
      child: Material(
        color: backgroundColor,
        elevation: 0,
        borderRadius:
            BorderRadius.circular(webbTheme.spacingGrid.baseSpacing * 4),
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
      ),
    );
  }
}
