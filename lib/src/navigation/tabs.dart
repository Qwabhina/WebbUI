import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';

enum WebbUITabOrientation { horizontal, vertical }
enum WebbUITabVariant { standard, segmented, pills }

class WebbUITabs extends StatelessWidget {
  final List<String> tabLabels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final WebbUITabOrientation orientation;
  final WebbUITabVariant variant;
  final bool fullWidth;
  final double? minTabWidth;

  const WebbUITabs({
    super.key,
    required this.tabLabels,
    required this.selectedIndex,
    required this.onChanged,
    this.orientation = WebbUITabOrientation.horizontal,
    this.variant = WebbUITabVariant.standard,
    this.fullWidth = false,
    this.minTabWidth,
  }) : assert(selectedIndex >= 0 && selectedIndex < tabLabels.length);

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;

    if (orientation == WebbUITabOrientation.vertical) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          tabLabels.length,
          (index) => _WebbUITabItem(
            label: tabLabels[index],
            index: index,
            isSelected: index == selectedIndex,
            orientation: orientation,
            variant: variant,
            onTap: onChanged,
          ),
        ),
      );
    }

    // Horizontal tabs
    return Container(
      decoration: variant == WebbUITabVariant.standard
          ? BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: webbTheme.colorPalette.neutralDark.withOpacity(0.1),
                  width: 1.0,
                ),
              ),
            )
          : null,
      child: Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        children: List.generate(
          tabLabels.length,
          (index) => Expanded(
            child: _WebbUITabItem(
              label: tabLabels[index],
              index: index,
              isSelected: index == selectedIndex,
              orientation: orientation,
              variant: variant,
              onTap: onChanged,
              minWidth: minTabWidth,
            ),
          ),
        ),
      ),
    );
  }
}

class _WebbUITabItem extends StatelessWidget {
  final String label;
  final int index;
  final bool isSelected;
  final WebbUITabOrientation orientation;
  final WebbUITabVariant variant;
  final ValueChanged<int> onTap;
  final double? minWidth;

  const _WebbUITabItem({
    required this.label,
    required this.index,
    required this.isSelected,
    required this.orientation,
    required this.variant,
    required this.onTap,
    this.minWidth,
  });

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: Material(
        color: _getBackgroundColor(webbTheme),
        borderRadius: _getBorderRadius(webbTheme),
        child: InkWell(
          onTap: () => onTap(index),
          borderRadius: _getBorderRadius(webbTheme),
          hoverColor: webbTheme.interactionStates.hoverOverlay,
          splashColor: webbTheme.interactionStates.pressedOverlay,
          child: Container(
            constraints:
                minWidth != null ? BoxConstraints(minWidth: minWidth!) : null,
            padding: _getPadding(webbTheme),
            decoration: _getDecoration(webbTheme),
            child: _buildContent(webbTheme),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor(BuildContext webbTheme) {
    switch (variant) {
      case WebbUITabVariant.segmented:
        return isSelected
            ? webbTheme.colorPalette.primary
            : webbTheme.colorPalette.surface;
      case WebbUITabVariant.pills:
        return isSelected
            ? webbTheme.colorPalette.primary.withOpacity(0.1)
            : Colors.transparent;
      case WebbUITabVariant.standard:
      default:
        return Colors.transparent;
    }
  }

  EdgeInsets _getPadding(BuildContext webbTheme) {
    final spacing = webbTheme.spacingGrid.spacing(1.5);

    if (orientation == WebbUITabOrientation.vertical) {
      return EdgeInsets.symmetric(
        horizontal: spacing,
        vertical: spacing * 0.75,
      );
    }

    switch (variant) {
      case WebbUITabVariant.segmented:
        return EdgeInsets.symmetric(
          horizontal: spacing,
          vertical: spacing,
        );
      case WebbUITabVariant.pills:
        return EdgeInsets.symmetric(
          horizontal: spacing,
          vertical: spacing * 0.75,
        );
      case WebbUITabVariant.standard:
      default:
        return EdgeInsets.symmetric(
          horizontal: spacing,
          vertical: spacing,
        );
    }
  }

  BoxDecoration? _getDecoration(BuildContext webbTheme) {
    switch (variant) {
      case WebbUITabVariant.segmented:
        return BoxDecoration(
          borderRadius:
              BorderRadius.circular(webbTheme.spacingGrid.baseSpacing),
          border: Border.all(
            color: webbTheme.colorPalette.neutralDark.withOpacity(0.2),
            width: 1,
          ),
        );
      case WebbUITabVariant.pills:
        return BoxDecoration(
          borderRadius:
              BorderRadius.circular(webbTheme.spacingGrid.baseSpacing * 4),
        );
      case WebbUITabVariant.standard:
      default:
        return null;
    }
  }

  BorderRadius _getBorderRadius(BuildContext webbTheme) {
    switch (variant) {
      case WebbUITabVariant.segmented:
        return BorderRadius.circular(webbTheme.spacingGrid.baseSpacing);
      case WebbUITabVariant.pills:
        return BorderRadius.circular(webbTheme.spacingGrid.baseSpacing * 4);
      case WebbUITabVariant.standard:
      default:
        return orientation == WebbUITabOrientation.vertical
            ? BorderRadius.only(
                topLeft: Radius.circular(webbTheme.spacingGrid.baseSpacing),
                bottomLeft: Radius.circular(webbTheme.spacingGrid.baseSpacing),
              )
            : BorderRadius.zero;
    }
  }

  Widget _buildContent(BuildContext webbTheme) {
    final textStyle = webbTheme.typography.labelLarge.copyWith(
      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      color: _getTextColor(webbTheme),
    );

    if (orientation == WebbUITabOrientation.horizontal &&
        variant == WebbUITabVariant.standard) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: textStyle),
          SizedBox(height: webbTheme.spacingGrid.spacing(0.5)),
          // Horizontal Tab Indicator
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 2,
            width: isSelected ? double.infinity : 0.0,
            decoration: BoxDecoration(
              color: isSelected
                  ? webbTheme.colorPalette.primary
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      );
    }

    return Text(
      label,
      style: textStyle,
      textAlign: TextAlign.center,
    );
  }

  Color _getTextColor(BuildContext webbTheme) {
    switch (variant) {
      case WebbUITabVariant.segmented:
        return isSelected
            ? webbTheme.colorPalette.onPrimary
            : webbTheme.colorPalette.neutralDark;
      case WebbUITabVariant.pills:
        return isSelected
            ? webbTheme.colorPalette.primary
            : webbTheme.colorPalette.neutralDark;
      case WebbUITabVariant.standard:
      default:
        return isSelected
            ? webbTheme.colorPalette.primary
            : webbTheme.colorPalette.neutralDark.withOpacity(0.7);
    }
  }
}
