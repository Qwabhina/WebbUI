import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';

enum WebbUITabOrientation { horizontal, vertical }

/// A reusable component for rendering tabs in either a horizontal or vertical orientation.
class WebbUITabs extends StatelessWidget {
  final List<String> tabLabels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final WebbUITabOrientation orientation;

  const WebbUITabs({
    super.key,
    required this.tabLabels,
    required this.selectedIndex,
    required this.onChanged,
    this.orientation = WebbUITabOrientation.horizontal,
  });

  @override
  Widget build(BuildContext context) {

    if (orientation == WebbUITabOrientation.vertical) {
      // Vertical Tabs: Use a Column for layout
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          tabLabels.length,
          (index) => _WebbUITabItem(
            label: tabLabels[index],
            index: index,
            isSelected: index == selectedIndex,
            orientation: orientation,
            onTap: onChanged,
          ),
        ),
      );
    }

    // Horizontal Tabs: Use a Row for layout
    return Container(
      // Container ensures the border/line sits correctly
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: context.colorPalette.neutralDark.withOpacity(0.1),
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Wrap content width
        children: List.generate(
          tabLabels.length,
          (index) => _WebbUITabItem(
            label: tabLabels[index],
            index: index,
            isSelected: index == selectedIndex,
            orientation: orientation,
            onTap: onChanged,
          ),
        ),
      ),
    );
  }
}

/// Private widget to render a single tab item with selected state styling.
class _WebbUITabItem extends StatelessWidget {
  const _WebbUITabItem({
    required this.label,
    required this.index,
    required this.isSelected,
    required this.orientation,
    required this.onTap,
  });

  final String label;
  final int index;
  final bool isSelected;
  final WebbUITabOrientation orientation;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final primaryColor = context.colorPalette.primary;
    final neutralDark = context.colorPalette.neutralDark;
    final spacing = context.spacingGrid.spacing(1.5); // 12px padding

    final labelStyle = context.typography.labelLarge.copyWith(
      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      color: isSelected ? primaryColor : neutralDark,
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onTap(index),
        child: orientation == WebbUITabOrientation.horizontal
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: spacing,
                      right: spacing,
                      top: spacing,
                      bottom: spacing / 2, // Space for indicator
                    ),
                    child: Text(label, style: labelStyle),
                  ),
                  // Horizontal Tab Indicator
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 2,
                    width: isSelected ? 48.0 : 0.0,
                    color: isSelected ? primaryColor : Colors.transparent,
                  ),
                ],
              )
            : Container(
                // Vertical Tab Styling
                margin: EdgeInsets.symmetric(
                    vertical: context.spacingGrid.spacing(0.5)),
                padding: EdgeInsets.symmetric(
                    horizontal: spacing, vertical: spacing * 0.75),
                decoration: BoxDecoration(
                  color: isSelected
                      ? primaryColor.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius:
                      BorderRadius.circular(context.spacingGrid.baseSpacing),
                  border: Border(
                    left: BorderSide(
                      color: isSelected ? primaryColor : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Text(
                  label,
                  style: labelStyle.copyWith(
                    color: isSelected ? primaryColor : neutralDark,
                  ),
                ),
              ),
      ),
    );
  }
}
