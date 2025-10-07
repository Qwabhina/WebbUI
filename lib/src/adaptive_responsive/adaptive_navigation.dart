import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';


class WebbUIAdaptiveNavigation extends StatelessWidget {
  final List<NavigationRailDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int>? onDestinationSelected;
  final Widget? trailing;

  const WebbUIAdaptiveNavigation({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    this.onDestinationSelected,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    final double width = MediaQuery.of(context).size.width;

    if (width < 600) {
      return Drawer(
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: destinations.length + (trailing != null ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == destinations.length && trailing != null) {
              return trailing!;
            }
            final destination = destinations[index];
            return ListTile(
              leading: destination.icon,
              title: Text(destination.label as String,
                  style: webbTheme.typography.bodyMedium),
              selected: index == selectedIndex,
              onTap: () => onDestinationSelected?.call(index),
            );
          },
        ),
      );
    } else {
      return NavigationRail(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        labelType: NavigationRailLabelType.all,
        backgroundColor: webbTheme.colorPalette.neutralLight,
        unselectedIconTheme:
            IconThemeData(color: webbTheme.colorPalette.neutralDark),
        selectedIconTheme: IconThemeData(color: webbTheme.colorPalette.primary),
        destinations: destinations,
        trailing: trailing,
      );
    }
  }
}
