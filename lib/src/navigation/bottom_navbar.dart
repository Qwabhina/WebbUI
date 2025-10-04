import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';

class WebbUIBottomNavItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const WebbUIBottomNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class WebbUIBottomNav extends StatelessWidget {
  final List<WebbUIBottomNavItem> items;
  final int selectedIndex;

  const WebbUIBottomNav({
    super.key,
    required this.items,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    return BottomNavigationBar(
      items: items
          .map((item) => BottomNavigationBarItem(
                icon: Icon(item.icon),
                label: item.label,
              ))
          .toList(),
      currentIndex: selectedIndex,
      selectedItemColor: webbTheme.colorPalette.primary,
      unselectedItemColor: webbTheme.colorPalette.neutralDark,
      onTap: (index) => items[index].onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: webbTheme.colorPalette.neutralLight,
    );
  }
}
