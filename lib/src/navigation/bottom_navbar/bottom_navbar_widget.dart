import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';
import 'bottom_navbar_item.dart';

class WebbUIBottomNav extends StatelessWidget {
  final List<WebbUIBottomNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final Color? backgroundColor;
  final double height;

  const WebbUIBottomNav({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
    this.backgroundColor,
    this.height = 72.0,
  });

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? webbTheme.colorPalette.surface,
        boxShadow: webbTheme.elevation.getShadows(1),
      ),
      child: Row(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isSelected = index == selectedIndex;

          return Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onItemSelected(index),
                highlightColor: webbTheme.interactionStates.hoverOverlay,
                splashColor: webbTheme.interactionStates.pressedOverlay,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: webbTheme.spacingGrid.spacing(1),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        size: webbTheme.iconTheme.mediumSize,
                        color: isSelected
                            ? webbTheme.colorPalette.primary
                            : webbTheme.colorPalette.neutralDark
                                .withOpacity(0.6),
                      ),
                      SizedBox(height: webbTheme.spacingGrid.spacing(0.5)),
                      Text(
                        item.label,
                        style: webbTheme.typography.labelSmall.copyWith(
                          color: isSelected
                              ? webbTheme.colorPalette.primary
                              : webbTheme.colorPalette.neutralDark
                                  .withOpacity(0.6),
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
