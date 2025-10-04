import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';

enum WebbUITabOrientation { horizontal, vertical }

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
    final webbTheme = context;
    if (orientation == WebbUITabOrientation.vertical) {
      return ListView.builder(
        scrollDirection:
            Axis.horizontal, // For vertical, but wait, vertical tabs are column
        itemCount: tabLabels.length,
        itemBuilder: (context, index) {
          return ListTile(
            title:
                Text(tabLabels[index], style: webbTheme.typography.labelLarge),
            selected: index == selectedIndex,
            onTap: () => onChanged(index),
            selectedTileColor:
                webbTheme.colorPalette.secondary.withOpacity(0.2),
          );
        },
      );
    }
    return TabBar(
      tabs: tabLabels.map((label) => Tab(text: label)).toList(),
      labelColor: webbTheme.colorPalette.primary,
      unselectedLabelColor: webbTheme.colorPalette.neutralDark,
      onTap: onChanged,
    );
  }
}
